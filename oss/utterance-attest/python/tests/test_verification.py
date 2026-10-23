import base64
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import pytest

from utterance_attest import sign_attestation, verify_for_command

VECTORS = Path(__file__).resolve().parents[2] / "vectors"
FIXTURE = json.loads((VECTORS / "signed_payload.json").read_text())
CASES = json.loads((VECTORS / "verify_command.json").read_text())["cases"]


def check(**changes):
    args = dict(payload=FIXTURE["canonicalPayload"], signature_base64=FIXTURE["signatureBase64"],
                trusted_public_key_base64=FIXTURE["public_key_base64"], command="send 10 dollars to mom",
                expected_hub_id=1, expected_member_id=42, max_age=timedelta(seconds=30),
                now=datetime(2026, 9, 24, 12, 0, 1, tzinfo=timezone.utc))
    args.update(changes)
    return verify_for_command(**args)


@pytest.mark.parametrize("case", CASES, ids=lambda c: c["name"])
def test_shared_command_vectors(case):
    assert check(command=case["command"], expected_hub_id=case["hubId"],
                 expected_member_id=case["memberId"], max_age=timedelta(seconds=case["maxAgeSeconds"]),
                 now=datetime.fromisoformat(case["now"].replace("Z", "+00:00"))) == case["expected"]


def malformed_payloads():
    p = FIXTURE["canonicalPayload"]
    return ["null", "[]", "{}", "{", " " + p,
            p.replace('"hubId":1,', '"hubId":1,"hubId":1,'),
            p.replace('"hubId":1', '"hubId":true'),
            p.replace('"confidence":0.97', '"confidence":1.1'),
            p.replace('2026-09-24', '2026-02-30'),
            p.replace('.000Z', '.000123Z')]


@pytest.mark.parametrize("payload", malformed_payloads())
def test_even_valid_signatures_do_not_accept_noncanonical_or_malformed_schema(payload):
    key = Ed25519PrivateKey.from_private_bytes(base64.b64decode(FIXTURE["private_key_base64"]))
    signed = sign_attestation(payload, key)
    assert not check(payload=payload, signature_base64=signed.signature_base64)


def test_signature_and_trusted_key_cannot_be_substituted():
    assert not check(payload=FIXTURE["canonicalPayload"].replace('"tier":"t1"', '"tier":"t2"'))
    other = Ed25519PrivateKey.from_private_bytes(bytes(range(32, 64)))
    signed = sign_attestation(FIXTURE["canonicalPayload"], other)
    assert not check(trusted_public_key_base64=signed.public_key_base64)
    assert not check(signature_base64=FIXTURE["signatureBase64"] + "\n")


def test_input_limits_and_python_boolean_identity_do_not_bypass_checks():
    assert not check(command="a" * 4097)
    assert not check(payload="a" * 8193)
    assert not check(expected_hub_id=True)
    assert not check(expected_member_id=True)
