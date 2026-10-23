"""Python port of `TranscriptMatcher.normalise` / `.hash` from
vouch/vouch_server/lib/src/attestation/transcript_matcher.dart.

Kept line-for-line comparable to the Dart source so the two can be
eyeballed side by side; ported EXACTLY, not "equivalently" — e.g. the
same wake-word set, the same number-word collapsing algorithm including
its hundred/thousand scale handling, and the same punctuation-stripping
regex (`[^\\w\\s]` with unicode word chars).
"""

from __future__ import annotations

import hashlib
import re

_WAKE_WORDS = {"alexa", "echo", "computer", "amazon"}

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

# Dart's RegExp(r'[^\w\s]', unicode: true): the `unicode` flag changes how
# character CLASSES are interpreted (e.g. code-point vs UTF-16 code-unit
# matching for surrogate pairs), but \w itself is still ASCII-only
# ([a-zA-Z0-9_]) — it does NOT extend to accented/other-language letters.
# Confirmed empirically: "café" -> "caf" on the Dart side (the "é" is
# treated as punctuation and stripped, not kept). Python's \w with
# re.UNICODE (the Py3 default) is NOT ASCII-only and would keep "café"
# whole, which mismatches Dart's behaviour, so we use an explicit
# ASCII-only class here.
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
    lower = text.lower()
    lower = _PUNCT_RE.sub(" ", lower)
    tokens = [t for t in _WS_RE.split(lower) if t]

    if tokens and tokens[0] in _WAKE_WORDS:
        tokens = tokens[1:]

    tokens = _collapse_number_words(tokens)

    return " ".join(tokens).strip()


def transcript_hash(normalised_text: str) -> str:
    return hashlib.sha256(normalised_text.encode("utf-8")).hexdigest()
