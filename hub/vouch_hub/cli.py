"""vouch_hub CLI: python -m vouch_hub <cmd>."""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

import numpy as np

from . import audio, config, signing, voiceprint
from .config import DATA_DIR
from .evaluation import EVAL_DIR, collect_trials, eer, far_frr, sweep, write_report
from .normalise import normalise
from . import spoof

EVAL_PHRASES = [
    "Alexa, unlock the front door.",
    "Alexa, what's the weather today?",
    "Alexa, add chocolate to the shopping list.",
    "Alexa, order the new PlayStation for 500 euros.",
    "My voice is my password, please verify me.",
]
EVAL_CONDITIONS = ["quiet", "tv-on", "far-3m"]

ENROL_PHRASES = [
    "My voice is my password, please verify me.",
    "The quick brown fox jumps over the lazy dog.",
    "Alexa, what is the weather like in Berlin today?",
    "Please add oat milk and fresh bread to the shopping list.",
    "I would like to hear some quiet jazz in the kitchen.",
    "Remind me to call the dentist on Thursday at nine.",
    "Seven purple elephants danced across the sunny meadow.",
    "Our house has a red front door and a small garden.",
]
DEMO_COMMANDS = {
    "owner": {"unlock": "Alexa, unlock the front door.",
              "weather": "Alexa, what's the weather today?",
              "order": "Alexa, order the new PlayStation for 500 euros."},
    "child": {"order": "Alexa, order the new PlayStation for 500 euros.",
              "unlock": "Alexa, unlock the front door.",
              "list": "Alexa, add chocolate to the shopping list."},
}
VOICES = {"owner": ["Daniel", "Fred"], "child": ["Samantha", "Flo (English (US))", "Junior"]}
PENDING = DATA_DIR / "pending.json"
SPOOF_LOG = DATA_DIR / "spoof_log.jsonl"


def _ms(t0):
    return round((time.perf_counter() - t0) * 1000, 1)


def _server(cfg):
    from .server import Serverpod
    return Serverpod(cfg["serverUrl"])


def cmd_keygen(a):
    pub = signing.keygen(force=a.force)
    print(f"public key (raw Ed25519, base64): {pub}\nprivate key: {signing.KEY_DIR/'hub_ed25519.key'} (0600)")


def cmd_register(a):
    cfg = config.load()
    pub = signing.public_key_b64(signing.load_private())
    seed = _server(cfg).seed_demo_household(a.owner, a.child, pub)
    cfg.update({"householdId": seed["householdId"], "hubId": seed["hubId"],
                "members": {"owner": seed["ownerMemberId"], "child": seed["childMemberId"]},
                "names": {"owner": a.owner, "child": a.child}, "mcpToken": seed["mcpToken"]})
    config.save(cfg)
    print(f"registered household {seed['householdId']} hub {seed['hubId']} "
          f"owner={seed['ownerMemberId']} child={seed['childMemberId']} -> {config.CONFIG_PATH}")


def _member_id(cfg, who):
    if who in cfg.get("members", {}):
        return int(cfg["members"][who])
    return int(who)


