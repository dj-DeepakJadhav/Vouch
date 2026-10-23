"""Fuzzy transcript matching: token-set similarity plus an exact-numeric-token
guard, so "send 10" can never be matched against "send 1000".

Always uses the pure-Python implementation of SPEC.md section 3.1. rapidfuzz's
`token_set_ratio` is NOT used: it scores subset token sets as 1.0 and empty-vs-
empty as 0.0, which disagrees with the spec and the Dart implementation
(caught by the shared vectors).
"""

from __future__ import annotations

import re

from .normalise import normalise

SIMILARITY_THRESHOLD = 0.90

_NUMERIC_RE = re.compile(r"^\d+$")


def _levenshtein_distance(a: str, b: str) -> int:
    m, n = len(a), len(b)
    if m == 0:
        return n
    if n == 0:
        return m

    previous = list(range(n + 1))
    current = [0] * (n + 1)

    for i in range(1, m + 1):
        current[0] = i
        for j in range(1, n + 1):
            cost = 0 if a[i - 1] == b[j - 1] else 1
            current[j] = min(
                current[j - 1] + 1,
                previous[j] + 1,
                previous[j - 1] + cost,
            )
        previous, current = current, previous
    return previous[n]


def _levenshtein_ratio(a: str, b: str) -> float:
    if not a and not b:
        return 1.0
    distance = _levenshtein_distance(a, b)
    max_len = max(len(a), len(b))
    if max_len == 0:
        return 1.0
    return 1.0 - (distance / max_len)


def _pure_python_token_set_ratio(a: str, b: str) -> float:
    tokens_a = {t for t in a.split(" ") if t}
    tokens_b = {t for t in b.split(" ") if t}

    if not tokens_a and not tokens_b:
        return 1.0
    if not tokens_a or not tokens_b:
        return 0.0

    intersection = tokens_a & tokens_b
    remainder_a = tokens_a - tokens_b
    remainder_b = tokens_b - tokens_a

    sorted_intersection = " ".join(sorted(intersection))
    combined_a = " ".join(sorted(intersection | remainder_a))
    combined_b = " ".join(sorted(intersection | remainder_b))

    return max(
        _levenshtein_ratio(sorted_intersection, combined_a),
        _levenshtein_ratio(sorted_intersection, combined_b),
        _levenshtein_ratio(combined_a, combined_b),
    )


def token_set_similarity(a: str, b: str) -> float:
    """Token-set similarity in [0, 1] between two already-normalised
    transcripts, modelled on rapidfuzz's `token_set_ratio`."""
    return _pure_python_token_set_ratio(a, b)


def _numeric_tokens(normalised_text: str) -> list[str]:
    return [t for t in normalised_text.split(" ") if t and _NUMERIC_RE.match(t)]


def _same_number_multiset(a: list[str], b: list[str]) -> bool:
    return sorted(a) == sorted(b)


def transcripts_match(hub_transcript: str, other_text: str) -> bool:
    """True iff `hub_transcript` and `other_text` describe the same
    utterance: token-set similarity >= SIMILARITY_THRESHOLD AND the
    multiset of numeric tokens is identical in both, after normalisation."""
    norm_a = normalise(hub_transcript)
    norm_b = normalise(other_text)

    if token_set_similarity(norm_a, norm_b) < SIMILARITY_THRESHOLD:
        return False

    return _same_number_multiset(_numeric_tokens(norm_a), _numeric_tokens(norm_b))
