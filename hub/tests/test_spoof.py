"""Anti-spoof signal tests: a fake scorer never allows anything, is always
recorded, and can only lower (never raise) the attested tier."""
import numpy as np
import pytest

from vouch_hub import spoof


class FakeScorer:
    """Deterministic stand-in for a real anti-spoof model."""
    def __init__(self, value: float, name: str = "fake-v1"):
        self.value = value
        self.name = name

    def score(self, x: np.ndarray) -> float:
        return self.value


def test_null_scorer_is_clearly_labelled_and_inert():
    s = spoof.NullScorer()
    assert "not-a-detector" in s.name
    assert s.score(np.zeros(16000, dtype=np.float32)) == 0.0


def test_timed_score_clamps_and_times():
    score, ms = spoof.timed_score(FakeScorer(1.5), np.zeros(16000, dtype=np.float32))
    assert score == 1.0  # clamped
    assert ms >= 0.0
    score, _ = spoof.timed_score(FakeScorer(-0.5), np.zeros(16000, dtype=np.float32))
    assert score == 0.0


@pytest.mark.parametrize("score,medium,high,expected", [
    (0.1, 0.4, 0.75, "low"),
    (0.5, 0.4, 0.75, "medium"),
    (0.9, 0.4, 0.75, "high"),
    (0.4, 0.4, 0.75, "medium"),  # boundary is inclusive on the upper side
    (0.75, 0.4, 0.75, "high"),
])
def test_score_to_risk_thresholds(score, medium, high, expected):
    assert spoof.score_to_risk(score, medium, high) == expected


def test_cap_tier_disabled_is_a_noop_even_at_max_score():
    # The load-bearing property: with the cap disabled (the default),
    # a maximal spoof score changes nothing about the tier.
    assert spoof.cap_tier("t1", 1.0, 0.75, cap_enabled=False) == "t1"


def test_cap_tier_only_lowers_never_raises():
    # t1 capped at t1 threshold with a low score: untouched.
    assert spoof.cap_tier("t1", 0.1, 0.75, cap_enabled=True) == "t1"
    # t1 with a high score capped at t1: still t1 (cap floor == current tier).
    assert spoof.cap_tier("t1", 0.9, 0.75, cap_enabled=True) == "t1"
    # t0 (already below t1) with a high score: cap_tier takes min(), so it
    # stays at t0 — capping can never raise t0 up to t1.
    assert spoof.cap_tier("t0", 0.9, 0.75, cap_enabled=True) == "t0"


def test_cap_tier_never_produces_a_tier_above_input():
    for tier in spoof.TIER_ORDER:
        for score in (0.0, 0.5, 0.75, 1.0):
            for enabled in (True, False):
                capped = spoof.cap_tier(tier, score, 0.75, enabled)
                assert spoof.TIER_ORDER.index(capped) <= spoof.TIER_ORDER.index(tier)


def test_build_scorer_default_is_null():
    s = spoof.build_scorer("null")
    assert isinstance(s, spoof.NullScorer)


def test_build_scorer_rejects_unknown_name():
    with pytest.raises(ValueError):
        spoof.build_scorer("definitely-not-a-real-scorer")
