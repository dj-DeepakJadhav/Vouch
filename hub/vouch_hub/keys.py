"""Ed25519 keypair for signing hub attestations.

The public key must be exported in exactly the format
`AttestationSignature.verify` decodes on the server side
(vouch/vouch_server/lib/src/attestation/attestation_signature.dart):
`base64.decode(publicKeyBase64)` fed straight into
`SimplePublicKey(bytes, type: KeyPairType.ed25519)` — i.e. the raw 32-byte
Ed25519 public key, base64-encoded, no PEM/DER wrapping. Signatures are the
raw 64-byte Ed25519 signature, base64-encoded, the same way.
"""

from __future__ import annotations

import base64
import os
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
    Ed25519PublicKey,
)
from cryptography.hazmat.primitives.serialization import (
    Encoding,
    NoEncryption,
    PrivateFormat,
    PublicFormat,
)

DEFAULT_KEYS_DIR = Path(__file__).resolve().parent.parent / "keys"
PRIVATE_KEY_PATH = DEFAULT_KEYS_DIR / "hub_ed25519.key"
PUBLIC_KEY_PATH = DEFAULT_KEYS_DIR / "hub_ed25519.pub"


def generate_keypair(keys_dir: Path = DEFAULT_KEYS_DIR) -> Ed25519PrivateKey:
    """Generates a new Ed25519 keypair and writes it to `keys_dir`.

    The private key file is written with mode 600 (owner read/write only)
    before any key material touches disk: even if the rest of the box is
    compromised, the private signing key is not world-readable.
    """
    keys_dir.mkdir(parents=True, exist_ok=True)
    private_key = Ed25519PrivateKey.generate()

    private_path = keys_dir / "hub_ed25519.key"
    # Create with restrictive permissions from the start (avoid a window
    # where the file exists world-readable before chmod runs).
    fd = os.open(private_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(
                private_key.private_bytes(
                    Encoding.Raw, PrivateFormat.Raw, NoEncryption()
                )
            )
    finally:
        os.chmod(private_path, 0o600)

    public_path = keys_dir / "hub_ed25519.pub"
    public_path.write_text(public_key_base64(private_key.public_key()) + "\n")

    return private_key


def load_keypair(keys_dir: Path = DEFAULT_KEYS_DIR) -> Ed25519PrivateKey:
    """Loads the private key from `keys_dir`, generating one if absent."""
    private_path = keys_dir / "hub_ed25519.key"
    if not private_path.exists():
        return generate_keypair(keys_dir)
    raw = private_path.read_bytes()
    return Ed25519PrivateKey.from_private_bytes(raw)


def public_key_base64(public_key: Ed25519PublicKey) -> str:
    """Raw 32-byte Ed25519 public key, base64-encoded — the format the
    server's `AttestationSignature.verify` expects for `publicKeyBase64`.
    """
    raw = public_key.public_bytes(Encoding.Raw, PublicFormat.Raw)
    return base64.b64encode(raw).decode("ascii")
