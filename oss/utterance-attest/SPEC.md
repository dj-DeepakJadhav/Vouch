# Vouch Attest wire format (v0.1.0)

The Dart and Python implementations use this wire format and the shared vectors in `vectors/`. A signature covers the canonical payload bytes, so field order and formatting must agree across languages.

## 1. Canonical payload

A payload is a JSON object with exactly these seven fields, **in this
exact order**, with **no extra whitespace**:

```
{"hubId":<int>,"memberId":<int|null>,"tier":"<string>","confidence":<number>,"spoofRisk":"<string>","transcriptHash":"<string>","capturedAt":"<string>"}
```

| Field | Type | Notes |
|---|---|---|
| `hubId` | integer | Identifies the signing hub. Written as a bare integer literal. |
| `memberId` | integer or `null` | The recognised household member, or `null` if unresolved. Written as a bare literal (`null`, not `"null"`). |
| `tier` | string | The trust tier associated with this attestation (e.g. `"t0"`, `"t1"`, `"t2"`). Opaque to this library — callers define the tier vocabulary. |
| `confidence` | number | Speaker-verification confidence, `0.0`–`1.0`. **Must serialize as a genuine floating-point literal** — `0.97`, `1.0` — never a bare integer (`1`). See §1.1. |
| `spoofRisk` | string | Anti-spoof signal (e.g. `"low"`, `"medium"`, `"high"`). Opaque to this library. |
| `transcriptHash` | string | SHA-256 hex digest (64 lowercase hex chars) of the **normalised** transcript — see §2. |
| `capturedAt` | string | UTC timestamp, ISO-8601, millisecond precision, always ending in `Z` — see §1.2. |

Field order is fixed by this document, not by a language's map/dict
insertion order. Both implementations hard-code it.

### 1.1 Number formatting

`confidence` must always include a decimal point and at least one
fractional digit, matching Dart's `num` string interpolation
(`$confidence` on a `double` never prints a bare integer). Python's
`repr(float(value))` already matches this for values in `[0, 1]`.

Wrong: `"confidence":1,` — right: `"confidence":1.0,`

### 1.2 Timestamp formatting

`capturedAt` is UTC, ISO-8601, with exactly three fractional-second
digits and a literal `Z` suffix (never `+00:00`):

```
2026-09-24T12:00:00.000Z
```

This matches Dart's `DateTime.toUtc().toIso8601String()` for
millisecond-resolution timestamps.

### 1.3 String escaping

`tier`, `spoofRisk`, `transcriptHash` and `capturedAt` are JSON-string
literals produced by each language's standard JSON string encoder
(`jsonEncode` in Dart, `json.dumps` in Python). Both quote and escape
identically for the ASCII content this spec's fields ever contain.

## 2. Transcript normalisation

Given raw transcript text, `normalise(text)`:

1. Lowercases the text.
2. Strips punctuation: replaces every character that is not an ASCII
   word character (`[a-zA-Z0-9_]`) or whitespace with a space. This is
   **ASCII-only** — accented and non-Latin letters are stripped, not
   preserved (`"café"` → `"caf"`).
3. Splits on runs of whitespace, dropping empty tokens.
4. If the **first** token is a recognised wake word
   (`alexa`, `echo`, `computer`, `amazon`), drops it.
5. Collapses number words into digit-string tokens (§2.1).
6. Joins the remaining tokens with a single space and trims.

`transcript_hash(normalised_text)` is the SHA-256 hex digest (lowercase)
of the normalised text, UTF-8 encoded.

### 2.1 Number-word collapsing

Walk the token list left to right. Whenever a token is a recognised
number word, greedily consume a run of number words and fold them into
a single value using standard English number-naming rules:

- **Units** (`zero`…`twenty`) contribute their value directly.
- **Tens** (`twenty`, `thirty`, …, `ninety`) contribute their value;
  a following unit is added on top (`twenty` + `two` → `22`).
- **Scales** (`hundred` = 100, `thousand` = 1000) multiply the
  accumulated value so far (defaulting to `1` if nothing preceded the
  scale word) — `hundred` multiplies into the running total, `thousand`
  flushes the running total into the final value and resets it (so
  `"two thousand five hundred"` → `2500`).

The run replaces its input tokens with one token: the resulting
integer, printed as a plain decimal string (no leading zeros, no
commas).

Non-number tokens pass through unchanged.

## 3. Matching rule

The lower-level fuzzy matcher accepts transcripts `a` and `b` when,
after independently normalising both:

