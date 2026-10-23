# Changelog

## 0.1.0

- Canonical JSON payload (`hubId`, `memberId`, `tier`, `confidence`,
  `spoofRisk`, `transcriptHash`, `capturedAt`) with a fixed field order and
  byte-exact number/timestamp formatting, specified in `SPEC.md`.
- Ed25519 sign/verify over the canonical payload, in `dart/` (uses
  `package:cryptography` + `package:crypto`) and `python/` (uses
  `cryptography`).
- Transcript normalisation: lowercasing, ASCII-only punctuation stripping,
  leading wake-word removal, English number-word → digit collapsing.
- Transcript matching rule: token-set similarity ≥ 0.90 AND identical
  numeric-token multisets, to reject different numeric-token multisets. Applications still validate structured amounts.
- Freshness-window check (`is_fresh` / `isFresh`).
- Shared cross-language test vectors in `vectors/`, including a
  fixed-key signed payload both implementations sign and verify
  against to prove byte-exact interoperability.

- Combined command verification checks canonical payloads, enrolled identities, signed timestamps and exact normalised command hashes.
