# utterance-attest

Sign and verify short-lived, single-utterance speaker attestations for
voice agents — built for MCP tool calls, but not MCP-specific.

## The problem

A voice agent's MCP server (e.g. Alexa+) does its own speech
recognition and hands your server **text**, never audio. That means the
server can check *which app* is calling (OAuth) but has no way to check
*who spoke* — a cloned voice, a household member without authority, or a
recording can trigger the same tool call as the right person.

`utterance-attest` doesn't solve speaker verification (bring your own —
a local hub, an on-device model, whatever produces a confidence score
and a transcript). It solves the **binding problem** afterwards: given
a `(who, what was said, how confident, how risky)` tuple from your
verifier, it produces a short-lived, tamper-evident, Ed25519-signed
attestation your MCP server can check against the text the voice agent
actually recognised — so "who spoke" and "exactly what was said" travel
together and can't be mixed and matched.

The library has two independent pieces:

1. **Sign/verify** — Ed25519 over a small canonical JSON payload.
2. **Transcript matching** — normalise two transcripts (from your
   verifier and from the voice agent) and decide if they describe the
   same utterance, with a hard numeric guard so a fuzzy match can never
   authorise a different amount ("send 10" must never authorise "send
   1000").

Full wire format: [`SPEC.md`](./SPEC.md).

## Packages

| Language | Path | Install |
|---|---|---|
| Dart | [`dart/`](./dart) | add `utterance_attest` to `pubspec.yaml` |
| Python | [`python/`](./python) | `pip install ./python` from this repository |

Both implement the exact same spec and are tested against the same
vectors in [`vectors/`](./vectors), including a fixed test key that
each implementation signs with and cross-checks against — proving the
two languages produce byte-identical signatures for identical input.

### Dart usage

```dart
import 'package:utterance_attest/utterance_attest.dart';

// Your speaker verifier gives you (memberId, tier, confidence, spoofRisk)
// and a transcript. Normalise + hash it, then sign an attestation.
final transcript = Normalise.normalise('Alexa, send ten dollars to Mom');
final hash = Normalise.hash(transcript);

final payload = Payload.canonicalPayload(
  hubId: 1,
  memberId: 42,
  tier: 't1',
  confidence: 0.97,
  spoofRisk: 'low',
  transcriptHash: hash,
  capturedAt: DateTime.now(),
);

final keyPair = await Attest.keyPairFromSeed(hubPrivateKeyBase64);
final signed = await Attest.sign(payload, keyPair);

// --- later, on the MCP server, given the signed attestation + the
// text the voice agent recognised: ---
final ok = await Attest.verify(
  payload: signed.payload,
  signatureBase64: signed.signatureBase64,
  publicKeyBase64: signed.publicKeyBase64,
);
final fresh = Attest.isFresh(DateTime.parse(capturedAtIso), maxAge: Duration(seconds: 30));
final sameUtterance = Matching.transcriptsMatch(transcript, alexaRecognisedText);
final trusted = ok && fresh && sameUtterance;
```

### Python usage

```python
from datetime import datetime, timedelta, timezone
from utterance_attest import (
    normalise, transcript_hash, canonical_payload,
    sign_attestation, verify_attestation, is_fresh, transcripts_match,
)
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

transcript = normalise("Alexa, send ten dollars to Mom")
tx_hash = transcript_hash(transcript)

payload = canonical_payload(
    hub_id=1, member_id=42, tier="t1", confidence=0.97,
    spoof_risk="low", transcript_hash=tx_hash,
    captured_at=datetime.now(timezone.utc),
)

private_key = Ed25519PrivateKey.from_private_bytes(hub_private_key_bytes)
signed = sign_attestation(payload, private_key)

# --- later, on the MCP server: ---
ok = verify_attestation(
    payload=signed.payload,
    signature_base64=signed.signature_base64,
    public_key_base64=signed.public_key_base64,
)
fresh = is_fresh(captured_at, max_age=timedelta(seconds=30))
same_utterance = transcripts_match(transcript, alexa_recognised_text)
trusted = ok and fresh and same_utterance
```

## Security notes

- **Not a deepfake detector.** This library doesn't score or detect
  voice cloning — that's the caller's speaker-verification step
  (`confidence` / `spoofRisk` are opaque inputs this library just signs).
  The security boundary a system built on this library should rely on
  is knowledge the attacker doesn't have, not "the voice sounded real."
- **Freshness is the caller's job.** `is_fresh` / `isFresh` is provided,
  but *you* choose the window and *you* call it — a valid signature
  alone says nothing about recency.
- **Single-use is the caller's job.** Nothing here prevents replaying a
  still-fresh, still-valid attestation for a second tool call. If that
  matters for your use case, track consumed signatures (or transcript
  hashes) in your own store.
- **Keys never leave the signer.** Only the private key holder (the
  "hub" in the originating use case) calls `sign`/`sign_attestation`.
  Verifiers only ever need the public key. Nothing in this library
  transmits or persists private key material.
- **Numeric guard is deliberate, not incidental.** `transcripts_match` /
  `Matching.transcriptsMatch` requires identical numeric tokens on top
  of similarity, specifically so a high-confidence fuzzy match on
  wording can never silently authorise a different amount.

## Development

```
# Dart
cd dart && dart pub get && dart test

# Python
cd python
python3.12 -m venv .venv   # or any Python >= 3.9
./.venv/bin/pip install -e ".[test]"
./.venv/bin/python -m pytest
```

## Examples

Runnable, end-to-end sign → verify → match examples that exercise the
same API as above:

- [`examples/basic.py`](./examples/basic.py) — from `python/`: `pip install -e . && python3 ../examples/basic.py` (with `python/` on `PYTHONPATH`)
- [`dart/example/basic.dart`](./dart/example/basic.dart) — from `dart/`: `dart pub get && dart run example/basic.dart`

## Used by

`utterance-attest` was extracted from [Vouch](https://github.com/dj-DeepakJadhav/Vouch), a
per-person permission layer for shared voice assistants, where a local hub
signs an attestation for each recognised utterance and an MCP guard verifies
it against the text the voice agent recognised before allowing a tool call.
This library is the standalone sign/verify/match piece; it has no
dependency on Vouch and no knowledge of hubs, households or MCP.

## License

MIT — see [`LICENSE`](./LICENSE).
