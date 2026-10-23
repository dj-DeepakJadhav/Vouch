"""Offline end-to-end on synthetic `say` voices: enrol owner + child, then attest
commands and check identification. Real TitaNet + Parakeet; server mocked.
Skips if the demo WAVs are absent (run `python -m vouch_hub demo-voices`)."""
import json

import numpy as np
import pytest

from vouch_hub import audio, cli, keys, signing, voiceprint
from vouch_hub.config import DATA_DIR

DEMO = DATA_DIR / "demo"
pytestmark = pytest.mark.skipif(not (DEMO / "owner_cmd_unlock.wav").exists(), reason="no demo voices")


class FakeServer:
    def __init__(self):
        self.calls = []

    def submit_attestation(self, **kw):
        self.calls.append(kw)
        return {"id": len(self.calls)}


@pytest.fixture(scope="module")
def env(tmp_path_factory):
    from vouch_hub import models
    vp = tmp_path_factory.mktemp("vp")
    voiceprint.VP_DIR = vp
    for mid, who in ((101, "owner"), (102, "child")):
        embs = [models.embed(audio.trim(audio.load_wav(p))) for p in sorted(DEMO.glob(f"{who}_enrol_*.wav"))]
        assert len(embs) == 8
        voiceprint.save(mid, embs)
    sk = keys.generate_keypair(tmp_path_factory.mktemp("k"))
    cfg = {"hubId": 9, "threshold": 0.6, "members": {"owner": 101, "child": 102}}
    return cfg, sk


@pytest.mark.parametrize("wav,who,expect", [
    ("child_cmd_order.wav", "child", "order the new playstation for 500 euros"),
    ("owner_cmd_unlock.wav", "owner", "unlock the front door"),
    ("owner_cmd_weather.wav", "owner", None),
    ("child_cmd_list.wav", "child", None),
])
def test_identify_and_sign(env, wav, who, expect):
    cfg, sk = env
    srv = FakeServer()
    r = cli.attest_audio(audio.load_wav(DEMO / wav), cfg, server=srv, sk=sk)
    assert r["status"] == "recognised" and r["member"] == who, r
    if expect:
        assert r["normalised"] == expect
    other = "child" if who == "owner" else "owner"
    assert r["scores"][who] - r["scores"][other] > 0.4
    [call] = srv.calls
    assert call["memberId"] == cfg["members"][who] and call["tier"] == "t1"
    assert signing.verify(signing.public_key_b64(sk), r["payload"], call["signatureBase64"])
    assert "embedding" not in str(call).lower() and all(not isinstance(v, (list, np.ndarray)) for v in call.values())


def test_unrecognised_submits_nothing(env, tmp_path):
    """A third, unenrolled synthetic voice must not be attested."""
    import subprocess
    aiff, wav = tmp_path / "x.aiff", tmp_path / "x.wav"
    subprocess.run(["say", "-v", "Fred", "-o", str(aiff), "Alexa, unlock the front door."], check=True)
    subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1", str(aiff), str(wav)], check=True)
    cfg, sk = env
    srv = FakeServer()
    r = cli.attest_audio(audio.load_wav(wav), cfg, server=srv, sk=sk)
    print("stranger scores", r.get("scores"))
    assert r["status"] == "unrecognised", r
    assert srv.calls == []


def test_attest_records_spoof_signal_and_never_raises_tier(env, monkeypatch, tmp_path):
    """C2: anti-spoof score is recorded and, when enabled, can only cap the
    tier at T1 — never allow or raise trust. Uses a fake high-score scorer
    so the test doesn't depend on a real model being wired up."""
    from vouch_hub import cli, spoof

    class AlwaysSpoofed:
        name = "fake-high-v1"
        def score(self, x):
            return 0.99

    monkeypatch.setattr(spoof, "build_scorer", lambda name="null": AlwaysSpoofed())
    monkeypatch.setattr(cli, "SPOOF_LOG", tmp_path / "spoof_log.jsonl")

    cfg, sk = env
    srv = FakeServer()

    # Cap disabled (default): high spoof score is recorded but tier stays t1.
    cfg_disabled = {**cfg, "spoofCapTierAtT1": False, "spoofHighThreshold": 0.75}
    r = cli.attest_audio(audio.load_wav(DEMO / "owner_cmd_unlock.wav"), cfg_disabled, server=srv, sk=sk)
    assert r["tier"] == "t1"
    assert r["spoofScore"] == 0.99
    assert r["spoofRisk"] == "high"

    # Cap enabled: still can't go above t1 (t1 capped at t1 is a no-op),
    # proving the cap only ever lowers, demonstrated properly against t0
    # via the unit test in test_spoof.py::test_cap_tier_never_produces_a_tier_above_input.
    cfg_enabled = {**cfg, "spoofCapTierAtT1": True, "spoofHighThreshold": 0.75}
    r2 = cli.attest_audio(audio.load_wav(DEMO / "owner_cmd_unlock.wav"), cfg_enabled, server=srv, sk=sk)
    assert r2["tier"] == "t1"

    log_lines = (tmp_path / "spoof_log.jsonl").read_text().strip().splitlines()
    assert len(log_lines) == 2
    entry = json.loads(log_lines[0])
    assert entry["scorer"] == "fake-high-v1"
    assert entry["spoofScore"] == 0.99
