"""TitaNet (speaker embedding) + Parakeet (ASR). Loaded once, kept resident."""
import os
import tempfile
import time
import logging

import numpy as np
import soundfile as sf

from .audio import SR

TITANET = "nvidia/speakerverification_en_titanet_large"
PARAKEET = "nvidia/parakeet-tdt-0.6b-v2"
_cache = {}


def _device():
    import torch
    return "mps" if torch.backends.mps.is_available() else "cpu"


def _quiet():
    logging.getLogger("nemo_logger").setLevel(logging.ERROR)
    os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")


def titanet():
    if "titanet" not in _cache:
        _quiet()
        t = time.perf_counter()
        from nemo.collections.asr.models import EncDecSpeakerLabelModel
        m = EncDecSpeakerLabelModel.from_pretrained(TITANET).eval().to(_device())
        _cache["titanet"] = m
        embed(np.random.default_rng(0).standard_normal(SR).astype(np.float32) * 0.05)  # MPS warm-up
        _cache["titanet_load_s"] = time.perf_counter() - t
    return _cache["titanet"]


def parakeet():
    if "parakeet" not in _cache:
        _quiet()
        t = time.perf_counter()
        from nemo.collections.asr.models import ASRModel
        m = ASRModel.from_pretrained(PARAKEET).eval().to(_device())
        _cache["parakeet"] = m
        transcribe(np.zeros(SR, dtype=np.float32))  # MPS warm-up
        _cache["parakeet_load_s"] = time.perf_counter() - t
    return _cache["parakeet"]


def load_times():
    return {k: round(v, 2) for k, v in _cache.items() if k.endswith("_load_s")}


def embed(x: np.ndarray) -> np.ndarray:
    import torch
    m = titanet()
    with torch.no_grad():
        sig = torch.from_numpy(x.astype(np.float32)).unsqueeze(0).to(m.device)
        ln = torch.tensor([sig.shape[1]], device=m.device)
        _, emb = m.forward(input_signal=sig, input_signal_length=ln)
    v = emb.squeeze(0).float().cpu().numpy()
    return v / (np.linalg.norm(v) + 1e-12)


def transcribe(x: np.ndarray) -> str:
    m = parakeet()
    with tempfile.NamedTemporaryFile(suffix=".wav") as f:
        sf.write(f.name, x, SR)
        out = m.transcribe([f.name], verbose=False)
    r = out[0]
    return getattr(r, "text", r if isinstance(r, str) else str(r))
