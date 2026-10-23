"""Canonical attestation payload + signing.

Must byte-for-byte match `AttestationSignature.canonicalPayload` in
vouch/vouch_server/lib/src/attestation/attestation_signature.dart:

    {
      "hubId":<int>,
      "memberId":<int|null>,
      "tier":"<TrustTier enum name>",
      "confidence":<double, Dart `num` toString formatting>,
      "spoofRisk":"<SpoofRisk enum name>",
      "transcriptHash":"<string>",
      "capturedAt":"<UTC ISO-8601, e.g. 2026-09-24T12:00:00.000Z>"
    }

Field order is fixed and NOT derived from dict insertion order (mirroring
the Dart side deliberately hard-coding order, per its own docstring) so
both languages always produce identical bytes to sign/verify.
"""

from __future__ import annotations

import base64
import json
from dataclasses import dataclass
from datetime import datetime, timezone

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey


def _format_number(value: float) -> str:
    """Formats a float the way Dart's `num.toString()` / string
    interpolation does when written via `'"confidence":$confidence,'`.

    Dart prints a `double` with at least one digit after the decimal
    point (e.g. `0.95`, `1.0`), never as `0.950` or bare `1`. Python's
    `json.dumps`/`repr` already matches this for the values we produce
    (0..1 confidence scores) as long as the value is a genuine float, so
    we just guard against accidentally getting an int here.
    """
    f = float(value)
    text = repr(f)
    return text


def _format_datetime(dt: datetime) -> str:
    """UTC ISO-8601 with milliseconds and a trailing 'Z', matching Dart's
    `DateTime.toUtc().toIso8601String()` (which always includes
    milliseconds/microseconds and uses 'Z' for UTC, never '+00:00').
    """
    dt_utc = dt.astimezone(timezone.utc) if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
    # Dart's toIso8601String() -> "2026-09-24T12:00:00.000Z" (millis, no
    # microseconds unless nonzero, in which case it prints microseconds
    # too — e.g. "...000123Z"). We keep this deliberately simple: hub
    # timestamps are millisecond-resolution, so we always emit exactly
    # three fractional digits, which is what Dart emits when microseconds
    # are zero (the common case for a `DateTime.now().toUtc()` captured
    # at millisecond granularity).
    millis = dt_utc.microsecond // 1000
    return dt_utc.strftime("%Y-%m-%dT%H:%M:%S") + f".{millis:03d}Z"


def canonical_payload(
    *,
    hub_id: int,
    member_id: int | None,
    tier: str,
    confidence: float,
    spoof_risk: str,
    transcript_hash: str,
    captured_at: datetime,
) -> str:
    member_json = "null" if member_id is None else str(member_id)
    parts = [
        '{"hubId":' + str(hub_id) + ",",
        '"memberId":' + member_json + ",",
        '"tier":' + json.dumps(tier) + ",",
        '"confidence":' + _format_number(confidence) + ",",
        '"spoofRisk":' + json.dumps(spoof_risk) + ",",
        '"transcriptHash":' + json.dumps(transcript_hash) + ",",
        '"capturedAt":' + json.dumps(_format_datetime(captured_at)),
        "}",
    ]
    return "".join(parts)


def canonical_enrolment_payload(
    *,
    hub_id: int,
    member_id: int,
    embedding_ref: str,
    quality_score: float,
    sample_count: int,
    captured_at: datetime,
) -> str:
    """Must byte-for-byte match `EnrolmentSignature.canonicalPayload` in
    vouch/vouch_server/lib/src/enrolment/enrolment_signature.dart.
    """
    parts = [
        '{"hubId":' + str(hub_id) + ",",
        '"memberId":' + str(member_id) + ",",
        '"embeddingRef":' + json.dumps(embedding_ref) + ",",
        '"qualityScore":' + _format_number(quality_score) + ",",
        '"sampleCount":' + str(sample_count) + ",",
        '"capturedAt":' + json.dumps(_format_datetime(captured_at)),
        "}",
    ]
    return "".join(parts)


def canonical_pairing_payload(*, hub_id: int, captured_at: datetime) -> str:
    """Must byte-for-byte match `PairingSignature.canonicalPayload` in
    vouch/vouch_server/lib/src/pairing/pairing_signature.dart.
    """
    parts = [
        '{"hubId":' + str(hub_id) + ",",
        '"capturedAt":' + json.dumps(_format_datetime(captured_at)),
        "}",
    ]
    return "".join(parts)


@dataclass
class SignedAttestation:
    payload: str
    signature_base64: str
    public_key_base64: str


def sign_payload(payload: str, private_key: Ed25519PrivateKey, public_key_base64: str) -> SignedAttestation:
    signature = private_key.sign(payload.encode("utf-8"))
    return SignedAttestation(
        payload=payload,
        signature_base64=base64.b64encode(signature).decode("ascii"),
        public_key_base64=public_key_base64,
    )
