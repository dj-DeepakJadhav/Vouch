"""Anti-spoof (synthetic/replayed speech) scoring — SIGNAL ONLY, NEVER A BOUNDARY.

The anti-spoof classifier is a signal, not a boundary; we do not claim to
detect deepfakes. This module must never be
used to ALLOW anything, and a high score must never RAISE trust. The only
two effects a caller may derive from `spoof_score`:

  (a) record it alongside the attestation so the household owner can see it
      in the audit trail (see README "Anti-spoof signal" and the note below
      about the fixed signed-payload schema);
  (b) optionally CAP the attested tier at T1 when the score looks like a
      likely spoof (`cap_tier`). It may only lower a tier, never raise one.

## Model search (C2, ~30 min budget)

We looked for a small, openly licensed, pretrained anti-spoofing model
(ASVspoof-trained AASIST/RawNet2) that could be loaded without training,
on Hugging Face or as a NeMo checkpoint. Candidates that exist in the
literature (AASIST, RawNet2, the ASVspoof2019/2021 baselines) are
published as research-code checkpoints (e.g. clovaai/aasist on GitHub,
license MIT) but are NOT published as ready-to-`from_pretrained()`
Hugging Face models with pinned weights the way TitaNet/Parakeet are —
using one would mean vendoring third-party training code and a checkpoint
file into this repo, which is more than "load once, keep resident" and
did not fit the time budget honestly. No suitable turnkey model was found
in the ~30 minute window.

Per the task's own fallback: this ships a **pluggable scorer interface**
with a clearly labelled `NullScorer` as the default, so the wiring
(config, signing-adjacent recording, tier cap, tests) is real and ready
to receive a genuine model later — only `spoof.py`'s `build_scorer()|`
would need to change.
"""
from __future__ import annotations

import time
from dataclasses import dataclass
from typing import Protocol

import numpy as np


class SpoofScorer(Protocol):
    """A scorer maps one trimmed utterance waveform to a score in [0, 1],
    higher = more likely spoofed (synthetic or replayed), plus a name
    recorded alongside the score so the audit trail always shows which
    (if any) model produced it."""

    name: str

    def score(self, x: np.ndarray) -> float: ...


@dataclass
class NullScorer:
    """Explicitly NOT an anti-spoof detector. No pretrained model is
    wired up (see module docstring). Always returns 0.0 ("no evidence of
    spoofing") so it can never cause a tier cap by itself — it exists so
    the rest of the pipeline (config, recording, capping, tests) can be
    built and exercised honestly ahead of a real model landing here.
    """

    name: str = "null-v0-not-a-detector"

    def score(self, x: np.ndarray) -> float:
        return 0.0


def build_scorer(name: str = "null") -> SpoofScorer:
    if name == "null":
        return NullScorer()
    raise ValueError(f"unknown spoof scorer {name!r}")


def timed_score(scorer: SpoofScorer, x: np.ndarray) -> tuple[float, float]:
    """Returns (score, elapsed_ms)."""
    t0 = time.perf_counter()
    s = float(scorer.score(x))
    return max(0.0, min(1.0, s)), round((time.perf_counter() - t0) * 1000, 2)


# Signed-payload `spoofRisk` is a fixed 3-value enum (low/medium/high —
# vouch/vouch_server/lib/src/enums/spoof_risk.spy.yaml), not a float. We
# still map our continuous score onto it so *something* reaches the
# existing signed field; the raw float is additionally recorded locally
# (see cli.py) since the signed schema has no numeric slot for it.
def score_to_risk(score: float, medium: float, high: float) -> str:
    if score >= high:
        return "high"
    if score >= medium:
        return "medium"
    return "low"


TIER_ORDER = ["t0", "t1", "t2"]


def cap_tier(tier: str, score: float, cap_threshold: float, cap_enabled: bool) -> str:
    """Never raises trust. When `cap_enabled` and `score` looks like a
    likely spoof (>= cap_threshold), caps the tier at T1. Leaves
    everything else — including T0 — untouched, and is a no-op unless
    explicitly enabled."""
    if not cap_enabled or score < cap_threshold:
        return tier
    if tier not in TIER_ORDER:
        return tier
    capped_index = min(TIER_ORDER.index(tier), TIER_ORDER.index("t1"))
    return TIER_ORDER[capped_index]
