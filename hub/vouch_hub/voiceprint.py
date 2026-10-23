"""Local-only voiceprint store. Centroids are written to data/voiceprints and
are never transmitted — the server only ever sees member ids."""
import numpy as np

from .config import DATA_DIR

VP_DIR = DATA_DIR / "voiceprints"


def save(member_id: int, embeddings: list[np.ndarray]) -> np.ndarray:
    c = np.mean(np.stack(embeddings), axis=0)
    c = c / (np.linalg.norm(c) + 1e-12)
    VP_DIR.mkdir(parents=True, exist_ok=True)
    np.save(VP_DIR / f"{member_id}.npy", c)
    return c


def load_all() -> dict[int, np.ndarray]:
    if not VP_DIR.exists():
        return {}
    return {int(p.stem): np.load(p) for p in VP_DIR.glob("*.npy")}


def score(emb: np.ndarray, prints: dict[int, np.ndarray]) -> dict[int, float]:
    e = emb / (np.linalg.norm(emb) + 1e-12)
    return {mid: float(np.dot(e, c)) for mid, c in prints.items()}


def identify(emb, prints, threshold):
    scores = score(emb, prints)
    if not scores:
        return None, scores
    best = max(scores, key=scores.get)
    return (best if scores[best] >= threshold else None), scores
