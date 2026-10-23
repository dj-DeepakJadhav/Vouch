"""Transcript normalisation: lowercase, strip punctuation, strip a leading
wake word, collapse number words into digit tokens, collapse whitespace.

See SPEC.md at the repository root for the exact rules. This must stay
byte-for-byte equivalent to the Dart implementation in
`dart/lib/src/normalise.dart` — both are tested against the shared vectors
in `vectors/normalise.json`.
"""

from __future__ import annotations

import hashlib
import re

WAKE_WORDS = {"alexa", "echo", "computer", "amazon"}

_UNITS = {
    "zero": 0,
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
    "ten": 10,
    "eleven": 11,
    "twelve": 12,
    "thirteen": 13,
    "fourteen": 14,
    "fifteen": 15,
    "sixteen": 16,
    "seventeen": 17,
    "eighteen": 18,
    "nineteen": 19,
    "twenty": 20,
}

_TENS = {
    "twenty": 20,
    "thirty": 30,
    "forty": 40,
    "fifty": 50,
    "sixty": 60,
    "seventy": 70,
    "eighty": 80,
    "ninety": 90,
}

_SCALES = {"hundred": 100, "thousand": 1000}

# Dart's `RegExp(r'[^\w\s]', unicode: true)` keeps `\w` ASCII-only
# ([a-zA-Z0-9_]) even with the unicode flag set (that flag only changes how
# character classes handle surrogate pairs, not which characters `\w`
# matches). Python's `\w` under the default `re.UNICODE` behaviour is NOT
# ASCII-only, so we spell the class out explicitly to keep both languages
# byte-for-byte identical (e.g. "café" -> "caf", not "café").
_PUNCT_RE = re.compile(r"[^a-zA-Z0-9_\s]")
_WS_RE = re.compile(r"\s+")


def _collapse_number_words(tokens: list[str]) -> list[str]:
    result: list[str] = []
    i = 0
    n = len(tokens)
    while i < n:
        token = tokens[i]
        if token in _UNITS or token in _TENS or token in _SCALES:
            value = 0
            current = 0
            consumed_any = False
            while i < n:
                t = tokens[i]
                if t in _UNITS and t not in _TENS:
                    current += _UNITS[t]
                    i += 1
                    consumed_any = True
                elif t in _TENS:
                    current += _TENS[t]
                    i += 1
                    consumed_any = True
                elif t in _SCALES:
                    scale = _SCALES[t]
                    if current == 0:
                        current = 1
                    if scale >= 1000:
                        value += current * scale
                        current = 0
                    else:
                        current *= scale
                    i += 1
                    consumed_any = True
                else:
                    break
            if consumed_any:
                value += current
                result.append(str(value))
                continue
        result.append(token)
        i += 1
    return result


def normalise(text: str) -> str:
    """Lowercases, strips punctuation, strips a leading wake word, converts
    number words to digits, and collapses whitespace."""
    lower = text.lower()
    lower = _PUNCT_RE.sub(" ", lower)
    tokens = [t for t in _WS_RE.split(lower) if t]

    if tokens and tokens[0] in WAKE_WORDS:
        tokens = tokens[1:]

    tokens = _collapse_number_words(tokens)

    return " ".join(tokens).strip()


def transcript_hash(normalised_text: str) -> str:
    """SHA-256 hex digest of an already-normalised transcript."""
    return hashlib.sha256(normalised_text.encode("utf-8")).hexdigest()
