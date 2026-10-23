"""utterance-attest: sign and verify short-lived, single-utterance speaker
attestations for voice agents.

See the package README and the top-level SPEC.md for the wire format.
"""

from .normalise import normalise, transcript_hash
from .matching import token_set_similarity, transcripts_match
from .payload import canonical_payload
from .attest import sign_attestation, verify_attestation, is_fresh, SignedAttestation
from .verification import verify_for_command

__all__ = [
    "normalise",
    "transcript_hash",
    "token_set_similarity",
    "transcripts_match",
    "canonical_payload",
    "sign_attestation",
    "verify_attestation",
    "is_fresh",
    "SignedAttestation",
    "verify_for_command",
]

__version__ = "0.1.0"
