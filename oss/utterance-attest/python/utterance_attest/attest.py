"""Ed25519 signing and verification of canonical attestation payloads, plus
a freshness-window helper.

Keys are always raw 32-byte Ed25519 keys, base64-encoded. Callers own key
storage and rotation; this module only signs and verifies bytes.
"""

from __future__ import annotations

import base64
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
    Ed25519PublicKey,
)


@dataclass
class SignedAttestation:
    payload: str
    signature_base64: str
    public_key_base64: str


def sign_attestation(payload: str, private_key: Ed25519PrivateKey) -> SignedAttestation:
    """Signs `payload` (as produced by `canonical_payload`) with
    `private_key` and returns the payload plus base64 signature and public
    key, ready to hand to a verifier."""
    signature = private_key.sign(payload.encode("utf-8"))
    public_key = private_key.public_key()
    public_bytes = public_key.public_bytes_raw()
    return SignedAttestation(
        payload=payload,
        signature_base64=base64.b64encode(signature).decode("ascii"),
        public_key_base64=base64.b64encode(public_bytes).decode("ascii"),
    )


def verify_attestation(
    *,
    payload: str,
    signature_base64: str,
    public_key_base64: str,
) -> bool:
    """Verifies `signature_base64` over `payload` against
    `public_key_base64`. Returns False for any malformed input or invalid
    signature rather than raising — this sits on an accept/reject security
    path and must never leak a parse error as an uncaught exception."""
    try:
        public_key = Ed25519PublicKey.from_public_bytes(
            base64.b64decode(public_key_base64)
        )
        signature = base64.b64decode(signature_base64)
        public_key.verify(signature, payload.encode("utf-8"))
        return True
    except (InvalidSignature, ValueError, TypeError):
        return False


def is_fresh(captured_at: datetime, *, max_age: timedelta, now: datetime | None = None) -> bool:
    """True iff `captured_at` is within `max_age` of `now` (default: the
    current UTC time) and not in the future. Freshness is the caller's
    responsibility to check on every use — a valid signature only proves
    who signed the payload and that it has not been altered, not that it
    is still current."""
    reference = now.astimezone(timezone.utc) if now and now.tzinfo else (
        now.replace(tzinfo=timezone.utc) if now else datetime.now(timezone.utc)
    )
    captured = (
        captured_at.astimezone(timezone.utc)
        if captured_at.tzinfo
        else captured_at.replace(tzinfo=timezone.utc)
    )
    if captured > reference:
        return False
    return (reference - captured) <= max_age
