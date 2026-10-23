"""FAR/FRR/EER measurement for the speaker-verification threshold. Pure
scoring math here is deliberately free of NeMo/model imports so it can be
unit-tested with fake cosine scores; `run_eval` is the only part that loads
TitaNet and walks WAV files.

Trial convention: a genuine trial compares an eval clip against the
voiceprint of the SAME enrolled member (their own centroid). An impostor
trial compares a clip against every OTHER enrolled member's voiceprint,
including clips from speakers who are not enrolled at all (unknown
folders under the eval dir) -- those are impostors against every member.
"""
import json
from pathlib import Path

import numpy as np

from .config import DATA_DIR

EVAL_DIR = DATA_DIR / "eval"


def far_frr(genuine: list[float], impostor: list[float], threshold: float) -> dict:
    """False accept/reject rates at a single threshold. A genuine trial
    scoring below `threshold` is a false reject; an impostor trial scoring
    at/above `threshold` is a false accept."""
    frr = (sum(1 for s in genuine if s < threshold) / len(genuine)) if genuine else None
    far = (sum(1 for s in impostor if s >= threshold) / len(impostor)) if impostor else None
    return {"threshold": threshold, "far": far, "frr": frr,
            "n_genuine": len(genuine), "n_impostor": len(impostor)}


def sweep(genuine: list[float], impostor: list[float], thresholds: list[float]) -> list[dict]:
    return [far_frr(genuine, impostor, t) for t in thresholds]


def eer(genuine: list[float], impostor: list[float], steps: int = 1000) -> dict:
    """Equal error rate: the threshold where FAR and FRR are closest,
    found by a linear sweep over the observed score range."""
    scores = genuine + impostor
    if not scores or not genuine or not impostor:
        return {"eer": None, "threshold": None}
    lo, hi = min(scores), max(scores)
    best = None
    for i in range(steps + 1):
        t = lo + (hi - lo) * i / steps
        r = far_frr(genuine, impostor, t)
        gap = abs(r["far"] - r["frr"])
        if best is None or gap < best[0]:
            best = (gap, t, (r["far"] + r["frr"]) / 2)
    return {"eer": round(best[2], 4), "threshold": round(best[1], 4)}


def collect_trials(prints: dict[int, np.ndarray], clips: dict[str, list[np.ndarray]],
                    member_of_speaker: dict[str, int | None], embed_fn) -> tuple[list[float], list[float]]:
    """`clips`: speaker-name -> list of waveforms (already trimmed).
    `member_of_speaker`: speaker-name -> enrolled member id, or None if the
    speaker isn't enrolled (unknown -> impostor against everyone).
    `embed_fn`: callable waveform -> embedding (injected so tests never load
    a model)."""
    genuine, impostor = [], []
    for speaker, waves in clips.items():
        own = member_of_speaker.get(speaker)
        for x in waves:
            emb = embed_fn(x)
            e = emb / (np.linalg.norm(emb) + 1e-12)
            for mid, c in prints.items():
                s = float(np.dot(e, c))
                if mid == own:
                    genuine.append(s)
                else:
                    impostor.append(s)
    return genuine, impostor


def report_markdown(prod_threshold: float, at_prod: dict, eer_result: dict,
                     sweep_result: list[dict], n_speakers: int) -> str:
    lines = [
        "# Speaker verification accuracy",
        "",
        f"Speakers in eval set: {n_speakers}. "
        f"Genuine trials: {at_prod['n_genuine']}. Impostor trials: {at_prod['n_impostor']}.",
        "",
        f"**At production threshold {prod_threshold}:** "
        f"FAR={_pct(at_prod['far'])} FRR={_pct(at_prod['frr'])}",
        "",
        f"**EER:** {_pct(eer_result['eer'])} at threshold {eer_result['threshold']}",
        "",
        "| threshold | FAR | FRR |",
        "|---|---|---|",
    ]
    for r in sweep_result:
        lines.append(f"| {r['threshold']:.2f} | {_pct(r['far'])} | {_pct(r['frr'])} |")
    lines.append("")
    return "\n".join(lines)


def _pct(v):
    return "n/a" if v is None else f"{v * 100:.1f}%"


def write_report(out_dir: Path, prod_threshold: float, at_prod: dict, eer_result: dict,
                  sweep_result: list[dict], n_speakers: int) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    md = report_markdown(prod_threshold, at_prod, eer_result, sweep_result, n_speakers)
    (out_dir / "report.md").write_text(md)
    (out_dir / "report.json").write_text(json.dumps(
        {"prodThreshold": prod_threshold, "atProdThreshold": at_prod, "eer": eer_result,
         "sweep": sweep_result, "nSpeakers": n_speakers}, indent=2))
