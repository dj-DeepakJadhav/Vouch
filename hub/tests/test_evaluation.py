"""Scoring math for the FAR/FRR/EER eval harness, exercised with fixed fake
cosine scores -- no model load, no audio I/O."""
import numpy as np
import pytest

from vouch_hub.evaluation import collect_trials, eer, far_frr, report_markdown, sweep


def test_far_frr_basic_counts():
    genuine = [0.9, 0.8, 0.5, 0.95]  # one below 0.6 -> 1 false reject
    impostor = [0.1, 0.65, 0.3, 0.7]  # two at/above 0.6 -> 2 false accepts
    r = far_frr(genuine, impostor, threshold=0.6)
    assert r["frr"] == 0.25
    assert r["far"] == 0.5
    assert r["n_genuine"] == 4
    assert r["n_impostor"] == 4


def test_far_frr_empty_lists_are_none_not_zero():
    r = far_frr([], [], threshold=0.6)
    assert r["far"] is None and r["frr"] is None


def test_far_frr_boundary_is_false_accept():
    # score exactly at threshold counts as an accept (>=), matching
    # voiceprint.identify's `scores[best] >= threshold`.
    r = far_frr(genuine=[], impostor=[0.6], threshold=0.6)
    assert r["far"] == 1.0


def test_sweep_returns_one_row_per_threshold():
    rows = sweep([0.9, 0.4], [0.2, 0.8], thresholds=[0.3, 0.6, 0.9])
    assert [r["threshold"] for r in rows] == [0.3, 0.6, 0.9]
    # at 0.9: genuine 0.9>=0.9 not rejected, 0.4<0.9 rejected -> frr 0.5
    # impostor: 0.2,0.8 both <0.9 -> far 0.0
    at_09 = next(r for r in rows if r["threshold"] == 0.9)
    assert at_09["frr"] == 0.5
    assert at_09["far"] == 0.0


def test_eer_finds_crossover_for_separable_scores():
    # genuine clustered high, impostor clustered low -> EER near 0 at the
    # midpoint threshold.
    genuine = [0.9, 0.85, 0.95, 0.88]
    impostor = [0.1, 0.15, 0.05, 0.12]
    r = eer(genuine, impostor)
    assert r["eer"] < 0.05
    assert 0.15 < r["threshold"] < 0.9


def test_eer_is_high_when_distributions_overlap_completely():
    scores = [0.5, 0.5, 0.5, 0.5]
    r = eer(list(scores), list(scores))
    assert r["eer"] == 0.5


def test_eer_none_without_both_classes():
    assert eer([0.9, 0.8], [])["eer"] is None
    assert eer([], [0.1])["eer"] is None


def test_collect_trials_splits_genuine_and_impostor_by_declared_member():
    prints = {
        1: np.array([1.0, 0.0]),
        2: np.array([0.0, 1.0]),
    }
    clips = {
        "alice": [np.array([1.0, 0.0])],   # matches member 1 exactly
        "mallory": [np.array([0.0, 1.0])],  # not enrolled -> impostor vs everyone
    }
    member_of_speaker = {"alice": 1, "mallory": None}
    genuine, impostor = collect_trials(prints, clips, member_of_speaker, embed_fn=lambda x: x)
    # alice vs member 1 -> genuine (score 1.0); alice vs member 2 -> impostor (score 0.0).
    # mallory is unenrolled (own=None), so BOTH of her trials land in impostor,
    # including mallory-vs-2 which happens to score 1.0 -- an unenrolled speaker
    # never contributes a genuine trial no matter how similar the embedding is.
    assert genuine == pytest.approx([1.0])
    assert impostor == pytest.approx([0.0, 0.0, 1.0])


def test_report_markdown_contains_key_numbers():
    at_prod = far_frr([0.9, 0.4], [0.2, 0.8], 0.6)
    eer_result = eer([0.9, 0.4], [0.2, 0.8])
    rows = sweep([0.9, 0.4], [0.2, 0.8], [0.5, 0.6])
    md = report_markdown(0.6, at_prod, eer_result, rows, n_speakers=2)
    assert "FAR=" in md and "FRR=" in md
    assert "EER:" in md
    assert "| 0.50 |" in md and "| 0.60 |" in md
