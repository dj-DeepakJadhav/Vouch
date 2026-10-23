"""Verify a signed utterance for one command and an explicitly trusted hub."""
from __future__ import annotations

import base64
from datetime import datetime, timedelta
import json
import math
import re

from .attest import is_fresh, verify_attestation
from .normalise import normalise, transcript_hash
from .payload import canonical_payload


def verify_for_command(*, payload: str, signature_base64: str,
                       trusted_public_key_base64: str, command: str,
                       expected_hub_id: int, expected_member_id: int | None,
                       max_age: timedelta, now: datetime | None = None) -> bool:
    """Check signature, canonical schema, expected identity, signed age, and
    exact normalised command hash together. The trusted public key must come
    from the caller's enrolment store, not an untrusted envelope. This does
    not grant permissions or consume an attestation; callers still enforce
    policy and maintain single-use state atomically.
    """
    if not isinstance(payload, str) or len(payload) > 8192:
        return False
    if not isinstance(command, str) or len(command) > 4096:
        return False
    if not isinstance(max_age, timedelta) or max_age < timedelta(0):
        return False
    if now is not None and not isinstance(now, datetime):
        return False
    if type(expected_hub_id) is not int or expected_hub_id < 1:
        return False
    if expected_member_id is not None and (type(expected_member_id) is not int or expected_member_id < 1):
        return False
    try:
        for encoded, size in [(signature_base64, 64), (trusted_public_key_base64, 32)]:
            if not isinstance(encoded, str) or len(encoded) > 128:
                return False
            decoded = base64.b64decode(encoded, validate=True)
            if len(decoded) != size or base64.b64encode(decoded).decode() != encoded:
                return False
        if not verify_attestation(payload=payload, signature_base64=signature_base64,
                                  public_key_base64=trusted_public_key_base64):
            return False
        fields = json.loads(payload)
        required = {"hubId", "memberId", "tier", "confidence", "spoofRisk", "transcriptHash", "capturedAt"}
        if not isinstance(fields, dict) or set(fields) != required:
            return False
        if type(fields["hubId"]) is not int or fields["hubId"] != expected_hub_id:
            return False
        member = fields["memberId"]
        if member is not None and type(member) is not int:
            return False
        if member != expected_member_id:
            return False
        confidence = fields["confidence"]
        if type(confidence) not in (int, float) or not math.isfinite(confidence) or not 0 <= confidence <= 1:
            return False
        if not all(isinstance(fields[k], str) for k in ["tier", "spoofRisk", "transcriptHash", "capturedAt"]):
            return False
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z", fields["capturedAt"]):
            return False
        captured = datetime.fromisoformat(fields["capturedAt"].replace("Z", "+00:00"))
        canonical = canonical_payload(hub_id=fields["hubId"], member_id=member, tier=fields["tier"],
            confidence=confidence, spoof_risk=fields["spoofRisk"],
            transcript_hash=fields["transcriptHash"], captured_at=captured)
        if canonical != payload or not is_fresh(captured, max_age=max_age, now=now):
            return False
        text = normalise(command)
        return bool(text) and transcript_hash(text) == fields["transcriptHash"]
    except (ValueError, TypeError, KeyError, OverflowError):
        return False