def cmd_enrol(a):
    from . import models
    cfg = config.load()
    mid = _member_id(cfg, a.member)
    clips = []
    if a.mic:
        for i, p in enumerate(ENROL_PHRASES, 1):
            input(f"[{i}/8] press Enter, then say: \"{p}\"")
            clips.append((f"mic#{i}", audio.record(5.0)))
    else:
        clips = [(w, audio.load_wav(w)) for w in a.wav]
    if len(clips) < 3:
        sys.exit("need at least 3 clips (8 recommended)")
    embs = []
    for name, x in clips:
        x = audio.trim(x)
        q = audio.quality(x)
        if not q["ok"]:
            print(f"  REJECT {Path(str(name)).name}: {q['problems']}")
            continue
        t0 = time.perf_counter()
        embs.append(models.embed(x))
        print(f"  ok {Path(str(name)).name}: {q['duration_s']}s rms={q['rms_dbfs']}dBFS "
              f"snr~{q['snr_db']}dB embed={_ms(t0)}ms")
    if len(embs) < 3:
        sys.exit("too few clips passed the quality check")
    c = voiceprint.save(mid, embs)
    intra = [float(np.dot(e, c)) for e in embs]
    quality = float(np.mean(intra))
    print(f"enrolled member {mid} ({a.member}) from {len(embs)} clips; "
          f"intra-cosine min={min(intra):.3f} mean={quality:.3f}; "
          f"load={models.load_times()} -> {voiceprint.VP_DIR/f'{mid}.npy'} (local only)")

    captured_at = signing.now_ms()
    embedding_ref = f"member-{mid}"
    payload_str, sig = signing.sign_enrolment(
        signing.load_private(), hub_id=cfg["hubId"], member_id=mid,
        embedding_ref=embedding_ref, quality_score=quality,
        sample_count=len(embs), captured_at=captured_at)
    try:
        res = _server(cfg).report_enrolment(
            hubId=cfg["hubId"], memberId=mid, embeddingRef=embedding_ref,
            qualityScore=quality, sampleCount=len(embs),
            capturedAt=signing.iso_utc(captured_at), signatureBase64=sig)
        print(f"reported enrolment to server: {res}")
    except Exception as e:
        print(f"WARNING: could not report enrolment to server: {e}")


def _spoof_check(x, cfg, timings):
    """Signal only — never a boundary (anti-spoof score can only lower trust,
    never raise it). Returns (spoof_score, spoof_risk_enum, scorer_name).
    """
    scorer = spoof.build_scorer(cfg.get("spoofScorer", "null"))
    score, ms = spoof.timed_score(scorer, x)
    timings["spoof_ms"] = ms
    risk = spoof.score_to_risk(
        score, float(cfg.get("spoofMediumThreshold", 0.4)), float(cfg.get("spoofHighThreshold", 0.75)))
    return score, risk, scorer.name


def _log_spoof(entry: dict) -> None:
    """Local-only record of the raw float score + scorer name. The signed
    attestation schema only has room for the 3-value `spoofRisk` enum (see
    spoof.py), so this is where the full-precision score and model
    identity actually live until the server schema grows a slot for them
    (see README "Anti-spoof signal" for the exact change needed)."""
    SPOOF_LOG.parent.mkdir(parents=True, exist_ok=True)
    with open(SPOOF_LOG, "a") as f:
        f.write(json.dumps(entry) + "\n")


