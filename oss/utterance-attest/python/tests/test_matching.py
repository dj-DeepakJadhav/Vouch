import math

from utterance_attest.matching import token_set_similarity, transcripts_match
from utterance_attest.normalise import normalise


def test_vectors(matching_vectors):
    for case in matching_vectors:
        sim = token_set_similarity(normalise(case["a"]), normalise(case["b"]))
        assert math.isclose(sim, case["similarity"], abs_tol=1e-9), case
        assert transcripts_match(case["a"], case["b"]) is case["match"], case


def test_numeric_guard_blocks_amount_substitution():
    # High word overlap, but "10" vs "1000" must never match.
    assert not transcripts_match("send 10 dollars", "send 1000 dollars")


def test_identical_transcripts_match():
    assert transcripts_match("send 10 dollars to mom", "send 10 dollars to mom")


def test_empty_transcripts_match():
    assert transcripts_match("", "")
