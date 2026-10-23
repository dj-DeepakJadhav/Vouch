"""Round-trip test for canonical payload construction + Ed25519 signing,
and a cross-language check against the server's Dart verifier
(AttestationSignature.verify) via vouch/vouch_server/tool/verify_signature.dart.
"""

import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pytest
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from vouch_hub.keys import public_key_base64
from vouch_hub.payload import canonical_payload, sign_payload

SERVER_DIR = Path(__file__).resolve().parents[2] / "vouch" / "vouch_server"


def test_canonical_payload_format():
    captured_at = datetime(2026, 9, 24, 12, 0, 0, 0, tzinfo=timezone.utc)
    payload = canonical_payload(
        hub_id=7,
        member_id=None,
        tier="t2",
        confidence=0.5,
        spoof_risk="high",
        transcript_hash="deadbeef",
        captured_at=captured_at,
    )
    assert payload == (
        '{"hubId":7,"memberId":null,"tier":"t2","confidence":0.5,'
        '"spoofRisk":"high","transcriptHash":"deadbeef",'
        '"capturedAt":"2026-09-24T12:00:00.000Z"}'
    )


def test_sign_round_trip_verifies_locally():
    private_key = Ed25519PrivateKey.generate()
    public_b64 = public_key_base64(private_key.public_key())
    payload = canonical_payload(
        hub_id=1,
        member_id=2,
        tier="t1",
        confidence=0.95,
        spoof_risk="low",
        transcript_hash="abc123",
        captured_at=datetime.now(timezone.utc),
    )
    signed = sign_payload(payload, private_key, public_b64)

    public_key = private_key.public_key()
    # Raises on failure; cryptography's verify() returns None on success.
    import base64

    public_key.verify(base64.b64decode(signed.signature_base64), payload.encode("utf-8"))


def _dart_available() -> bool:
    return shutil.which("dart") is not None and (
        SERVER_DIR / "tool" / "verify_signature.dart"
    ).exists()


@pytest.mark.skipif(
    not _dart_available(),
    reason="dart executable or tool/verify_signature.dart not found — "
    "cannot cross-check against the Dart AttestationSignature verifier",
)
def test_signature_verifies_in_dart():
    private_key = Ed25519PrivateKey.generate()
    public_b64 = public_key_base64(private_key.public_key())
    payload = canonical_payload(
        hub_id=42,
        member_id=None,
        tier="t0",
        confidence=0.1234,
        spoof_risk="medium",
        transcript_hash="cross-language-check",
        captured_at=datetime.now(timezone.utc),
    )
    signed = sign_payload(payload, private_key, public_b64)

    stdin_payload = json.dumps(
        {
            "payload": signed.payload,
            "signatureBase64": signed.signature_base64,
            "publicKeyBase64": signed.public_key_base64,
        }
    )

    result = subprocess.run(
        ["dart", "run", "tool/verify_signature.dart"],
        cwd=SERVER_DIR,
        input=stdin_payload,
        capture_output=True,
        text=True,
        timeout=60,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "true", (
        f"Dart verifier rejected a Python-signed payload.\n"
        f"stdout={result.stdout!r} stderr={result.stderr!r}"
    )