def attest_audio(x, cfg, submit=True, transcript_override=None, server=None, sk=None):
    """Full pipeline on one utterance. Returns a result dict."""
    from . import models
    timings, t_all = {}, time.perf_counter()
    captured_at = signing.now_ms()
    t0 = time.perf_counter(); x = audio.trim(x); timings["vad_ms"] = _ms(t0)
    if len(x) < audio.SR * 0.3:
        return {"status": "no_speech", "timings": timings}
    t0 = time.perf_counter(); emb = models.embed(x); timings["embed_ms"] = _ms(t0)
    names = {v: k for k, v in cfg.get("members", {}).items()}
    member, scores = voiceprint.identify(emb, voiceprint.load_all(), float(cfg["threshold"]))
    pretty = {names.get(k, k): round(v, 3) for k, v in scores.items()}
    if member is None:
        timings["total_ms"] = _ms(t_all)
        return {"status": "unrecognised", "scores": pretty, "timings": timings}
    if transcript_override is None:
        t0 = time.perf_counter(); raw = models.transcribe(x); timings["asr_ms"] = _ms(t0)
    else:
        raw = transcript_override
    norm = normalise(raw)
    confidence = round(min(max(scores[member], 0.0), 1.0), 4)

    spoof_score, spoof_risk, scorer_name = _spoof_check(x, cfg, timings)
    tier = spoof.cap_tier("t1", spoof_score, float(cfg.get("spoofHighThreshold", 0.75)),
                          bool(cfg.get("spoofCapTierAtT1", False)))
    _log_spoof({"capturedAt": signing.iso_utc(captured_at), "memberId": member,
                "scorer": scorer_name, "spoofScore": spoof_score, "spoofRisk": spoof_risk,
                "tierAfterCap": tier, "capEnabled": bool(cfg.get("spoofCapTierAtT1", False))})

    t0 = time.perf_counter()
    payload, sig = signing.sign_attestation(
        sk or signing.load_private(), hub_id=cfg["hubId"], member_id=member, tier=tier,
        confidence=confidence, spoof_risk=spoof_risk, transcript_normalised=norm, captured_at=captured_at)
    timings["sign_ms"] = _ms(t0)
    out = {"status": "recognised", "member": names.get(member, member), "memberId": member,
           "scores": pretty, "transcript": raw, "normalised": norm, "confidence": confidence,
           "payload": payload, "spoofScore": spoof_score, "spoofRisk": spoof_risk, "tier": tier}
    if submit:
        t0 = time.perf_counter()
        from .server import RpcError
        try:
            res = (server or _server(cfg)).submit_attestation(
                hubId=cfg["hubId"], memberId=member, tier=tier, confidence=confidence,
                spoofRisk=spoof_risk, transcriptNormalised=norm,
                capturedAt=signing.iso_utc(captured_at), signatureBase64=sig)
            out["submitted"] = {"id": res.get("id") if isinstance(res, dict) else res}
        except RpcError as e:
            out["submitted"] = {"error": str(e)}
        timings["submit_ms"] = _ms(t0)
    timings["total_ms"] = _ms(t_all)
    out["timings"] = timings
    return out


def _print_attest(r):
    if r["status"] != "recognised":
        print(f"unrecognised  scores={r.get('scores')}  timings={r['timings']}" if r["status"] ==
              "unrecognised" else f"no speech  timings={r['timings']}")
        return
    print(f"speaker: {r['member']} (id {r['memberId']})  scores={r['scores']}\n"
          f"transcript: {r['transcript']!r} -> {r['normalised']!r}\n"
          f"tier: {r['tier']}  spoof: score={r['spoofScore']} risk={r['spoofRisk']} (signal only)\n"
          f"submit: {r.get('submitted')}\ntimings: {r['timings']}")


def cmd_attest(a):
    from . import models
    cfg = config.load()
    if a.threshold is not None:
        cfg["threshold"] = a.threshold
    models.titanet(); models.parakeet()
    print(f"models resident: {models.load_times()}")
    x = audio.record(a.seconds) if a.mic else audio.load_wav(a.wav)
    _print_attest(attest_audio(x, cfg, submit=not a.dry_run))


def cmd_listen(a):
    import queue
    import sounddevice as sd
    from . import models
    cfg = config.load()
    models.titanet(); models.parakeet()
    print(f"models resident: {models.load_times()} — listening (Ctrl-C to stop)")
    q, blk = queue.Queue(), audio.FRAME
    buf, silence, active, noise = [], 0, False, 1e-3
    with sd.InputStream(samplerate=audio.SR, channels=1, blocksize=blk, dtype="float32",
                        callback=lambda d, *_: q.put(d[:, 0].copy())):
        while True:
            f = q.get()
            e = float(np.sqrt((f ** 2).mean()))
            if not active:
                noise = 0.95 * noise + 0.05 * e
            if e > max(noise * 4, 0.01):
                active, silence = True, 0
            if active:
                buf.append(f)
                silence = silence + 1 if e <= max(noise * 2, 0.005) else 0
                if silence > 35 or len(buf) > 50 * 12:  # 700 ms silence or 12 s cap
                    _print_attest(attest_audio(np.concatenate(buf), cfg))
                    buf, active, silence = [], False, 0


