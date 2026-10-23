# Vouch Attest

Vouch Attest signs utterance evidence and verifies it against a command in Dart and Python. It lives in the Vouch repository; the package import remains `utterance_attest`.

A speaker verifier supplies the member identity, confidence and transcript. This library signs those claims with Ed25519. It cannot establish whether the speaker verifier was correct.

## Packages

| Language | Location | Install |
|---|---|---|
| Dart | [dart/](./dart) | Add a local path dependency on `dart/` |
| Python | [python/](./python) | `pip install ./python` |

## Verify a command

Use the combined verifier when checking an incoming attestation. Get the trusted public key from your enrolled hub record. Accepting a key supplied by the incoming envelope would let an attacker sign their own evidence.

### Python

```python
from datetime import timedelta
from utterance_attest import verify_for_command

valid = verify_for_command(
    payload=envelope.payload,
    signature_base64=envelope.signature_base64,
    trusted_public_key_base64=enrolled_hub.public_key_base64,
    command=recognised_text,
    expected_hub_id=enrolled_hub.id,
    expected_member_id=expected_member_id,
    max_age=timedelta(seconds=30),
)
```

### Dart

```dart
import 'package:utterance_attest/utterance_attest.dart';

final valid = await Verification.verifyForCommand(
  payload: envelope.payload,
  signatureBase64: envelope.signatureBase64,
  trustedPublicKeyBase64: enrolledHub.publicKeyBase64,
  command: recognisedText,
  expectedHubId: enrolledHub.id,
  expectedMemberId: expectedMemberId,
  maxAge: const Duration(seconds: 30),
);
```

Both helpers check the signature and canonical seven-field schema, expected hub and member, the timestamp inside the signed payload, and the SHA-256 hash of the normalised command. Future timestamps, malformed payloads and changed command hashes return false. The helpers use exact hash equality; they do not use the lower-level fuzzy matcher.

Signing examples remain in [examples/basic.py](./examples/basic.py) and [dart/example/basic.dart](./dart/example/basic.dart). Wire format and normalisation rules are in [SPEC.md](./SPEC.md).

## Security boundaries

A successful verification checks signed evidence. Your application must still apply permissions and atomically consume approvals to prevent replay. The library has no replay database.

Confidence, tier and spoof-risk values are signed claims from your verifier. This library does not detect cloned voices or decide whether a confidence score is sufficient.

Normalisation is ASCII-only and handles a limited set of English number words. It strips punctuation, including decimal points and minus signs. Validate structured actions and amounts separately; equal normalised hashes do not establish semantic equivalence for arbitrary language or financial input. The lower-level fuzzy matcher also loses word order and must not be used as an authorisation decision.

Choose the freshness window for your application and keep verifier clocks synchronised. The combined helper reads freshness from the signed timestamp; the lower-level freshness helper requires the caller to supply the correct timestamp.

Keep private keys on the signer. The fixed private key in the shared test vectors is public test data and must never be used in deployment.

## Development

```sh
cd python
pip install -e '.[test]'
python -m pytest -q
```

```sh
cd dart
dart pub get
dart analyze
dart test
```

Both suites read the same vectors under [vectors/](./vectors). Command verification tests cover identity mismatches, changed amounts, expiry and malformed payloads that still have valid signatures. The root repository workflow runs both languages.

## License

MIT. See [LICENSE](./LICENSE).
