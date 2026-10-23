"""Canonical enrolment payload + signing, and a mocked-server round trip for
`Serverpod.report_enrolment` (mirrors test_payload_signature.py's style for
attestations). Cross-checks
vouch/vouch_server/lib/src/enrolment/enrolment_signature.dart's
`EnrolmentSignature.canonicalPayload` field order/format by construction.
"""

from datetime import datetime, timezone

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from vouch_hub.keys import public_key_base64
from vouch_hub.payload import canonical_enrolment_payload, sign_payload
from vouch_hub.server import Serverpod
from vouch_hub.signing import sign_enrolment


class FakeRpcClient:
    def __init__(self):
        self.calls = []

    def call(self, endpoint, method, args=None):
        self.calls.append((endpoint, method, args or {}))
        return {"id": len(self.calls), "memberId": (args or {}).get("memberId")}


def test_canonical_enrolment_payload_format():
    captured_at = datetime(2026, 9, 24, 12, 0, 0, 0, tzinfo=timezone.utc)
    payload = canonical_enrolment_payload(
        hub_id=9,
        member_id=101,
        embedding_ref="member-101",
        quality_score=0.87,
        sample_count=8,
        captured_at=captured_at,
    )
    assert payload == (
        '{"hubId":9,"memberId":101,"embeddingRef":"member-101",'
        '"qualityScore":0.87,"sampleCount":8,'
        '"capturedAt":"2026-09-24T12:00:00.000Z"}'
    )


def test_sign_enrolment_round_trip_verifies_locally():
    private_key = Ed25519PrivateKey.generate()
    public_b64 = public_key_base64(private_key.public_key())
    payload = canonical_enrolment_payload(
        hub_id=1,
        member_id=2,
        embedding_ref="member-2",
        quality_score=0.91,
        sample_count=8,
        captured_at=datetime.now(timezone.utc),
    )
    signed = sign_payload(payload, private_key, public_b64)

    import base64

    private_key.public_key().verify(
        base64.b64decode(signed.signature_base64), payload.encode("utf-8")
    )


def test_sign_enrolment_helper_matches_canonical_payload():
    private_key = Ed25519PrivateKey.generate()
    captured_at = datetime.now(timezone.utc)
    payload, sig = sign_enrolment(
        private_key,
        hub_id=9,
        member_id=101,
        embedding_ref="member-101",
        quality_score=0.87,
        sample_count=8,
        captured_at=captured_at,
    )
    assert payload == canonical_enrolment_payload(
        hub_id=9,
        member_id=101,
        embedding_ref="member-101",
        quality_score=0.87,
        sample_count=8,
        captured_at=captured_at,
    )
    import base64

    private_key.public_key().verify(base64.b64decode(sig), payload.encode("utf-8"))


def test_report_enrolment_calls_enrolment_report_endpoint():
    fake_rpc = FakeRpcClient()
    srv = Serverpod("http://localhost:8080", client=fake_rpc)

    result = srv.report_enrolment(
        hubId=9,
        memberId=101,
        embeddingRef="member-101",
        qualityScore=0.87,
        sampleCount=8,
        capturedAt="2026-09-24T12:00:00.000Z",
        signatureBase64="deadbeef==",
    )

    assert fake_rpc.calls == [
        (
            "enrolment",
            "report",
            {
                "hubId": 9,
                "memberId": 101,
                "embeddingRef": "member-101",
                "qualityScore": 0.87,
                "sampleCount": 8,
                "capturedAt": "2026-09-24T12:00:00.000Z",
                "signatureBase64": "deadbeef==",
            },
        )
    ]
    assert result["memberId"] == 101