def cmd_pair(a):
    """Mints a fresh 6-digit pairing code for this hub's household and
    prints it big and clear, with its expiry — the household owner enters
    it in the Flutter app's "Pair with your hub" screen (sign-in is
    anonymous + hub pairing, not email).
    """
    cfg = config.load()
    captured_at = signing.now_ms()
    sk = signing.load_private()
    payload_str, sig = signing.sign_pairing(sk, hub_id=cfg["hubId"], captured_at=captured_at)
    code = _server(cfg).create_pairing_code(
        hubId=cfg["hubId"], capturedAt=signing.iso_utc(captured_at), signatureBase64=sig,
    )
    expires = captured_at.replace(microsecond=0)
    print()
    print("=" * 32)
    print(f"   PAIRING CODE:  {code}")
    print("=" * 32)
    print(f"expires 10 minutes from {expires.isoformat()}")
    print("enter this code in the Vouch app's \"Pair with your hub\" screen")
    print()


def _mcp(cfg):
    from .mcp import Mcp
    return Mcp(cfg["mcpUrl"], cfg["mcpToken"], legacy=cfg.get("mcpMode") == "legacy")


def _report(res):
    d = res["decision"]
    if d == "APPROVAL PENDING":
        ref = res.get("approvalId") or (res.get("approvalRef") or "")[:16] + "…"
        print(f"APPROVAL PENDING ref={ref} approvalId={res.get('approvalId')} mode={res['mode']}"
              f" — {res['text']}\n  approve with: python -m vouch_hub approve {res.get('approvalId') or ref}")
    elif d == "DENIED":
        print(f"DENIED: {res['text']}")
    elif d == "ALLOWED":
        print(f"ALLOWED: {res['text']}")
    else:
        print(f"ERROR: {res['text']}")


def _retry(cfg, p):
    cfg = {**cfg, "mcpMode": p["mode"] if p["mode"] == "legacy" else "modern"}
    m = _mcp(cfg)
    if p["mode"] == "mrtr":
        return m.call_tool(p["tool"], p["args"], request_state=p["requestState"])
    return m.call_tool(p["tool"], {**p["args"], "approvalRef": p["approvalRef"]})


def cmd_alexa(a):
    from .router import route
    cfg = config.load()
    if a.legacy:
        cfg["mcpMode"] = "legacy"
    if a.retry:
        src = PENDING if PENDING.exists() else PENDING.with_name("last_used.json")
        res = _retry(cfg, json.loads(src.read_text()))
    else:
        tool, args = route(a.text)
        print(f"router: {tool} {json.dumps({k: v for k, v in args.items() if k != 'utterance'})}")
        t0 = time.perf_counter()
        res = _mcp(cfg).call_tool(tool, args)
        print(f"mcp: {_ms(t0)}ms")
        if res["decision"] == "APPROVAL PENDING":
            PENDING.parent.mkdir(parents=True, exist_ok=True)
            PENDING.write_text(json.dumps({"tool": tool, "args": args, **{k: res.get(k) for k in (
                "mode", "requestState", "approvalRef", "approvalId")}}))
    if a.verbose:
        print(json.dumps(res["raw"], indent=2))
    _report(res)
    return 0 if res["decision"] in ("ALLOWED", "APPROVAL PENDING") else 1


def cmd_approve(a):
    cfg = config.load()
    ref = a.ref
    if ref is None:
        ref = json.loads(PENDING.read_text()).get("approvalId")
    approval = _server(cfg).approve_as_owner(int(ref))
    print(f"approved: status={approval.get('status') if approval else None}")
    if not a.no_retry and PENDING.exists():
        res = _retry(cfg, json.loads(PENDING.read_text()))
        print("retry:", end=" "); _report(res)
        if res["decision"] == "ALLOWED":
            PENDING.rename(PENDING.with_name("last_used.json"))  # kept for replay testing