1. `token_set_similarity(normalise(a), normalise(b)) >= 0.90`, **AND**
2. the multiset of numeric tokens (tokens matching `^\d+$`) extracted
   from each normalised string is identical — same digit strings, same
   count of each, order-independent.

Both conditions are required. Numeric-token comparison rejects `send 10 dollars` against `send 1000 dollars`. It does not validate the action's meaning: normalisation removes punctuation, and token-set matching loses word order. Applications must validate structured amounts and actions independently. The combined verifier in section 7 uses exact normalised hash equality instead of this fuzzy matcher.

### 3.1 Token-set similarity

Modelled on rapidfuzz's `token_set_ratio`:

1. Tokenise both (already-normalised, space-joined) strings by
   splitting on spaces into sets (each token counted once).
2. Compute `intersection`, `remainderA = tokensA - tokensB`,
   `remainderB = tokensB - tokensA`.
3. Build three space-joined, alphabetically-sorted strings:
   `sortedIntersection`, `combinedA = sort(intersection ∪ remainderA)`,
   `combinedB = sort(intersection ∪ remainderB)`.
4. Score = the **maximum** Levenshtein ratio among:
   `(sortedIntersection, combinedA)`,
   `(sortedIntersection, combinedB)`,
   `(combinedA, combinedB)`.
5. Levenshtein ratio of two strings = `1 - editDistance / max(len(a), len(b))`
   (both empty ⇒ `1.0`).

Empty-vs-empty token sets score `1.0`; empty-vs-nonempty scores `0.0`.

## 4. Signature

- Algorithm: **Ed25519** over the raw UTF-8 bytes of the canonical
  payload string (§1) — no additional hashing, no domain separation
  prefix.
- Keys: raw 32-byte Ed25519 keys (seed for private, public point for
  public), base64-standard-encoded for transport/storage.
- `sign(payload, privateKey) -> signatureBase64`
- `verify(payload, signatureBase64, publicKeyBase64) -> bool` — **must
  never throw** on malformed input (bad base64, wrong length, wrong
  key type); it returns `false` instead. This sits on an accept/reject
  security decision and callers must not need a try/catch to use it
  safely.

## 5. Freshness

A verified signature only proves *who signed the payload* and *that
it has not been altered* — not that it is still current. Callers must
separately check:

```
is_fresh(capturedAt, maxAge, now=now()) ->
    capturedAt <= now AND (now - capturedAt) <= maxAge
```

A future `capturedAt` fails freshness validation. Callers must synchronise signer and verifier clocks.

Single-use enforcement (never accepting the same attestation twice) is
**out of scope** for this library — that requires shared state the
caller owns (e.g. a replay cache keyed by signature or transcript
hash), not something a stateless sign/verify library can provide.

## 6. Test vectors

`vectors/normalise.json`, `vectors/matching.json` and
`vectors/signed_payload.json` are the executable ground truth. Both
`dart/test/vectors_test.dart` and `python/tests/test_*.py` load these
files directly (not copies) and assert against them, including a
cross-language check: `vectors/signed_payload.json` carries a fixed
Ed25519 test private key, and each implementation's test suite signs
the exact same canonical payload with that key and asserts its output
equals the vector's `signatureBase64` byte-for-byte. This checks that both implementations produce the same signature for the vector payload.

**This is a test-only key** (`vectors/signed_payload.json`,
`private_key_base64`). Never use it outside these test suites.

## 7. Combined command verification

`verify_for_command` (Python) and `Verification.verifyForCommand` (Dart) take a trusted public key, expected hub and member, recognised command, freshness window and optional clock value. The trusted key must come from an enrolled record outside the incoming envelope.

The helper accepts only when all checks pass:

1. Inputs fit the payload and command length limits of 8192 and 4096 characters, and the freshness window is nonnegative.
2. Key and signature are canonical standard base64 with decoded lengths of 32 and 64 bytes.
3. The signature verifies over the supplied payload.
4. The payload has exactly the canonical seven fields, valid field types, finite confidence in [0, 1], and a valid UTC timestamp with three fractional digits. Rebuilding the canonical payload must reproduce the original bytes.
5. Hub and member equal the caller's expected identities. The expected hub and any non-null expected member must be positive integers.
6. The timestamp inside the signed payload passes the freshness rule in section 5.
7. The recognised command normalises to nonempty text, and its hash equals the signed transcript hash.

Malformed inputs return false. The helper does not use fuzzy transcript matching. Shared cases are in `vectors/verify_command.json`.

Success grants no permission and records no consumption. Applications enforce policy and atomic replay protection separately. Normalisation strips punctuation and non-ASCII letters; applications must validate structured action parameters independently.
