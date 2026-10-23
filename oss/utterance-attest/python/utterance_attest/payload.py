"""Canonical JSON payload construction.

Field order and formatting are fixed by SPEC.md (not derived from dict
insertion order) so both the Python and Dart implementations always
produce byte-identical bytes to sign and verify.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone


def _format_number(value: float) -> str:
    """Formats a float the way Dart's `num` string interpolation does:
    always at least one digit after the decimal point (e.g. `0.95`, `1.0`),
    never a bare integer. Python's `repr` of a genuine float already
    matches this for values in the 0..1 confidence range."""
    return repr(float(value))


def _format_datetime(dt: datetime) -> str:
    """UTC ISO-8601 with exactly three fractional digits and a trailing
    'Z', matching Dart's `DateTime.toUtc().toIso8601String()` for
    millisecond-resolution timestamps."""
    dt_utc = dt.astimezone(timezone.utc) if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
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
    """Builds the canonical, stable-key-order JSON payload that gets signed
    and verified: `{hubId, memberId, tier, confidence, spoofRisk,
    transcriptHash, capturedAt}`. See SPEC.md for the exact byte layout."""
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