def _pick_voice(cands):
    avail = subprocess.run(["say", "-v", "?"], capture_output=True, text=True).stdout
    for c in cands:
        if any(line.startswith(c + " ") for line in avail.splitlines()):
            return c
    return None


def cmd_demo_voices(a):
    import soundfile as sf
    out = DATA_DIR / "demo"
    out.mkdir(parents=True, exist_ok=True)
    for who in ("owner", "child"):
        voice = _pick_voice(VOICES[who])
        texts = {f"enrol_{i+1:02d}": p for i, p in enumerate(ENROL_PHRASES)}
        texts.update({f"cmd_{k}": v for k, v in DEMO_COMMANDS[who].items()})
        for stem, t in texts.items():
            dst = out / f"{who}_{stem}.wav"
            aiff = out / f"{who}_{stem}.aiff"
            subprocess.run(["say", "-v", voice, "-o", str(aiff), t], check=True)
            subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1",
                            str(aiff), str(dst)], check=True)
            aiff.unlink()
        print(f"{who}: voice {voice!r}, {len(texts)} WAVs")
    print(f"-> {out}")


def cmd_record_session(a):
    import soundfile as sf
    speaker = a.speaker
    conditions = a.conditions or EVAL_CONDITIONS
    out_root = EVAL_DIR / speaker
    print(f"recording eval session for {speaker!r}: {len(conditions)} condition(s) x "
          f"{a.n} utterance(s) -> {out_root}")
    for cond in conditions:
        out = out_root / cond
        out.mkdir(parents=True, exist_ok=True)
        existing = len(list(out.glob("*.wav")))
        print(f"\ncondition: {cond}  (set up the room for this condition, e.g. TV on, "
              f"or stand ~3m from the mic, then press Enter)")
        input("press Enter when ready...")
        for i in range(1, a.n + 1):
            phrase = EVAL_PHRASES[(i - 1) % len(EVAL_PHRASES)]
            input(f"  [{cond} {i}/{a.n}] press Enter, then say: \"{phrase}\"")
            x = audio.record(a.seconds)
            path = out / f"{existing + i:02d}.wav"
            sf.write(str(path), x, audio.SR)
            q = audio.quality(audio.trim(x))
            print(f"    saved {path.name}: {q['duration_s']}s rms={q['rms_dbfs']}dBFS"
                  f"{'  WARNING: ' + '; '.join(q['problems']) if not q['ok'] else ''}")
    print(f"\ndone -> {out_root}")


def _load_eval_clips():
    """speaker-name -> list of trimmed waveforms, from every WAV under
    hub/data/eval/<speaker>/**/*.wav (condition subfolders are optional)."""
    clips = {}
    if not EVAL_DIR.exists():
        return clips
    for speaker_dir in sorted(p for p in EVAL_DIR.iterdir() if p.is_dir()):
        waves = []
        for wav in sorted(speaker_dir.rglob("*.wav")):
            waves.append(audio.trim(audio.load_wav(wav)))
        if waves:
            clips[speaker_dir.name] = waves
    return clips


