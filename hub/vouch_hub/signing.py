"""Hub-side signing glue over the verified C1a modules (keys, payload, normalise)."""
from datetime import datetime, timezone
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
import base64

from . import keys, payload
from .normalise import transcript_hash

KEY_DIR = keys.DEFAULT_KEYS_DIR


def keygen(key_dir: Path = KEY_DIR, force: bool = False) -> str:
    if (key_dir / "hub_ed25519.key").exists() and not force:
        raise SystemExit(f"{key_dir/'hub_ed25519.key'} exists (use --force to overwrite)")
    return keys.public_key_base64(keys.generate_keypair(key_dir).public_key())


def load_private(key_dir: Path = KEY_DIR):
    return keys.load_keypair(key_dir)


def public_key_b64(sk) -> str:
    return keys.public_key_base64(sk.public_key())


def now_ms() -> datetime:
    n = datetime.now(timezone.utc)
    return n.replace(microsecond=(n.microsecond // 1000) * 1000)


def iso_utc(dt: datetime) -> str:
    return payload._format_datetime(dt)


def sign_attestation(sk, *, hub_id, member_id, tier, confidence, spoof_risk,
                     transcript_normalised, captured_at) -> tuple[str, str]:
    if not 1e-4 <= confidence <= 1.0:
        raise ValueError("confidence outside the range where Python repr == Dart toString")
    p = payload.canonical_payload(hub_id=hub_id, member_id=member_id, tier=tier,
                                  confidence=confidence, spoof_risk=spoof_risk,
                                  transcript_hash=transcript_hash(transcript_normalised),
                                  captured_at=captured_at)
    s = payload.sign_payload(p, sk, public_key_b64(sk))
    return p, s.signature_base64


def sign_enrolment(sk, *, hub_id, member_id, embedding_ref, quality_score,
                    sample_count, captured_at) -> tuple[str, str]:
    p = payload.canonical_enrolment_payload(
        hub_id=hub_id, member_id=member_id, embedding_ref=embedding_ref,
        quality_score=quality_score, sample_count=sample_count, captured_at=captured_at)
    s = payload.sign_payload(p, sk, public_key_b64(sk))
    return p, s.signature_base64


def sign_pairing(sk, *, hub_id, captured_at) -> tuple[str, str]:
    p = payload.canonical_pairing_payload(hub_id=hub_id, captured_at=captured_at)
    s = payload.sign_payload(p, sk, public_key_b64(sk))
    return p, s.signature_base64


def verify(pub_b64: str, p: str, sig_b64: str) -> bool:
    try:
        Ed25519PublicKey.from_public_bytes(base64.b64decode(pub_b64)).verify(
            base64.b64decode(sig_b64), p.encode("utf-8"))
        return True
    except Exception:
        return False
