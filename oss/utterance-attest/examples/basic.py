"""Minimal end-to-end example: sign an attestation for one utterance, then
verify it and check freshness + transcript match, the way an MCP-style
guard would before allowing a tool call.

Run: pip install cryptography && python3 examples/basic.py
"""

from datetime import datetime, timedelta, timezone

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from utterance_attest import (
    canonical_payload,
    is_fresh,
    normalise,
    sign_attestation,
    transcript_hash,
    transcripts_match,
    verify_attestation,
)

# --- On the hub, right after speaker verification decides who spoke ---

private_key = Ed25519PrivateKey.generate()

transcript = normalise("Alexa, send ten dollars to Mom")
tx_hash = transcript_hash(transcript)

payload = canonical_payload(
    hub_id=1,
    member_id=42,
    tier="t1",
    confidence=0.97,
    spoof_risk="low",
    transcript_hash=tx_hash,
    captured_at=datetime.now(timezone.utc),
)

signed = sign_attestation(payload, private_key)

# --- On the MCP server/guard, given the signed attestation plus the text
# the voice agent itself recognised for the same command ---

alexa_recognised_text = "send 10 dollars to mom"

signature_ok = verify_attestation(
    payload=signed.payload,
    signature_base64=signed.signature_base64,
    public_key_base64=signed.public_key_base64,
)
fresh = is_fresh(datetime.now(timezone.utc), max_age=timedelta(seconds=30))
same_utterance = transcripts_match(transcript, alexa_recognised_text)

trusted = signature_ok and fresh and same_utterance

print(f"signature valid: {signature_ok}")
print(f"fresh:           {fresh}")
print(f"same utterance:  {same_utterance}")
print(f"=> allow tool call: {trusted}")

assert trusted, "example should trust this attestation"