def cmd_eval(a):
    from . import models
    cfg = config.load()
    prod_threshold = a.threshold if a.threshold is not None else float(cfg["threshold"])
    prints = voiceprint.load_all()
    if not prints:
        sys.exit("no enrolled voiceprints found; run `enrol` first")
    names_to_member = {v: int(cfg["members"][v]) for v in cfg.get("members", {})
                        if v in cfg.get("members", {})}
    # eval folder names may be the config alias (owner/child) or a raw member id
    clips = _load_eval_clips()
    if not clips:
        sys.exit(f"no WAVs found under {EVAL_DIR}; run `record-session` first, "
                  f"or copy hub/data/demo/*_cmd_*.wav into {EVAL_DIR}/<speaker>/ for a synthetic dry run")
    member_of_speaker = {}
    for speaker in clips:
        if speaker in names_to_member:
            member_of_speaker[speaker] = names_to_member[speaker]
        elif speaker.isdigit() and int(speaker) in prints:
            member_of_speaker[speaker] = int(speaker)
        else:
            member_of_speaker[speaker] = None  # unenrolled speaker -> impostor vs everyone
    print(f"speakers: { {s: member_of_speaker[s] for s in clips} }")
    print(f"clips per speaker: { {s: len(w) for s, w in clips.items()} }")
    models.titanet()
    genuine, impostor = collect_trials(prints, clips, member_of_speaker, models.embed)
    at_prod = far_frr(genuine, impostor, prod_threshold)
    eer_result = eer(genuine, impostor)
    thresholds = [round(0.3 + 0.05 * i, 2) for i in range(15)]  # 0.30..1.00
    sweep_result = sweep(genuine, impostor, thresholds)
    write_report(EVAL_DIR, prod_threshold, at_prod, eer_result, sweep_result, len(clips))
    print(f"\nat threshold {prod_threshold}: FAR={at_prod['far']} FRR={at_prod['frr']} "
          f"(n_genuine={at_prod['n_genuine']} n_impostor={at_prod['n_impostor']})")
    print(f"EER={eer_result['eer']} at threshold={eer_result['threshold']}")
    print(f"report written to {EVAL_DIR/'report.md'} and {EVAL_DIR/'report.json'}")


def cmd_serve(a):
    from . import httpserver
    httpserver.serve(host=a.host, port=a.port)


def main(argv=None):
    ap = argparse.ArgumentParser(prog="vouch_hub")
    sp = ap.add_subparsers(dest="cmd", required=True)
    p = sp.add_parser("keygen"); p.add_argument("--force", action="store_true"); p.set_defaults(f=cmd_keygen)
    p = sp.add_parser("register"); p.add_argument("--owner", required=True); p.add_argument("--child", required=True)
    p.set_defaults(f=cmd_register)
    p = sp.add_parser("enrol"); p.add_argument("--member", required=True)
    g = p.add_mutually_exclusive_group(required=True); g.add_argument("--mic", action="store_true")
    g.add_argument("--wav", nargs="+"); p.set_defaults(f=cmd_enrol)
    p = sp.add_parser("attest"); g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--mic", action="store_true"); g.add_argument("--wav")
    p.add_argument("--seconds", type=float, default=4.0); p.add_argument("--threshold", type=float)
    p.add_argument("--dry-run", action="store_true"); p.set_defaults(f=cmd_attest)
    p = sp.add_parser("listen"); p.set_defaults(f=cmd_listen)
    p = sp.add_parser("alexa"); p.add_argument("text", nargs="?"); p.add_argument("--retry", action="store_true")
    p.add_argument("-v", "--verbose", action="store_true")
    p.add_argument("--legacy", action="store_true", help="2025-11-25 session + approvalRef flow")
    p.set_defaults(f=cmd_alexa)
    p = sp.add_parser("approve"); p.add_argument("ref", nargs="?"); p.add_argument("--no-retry", action="store_true")
    p.set_defaults(f=cmd_approve)
    p = sp.add_parser("pair"); p.set_defaults(f=cmd_pair)
    p = sp.add_parser("demo-voices"); p.set_defaults(f=cmd_demo_voices)
    p = sp.add_parser("record-session"); p.add_argument("--speaker", required=True)
    p.add_argument("--conditions", nargs="+", help="default: quiet tv-on far-3m")
    p.add_argument("-n", type=int, default=5, help="utterances per condition (default 5)")
    p.add_argument("--seconds", type=float, default=5.0); p.set_defaults(f=cmd_record_session)
    p = sp.add_parser("eval"); p.add_argument("--threshold", type=float)
    p.set_defaults(f=cmd_eval)
    p = sp.add_parser("serve", help="local HTTP server for the Flutter web Hold-to-talk button")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=8765)
    p.set_defaults(f=cmd_serve)
    a = ap.parse_args(argv)
    return a.f(a) or 0
