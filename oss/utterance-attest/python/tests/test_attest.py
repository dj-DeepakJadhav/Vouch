import base64
from datetime import datetime, timedelta, timezone

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from utterance_attest.attest import is_fresh, sign_attestation, verify_attestation
from utterance_attest.payload import canonical_payload


def test_canonical_payload_matches_vector(signed_payload_vector):
    a = signed_payload_vector["attestation"]
    payload = canonical_payload(
        hub_id=a["hubId"],
        member_id=a["memberId"],
        tier=a["tier"],
        confidence=a["confidence"],
        spoof_risk=a["spoofRisk"],
        transcript_hash=a["transcriptHash"],
        captured_at=datetime.fromisoformat(a["capturedAt"].replace("Z", "+00:00")),
    )
    assert payload == signed_payload_vector["canonicalPayload"]


def test_verify_vector_signature(signed_payload_vector):
    assert verify_attestation(
        payload=signed_payload_vector["canonicalPayload"],
        signature_base64=signed_payload_vector["signatureBase64"],
        public_key_base64=signed_payload_vector["public_key_base64"],
    )


def test_sign_with_vector_key_reproduces_vector_signature(signed_payload_vector):
    # Proves this Python implementation, given the SAME fixed test key and
    # the same payload, produces the exact same signature Dart's tests
    # verify against — i.e. real cross-language compatibility, not just
    # "both accept the other's output".
    private_key = Ed25519PrivateKey.from_private_bytes(
        base64.b64decode(signed_payload_vector["private_key_base64"])
    )
    signed = sign_attestation(signed_payload_vector["canonicalPayload"], private_key)
    assert signed.signature_base64 == signed_payload_vector["signatureBase64"]
    assert signed.public_key_base64 == signed_payload_vector["public_key_base64"]


def test_verify_rejects_tampered_payload(signed_payload_vector):
    tampered = signed_payload_vector["canonicalPayload"].replace('"tier":"t1"', '"tier":"t2"')
    assert not verify_attestation(
        payload=tampered,
        signature_base64=signed_payload_vector["signatureBase64"],
        public_key_base64=signed_payload_vector["public_key_base64"],
    )


def test_verify_never_throws_on_garbage_input():
    assert not verify_attestation(payload="{}", signature_base64="not-base64!!", public_key_base64="also-not-base64!!")


def test_freshness_window():
    now = datetime(2026, 9, 24, 12, 0, 30, tzinfo=timezone.utc)
    captured = datetime(2026, 9, 24, 12, 0, 0, tzinfo=timezone.utc)
    assert is_fresh(captured, max_age=timedelta(seconds=60), now=now)
    assert not is_fresh(captured, max_age=timedelta(seconds=20), now=now)


def test_freshness_rejects_future_timestamp():
    now = datetime(2026, 9, 24, 12, 0, 0, tzinfo=timezone.utc)
    captured = datetime(2026, 9, 24, 12, 0, 30, tzinfo=timezone.utc)
    assert not is_fresh(captured, max_age=timedelta(seconds=60), now=now)
