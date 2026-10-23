"""Audio I/O, energy VAD/trim and enrolment quality checks. 16 kHz mono float32."""
import numpy as np
import soundfile as sf

SR = 16000
FRAME = 320  # 20 ms


def load_wav(path) -> np.ndarray:
    x, sr = sf.read(str(path), dtype="float32", always_2d=True)
    x = x.mean(axis=1)
    if sr != SR:  # simple linear resample; demo WAVs are already 16 kHz
        n = int(round(len(x) * SR / sr))
        x = np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x).astype(np.float32)
    return x


def frame_rms(x: np.ndarray) -> np.ndarray:
    n = len(x) // FRAME
    if n == 0:
        return np.zeros(1, dtype=np.float32)
    return np.sqrt((x[: n * FRAME].reshape(n, FRAME) ** 2).mean(axis=1) + 1e-12)


def trim(x: np.ndarray, pad_frames: int = 5) -> np.ndarray:
    """Energy VAD: keep from first to last frame above an adaptive threshold."""
    rms = frame_rms(x)
    floor = np.percentile(rms, 10)
    thr = max(floor * 3.0, 0.01 * rms.max(), 1e-4)
    voiced = np.where(rms > thr)[0]
    if len(voiced) == 0:
        return x[:0]
    a = max(0, voiced[0] - pad_frames) * FRAME
    b = min(len(rms), voiced[-1] + 1 + pad_frames) * FRAME
    return x[a:b]


def quality(x: np.ndarray) -> dict:
    rms = frame_rms(x)
    dur = len(x) / SR
    noise = np.percentile(rms, 10)
    speech = np.percentile(rms, 90)
    snr = 20 * np.log10((speech + 1e-9) / (noise + 1e-9))
    rms_db = 20 * np.log10(float(np.sqrt((x ** 2).mean() + 1e-12)))
    problems = []
    if dur < 1.0:
        problems.append(f"too short ({dur:.2f}s < 1.0s)")
    if rms_db < -45:
        problems.append(f"too quiet ({rms_db:.1f} dBFS)")
    if np.abs(x).max() >= 0.999:
        problems.append("clipping")
    # synthetic TTS has near-digital silence so SNR is huge; only flag low SNR
    if snr < 10:
        problems.append(f"low SNR estimate ({snr:.1f} dB)")
    return {"duration_s": round(dur, 2), "rms_dbfs": round(rms_db, 1),
            "snr_db": round(float(snr), 1), "ok": not problems, "problems": problems}


def record(seconds: float) -> np.ndarray:
    import sounddevice as sd
    print(f"  recording {seconds:.1f}s ...", flush=True)
    x = sd.rec(int(seconds * SR), samplerate=SR, channels=1, dtype="float32")
    sd.wait()
    return x[:, 0]
