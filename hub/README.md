# Vouch hub (Python)

The hub records audio, runs TitaNet speaker verification and Parakeet transcription, then signs short-lived Ed25519 evidence for `vouch_server`. Audio and enrolled voiceprints stay on the hub. The backend receives transcript text and signed metadata; it applies permissions before a tool call.

## Setup

Use Python 3.12. From the repository root:

```sh
python3.12 -m venv hub/.venv
hub/.venv/bin/pip install torch --index-url https://download.pytorch.org/whl/cpu
hub/.venv/bin/pip install -r hub/requirements.txt
```

Set `HF_TOKEN` in your environment before downloading gated model files. On macOS with Homebrew, use `/opt/homebrew/bin/python3.12` if Python 3.12 is not on your path. NeMo is included in `requirements.txt`.

On a Mac with MPS support, load TitaNet once and keep it resident:

```python
from nemo.collections.asr.models import EncDecSpeakerLabelModel
model = EncDecSpeakerLabelModel.from_pretrained(
    "nvidia/speakerverification_en_titanet_large"
).eval().to("mps")
embedding = model.get_embedding(wav)  # -> [1, 192]
```


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

## Browser microphone input

The Alexa tab's "Hold to talk" button sends browser-recorded audio to the local `attest_audio` pipeline used by `attest` and `listen`. The Alexa+ client remains simulated.

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

The evaluation harness measures false-accept rate (FAR), false-reject rate (FRR) and equal-error rate (EER). Synthetic demo voices do not establish real-room accuracy. Enrol the household with `register` and `enrol`, then record evaluation audio:

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

## Spoof-risk field

No deepfake detector ships. The default `NullScorer` in `vouch_hub/spoof.py` is labelled `null-v0-not-a-detector` and always returns `0.0`. Its output says nothing about whether speech is synthetic.

`SpoofScorer` accepts a score from 0 to 1. These optional settings in local `data/config.json` control how a future scorer maps that score:

```json
{
  "spoofScorer": "null",
  "spoofMediumThreshold": 0.4,
  "spoofHighThreshold": 0.75,
  "spoofCapTierAtT1": false
}
```

With `spoofCapTierAtT1` enabled, a score at or above the high threshold can lower a tier to T1. It cannot raise trust or permit a request. The default only records the score.

The signed payload contains the `low`, `medium` or `high` risk enum. The raw score and scorer name stay in the local `data/spoof_log.jsonl`; they are not fields in the signed schema. Add a scorer through `spoof.build_scorer()` and evaluate it on recorded speech before using its output for restrictions.
