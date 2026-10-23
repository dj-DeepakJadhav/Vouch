# Vouch hub (Python)

Owns the mic, runs speaker verification (TitaNet) and ASR (Parakeet), and
signs short-lived Ed25519 attestations that `vouch_server` verifies before
permitting a privileged tool call. Voice verification cannot live in the MCP
server (Alexa+ sends text, not audio), and voiceprints never leave the hub.

## Setup

```bash
/opt/homebrew/bin/python3.12 -m venv hub/.venv
hub/.venv/bin/pip install -r hub/requirements.txt
```

Then, separately (large download, CPU wheel index is not PyPI's default —
this is why it's a two-step install, and why it runs in the background
during initial setup):

```bash
hub/.venv/bin/pip install torch --index-url https://download.pytorch.org/whl/cpu
hub/.venv/bin/pip install "nemo_toolkit[asr]"
```

TitaNet load (keep the model resident on MPS for inference speed: 9–35ms per embedding):

```python
from nemo.collections.asr.models import EncDecSpeakerLabelModel
model = EncDecSpeakerLabelModel.from_pretrained(
    "nvidia/speakerverification_en_titanet_large"
).eval().to("mps")
embedding = model.get_embedding(wav)  # -> [1, 192]
```

Requires `HF_TOKEN` in the environment.

## Package layout

- `vouch_hub/keys.py` — Ed25519 keygen/load; public key exported in the
  same raw-32-byte-base64 format `AttestationSignature.verify` decodes on
  the server (`vouch/vouch_server/lib/src/attestation/attestation_signature.dart`).
- `vouch_hub/payload.py` — canonical payload + signing, byte-identical to
  `AttestationSignature.canonicalPayload`.
- `vouch_hub/normalise.py` — Python port of `TranscriptMatcher.normalise`
  and `.hash` (`vouch/vouch_server/lib/src/attestation/transcript_matcher.dart`).
- `vouch_hub/rpc.py` — minimal Serverpod HTTP RPC client (JSON POST to
  `<host><endpoint>/<method>`, see `tests/test_rpc_greeting.py`).

## Cross-language verification

`vouch/vouch_server/tool/gen_transcript_vectors.dart` prints normaliser
test vectors (saved to `tests/transcript_vectors.json`).
`vouch/vouch_server/tool/verify_signature.dart` reads
`{payload, signatureBase64, publicKeyBase64}` JSON on stdin and prints
`true`/`false` using `AttestationSignature.verify` — this is how
`tests/test_signature_cross_check.py` proves the Python and Dart Ed25519
implementations agree on the same bytes.

Run from `vouch/vouch_server` (needs
`export PATH="$PATH:$HOME/.pub-cache/bin"`):

```bash
dart run tool/gen_transcript_vectors.dart > ../../hub/tests/transcript_vectors.json
echo '{"payload":"...","signatureBase64":"...","publicKeyBase64":"..."}' \
  | dart run tool/verify_signature.dart
```

## Tests

```bash
hub/.venv/bin/pytest hub/tests -v
```

The Serverpod dev server must be running on `http://localhost:8080` for
the (marked) live RPC test.

## CLI (`python -m vouch_hub <cmd>`, run from `hub/`)

```bash
P=".venv/bin/python -m vouch_hub"
$P keygen                                   # keys/hub_ed25519.key (0600) + .pub (raw 32-byte, base64)
$P register --owner Deepak --child Mia      # dev.seedDemoHousehold -> data/config.json (0600, holds mcpToken)
$P demo-voices                              # macOS `say` (Daniel=owner, Samantha=child) -> data/demo/*.wav, 16 kHz mono
$P enrol --member owner --wav data/demo/owner_enrol_*.wav   # or --mic; centroid -> data/voiceprints/<id>.npy (local only)
$P enrol --member child --wav data/demo/child_enrol_*.wav
$P attest --wav data/demo/owner_cmd_unlock.wav   # or --mic; [--threshold 0.6] [--dry-run]
$P alexa "Alexa, unlock the front door."          # within 3 s; [--legacy] for 2025-11-25 session/approvalRef flow
$P approve [approvalId]                           # dev.approveAsOwner, then auto-retries the pending call
$P alexa --retry                                  # re-send last pending/used state (replay check)
$P listen                                         # continuous mic + energy VAD, models resident
```

Only member id, tier, confidence, spoof risk, the normalised transcript,
capturedAt and a signature are sent to the server. Embeddings and audio never leave this machine.
Tests: `.venv/bin/python -m pytest -q` (`-m "not live"` to skip server-dependent tests).

## Voice simulator (task F3)

Lets the Flutter Alexa tab's "Hold to talk" button drive the same
`attest_audio` pipeline as `attest`/`listen`, from browser-recorded audio,
so one real voice can drive the whole simulated Alexa+ flow end to end.

```bash
cd hub && .venv/bin/python -m vouch_hub serve
```

Starts a local HTTP server bound to `127.0.0.1:8765` **only**. Models load
once at startup and stay resident. Endpoints:

- `GET /health` -> `{"ok": true}`
- `POST /utterance` — body is recorded browser audio
  (`audio/webm;codecs=opus` or `audio/wav`), converted to 16 kHz mono with
  `ffmpeg` (`brew install ffmpeg` if `ffmpeg -version` fails) and run
  through the same VAD -> TitaNet -> Parakeet -> Ed25519 attestation
  pipeline as `attest`. Returns
  `{"transcript", "speaker", "confidence", "attestationId", "spoofRisk"}`.
  CORS allows only Origins whose host is `localhost` or `127.0.0.1` (any
  port); everything else gets `403`. Body capped at 2 MB, audio at 10 s
  (`413` past either limit). No audio is persisted beyond what `attest`
  already writes (i.e. nothing extra).

