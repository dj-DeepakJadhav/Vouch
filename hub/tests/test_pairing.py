"""Canonical pairing payload + signing, and a mocked-server round trip for
`Serverpod.create_pairing_code` (mirrors test_enrolment_report.py's style).
Cross-checks
vouch/vouch_server/lib/src/pairing/pairing_signature.dart's
`PairingSignature.canonicalPayload` field order/format by construction.
"""

from datetime import datetime, timezone

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from vouch_hub.keys import public_key_base64
from vouch_hub.payload import canonical_pairing_payload, sign_payload
from vouch_hub.server import Serverpod
from vouch_hub.signing import sign_pairing


class FakeRpcClient:
    def __init__(self):
        self.calls = []

    def call(self, endpoint, method, args=None):
        self.calls.append((endpoint, method, args or {}))
        return "483920"


def test_canonical_pairing_payload_format():
    captured_at = datetime(2026, 9, 24, 12, 0, 0, 0, tzinfo=timezone.utc)
    payload = canonical_pairing_payload(hub_id=9, captured_at=captured_at)
    assert payload == '{"hubId":9,"capturedAt":"2026-09-24T12:00:00.000Z"}'


def test_sign_pairing_round_trip_verifies_locally():
    private_key = Ed25519PrivateKey.generate()
    public_b64 = public_key_base64(private_key.public_key())
    payload = canonical_pairing_payload(hub_id=1, captured_at=datetime.now(timezone.utc))
    signed = sign_payload(payload, private_key, public_b64)

    import base64

    private_key.public_key().verify(
        base64.b64decode(signed.signature_base64), payload.encode("utf-8")
    )


def test_sign_pairing_helper_matches_canonical_payload():
    private_key = Ed25519PrivateKey.generate()
    captured_at = datetime.now(timezone.utc)
    payload, sig = sign_pairing(private_key, hub_id=9, captured_at=captured_at)
    assert payload == canonical_pairing_payload(hub_id=9, captured_at=captured_at)

    import base64

    private_key.public_key().verify(base64.b64decode(sig), payload.encode("utf-8"))


def test_create_pairing_code_calls_pairing_create_code_endpoint():
    fake_rpc = FakeRpcClient()
    srv = Serverpod("http://localhost:8080", client=fake_rpc)

    code = srv.create_pairing_code(
        hubId=9,
        capturedAt="2026-09-24T12:00:00.000Z",
        signatureBase64="deadbeef==",
    )

    assert fake_rpc.calls == [
        (
            "pairing",
            "createCode",
            {
                "hubId": 9,
                "capturedAt": "2026-09-24T12:00:00.000Z",
                "signatureBase64": "deadbeef==",
            },
        )
    ]
    assert code == "483920"