The Flutter app shows a hint to run this command if `/health` doesn't
respond; the text-box path keeps working either way.

## Measuring accuracy

Record real room audio and get honest FAR/FRR/EER numbers at the production
threshold, instead of trusting synthetic TTS voices. Enrol the household
first (`register` + `enrol` above), then:

```bash
P=".venv/bin/python -m vouch_hub"
# guided recording, one folder per condition: data/eval/<speaker>/<condition>/NN.wav
$P record-session --speaker owner -n 5                    # default conditions: quiet tv-on far-3m
$P record-session --speaker owner --conditions quiet -n 8
$P record-session --speaker stranger --conditions quiet -n 5   # unenrolled voice -> impostor trials

$P eval                          # scores everything under data/eval/ at cfg["threshold"]
$P eval --threshold 0.7          # or compare a candidate threshold
```

`eval` treats a folder as genuine trials for that member if its name matches
a `register`-time alias (`owner`/`child`) or a raw member id, and as
impostor trials against every enrolled member otherwise (e.g. `stranger`).
It writes `data/eval/report.md` (FAR/FRR at the production threshold, EER,
and a threshold sweep) and the same numbers as `data/eval/report.json`.
`data/eval/` is gitignored, same as the rest of `data/`, and voiceprints and
audio never leave the hub.

For a quick dry run without a microphone, copy the synthetic demo command
WAVs into the eval layout and reuse the demo household's enrolment:

```bash
mkdir -p data/eval/owner data/eval/child
cp data/demo/owner_cmd_*.wav data/eval/owner/
cp data/demo/child_cmd_*.wav data/eval/child/
$P eval
```

## Anti-spoof signal

`vouch_hub/spoof.py` is a slot for scoring each attested utterance for likely
synthetic/replayed speech, 0..1 (higher = more likely spoofed). **No detector model ships
yet:** we found no openly licensed, ready-to-load anti-spoofing checkpoint, so the default
scorer is a labelled placeholder (`null-v0-not-a-detector`) that always returns 0.

**What it is:** a pluggable `SpoofScorer` interface, recorded alongside
every attestation, that can *at most* cap the attested tier at T1.

**What it is not, and never will be by itself:** a boundary. It cannot
allow a call, cannot raise a tier, and its absence or a low score never
grants anything We do not claim to detect deepfakes.

**Model:** no turnkey pretrained anti-spoof model (ASVspoof-trained
AASIST/RawNet2) was found published as a load-without-training Hugging
Face/NeMo checkpoint within the time budget — the well-known open
implementations (e.g. `clovaai/aasist`, MIT-licensed) ship as research
training code, not a `from_pretrained()`-able artifact. So the default
scorer is `NullScorer` (`vouch_hub/spoof.py`), explicitly named
`null-v0-not-a-detector` and hard-coded to always return `0.0` — it is
wiring, not detection. Swap in a real model later by adding a case to
`spoof.build_scorer()`; nothing else needs to change.

**Config** (`data/config.json`, all optional, defaults shown):

```json
{
  "spoofScorer": "null",
  "spoofMediumThreshold": 0.4,
  "spoofHighThreshold": 0.75,
  "spoofCapTierAtT1": false
}
```

`spoofCapTierAtT1` defaults to `false` (record only). Set it `true` to
also cap the tier at T1 when the score reaches `spoofHighThreshold` —
this can only lower a tier (`spoof.cap_tier` takes a `min()`), never
raise one, and t0 stays t0 even at a maximal score.

**What reaches the server today:** the signed attestation's `spoofRisk`
field is a fixed 3-value enum (`low`/`medium`/`high` —
`vouch/vouch_server/lib/src/enums/spoof_risk.spy.yaml`), which already
existed before this change and is now actually populated from the score
(mapped via the two thresholds above) instead of being hard-coded to
`"low"`. The **raw float score and scorer name have no slot in the
signed schema**, so they are recorded locally only, in
`data/spoof_log.jsonl` (one JSON line per attested utterance:
`capturedAt`, `memberId`, `scorer`, `spoofScore`, `spoofRisk`,
`tierAfterCap`, `capEnabled`).

**Server change that would surface this in the audit trail:** add a
`double? spoofScore` (and `String scorerName`) field next to `spoofRisk`
in `Attestation` (`lib/src/identity/attestation.spy.yaml`), thread it
through `AttestationSignature.canonicalPayload` (so it's part of what's
signed, not just reported), `attestation_service.dart`'s submit path, and
the `AuditEvent` it writes, then show it in the Flutter Activity tab's
"why" panel. This is a `vouch/` change and was intentionally not made
here (task C2 scope is hub-only).

**Demo WAVs** (`data/demo/*_cmd_*.wav`, macOS `say` TTS — see
`demo-voices` above): scored `0.0` / `low` by `NullScorer`, as expected
of a placeholder that always returns `0.0` — it has no actual opinion on
whether these (or any) samples are synthetic. Per-utterance latency was
effectively 0 ms (no model inference happens). These numbers say nothing
about real spoof detection; they only confirm the wiring runs.
