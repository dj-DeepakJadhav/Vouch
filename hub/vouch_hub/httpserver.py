"""Local HTTP server for the Flutter web "Hold to talk" button (task F3).

Binds to 127.0.0.1 ONLY. Takes browser-recorded audio (audio/webm;codecs=opus
or audio/wav), converts it to 16 kHz mono, and runs the SAME pipeline as
`vouch_hub attest` (`cli.attest_audio`) — no duplicated logic. Never persists
audio beyond what `attest_audio` already does (nothing extra is written here).

Uses only the stdlib (`http.server`) plus `ffmpeg` via subprocess for decode,
so there's no new heavy dependency. See hub/README.md "Voice simulator" for
the exact run command and the ffmpeg install note.
"""
import json
import shutil
import subprocess
import tempfile
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from . import audio, config
from .cli import attest_audio

HOST = "127.0.0.1"
PORT = 8765
MAX_BODY_BYTES = 2 * 1024 * 1024  # 2 MB
MAX_AUDIO_SECONDS = 10.0


def _origin_allowed(origin: str | None) -> bool:
    """Only Origins whose host is localhost or 127.0.0.1 (any port)."""
    if not origin:
        return False
    try:
        host = urlparse(origin).hostname
    except ValueError:
        return False
    return host in ("localhost", "127.0.0.1")


def ffmpeg_available() -> bool:
    return shutil.which("ffmpeg") is not None


def decode_to_wav_array(raw: bytes, content_type: str):
    """Convert arbitrary browser audio bytes (webm/opus, wav, ...) to a 16 kHz
    mono float32 numpy array, using ffmpeg. Raises RuntimeError if ffmpeg is
    not installed or decoding fails."""
    if not ffmpeg_available():
        raise RuntimeError(
            "ffmpeg not found on PATH. Install it (e.g. `brew install ffmpeg`) "
            "so /utterance can decode browser audio; see hub/README.md."
        )
    suffix = ".webm" if "webm" in content_type else ".wav"
    with tempfile.TemporaryDirectory() as td:
        src = Path(td) / f"in{suffix}"
        dst = Path(td) / "out.wav"
        src.write_bytes(raw)
        proc = subprocess.run(
            ["ffmpeg", "-y", "-i", str(src), "-ac", "1", "-ar", str(audio.SR), str(dst)],
            capture_output=True,
        )
        if proc.returncode != 0 or not dst.exists():
            raise RuntimeError(f"ffmpeg decode failed: {proc.stderr.decode(errors='replace')[:400]}")
        return audio.load_wav(dst)


class Handler(BaseHTTPRequestHandler):
    server_version = "VouchHub/1.0"
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):  # quieter default logging
        pass

    def _cors_headers(self, origin: str | None):
        if _origin_allowed(origin):
            self.send_header("Access-Control-Allow-Origin", origin)
            self.send_header("Vary", "Origin")
            self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _drain(self, length: int, chunk: int = 65536):
        remaining = length
        while remaining > 0:
            n = self.rfile.read(min(chunk, remaining))
            if not n:
                break
            remaining -= len(n)

    def _send_json(self, status: int, payload: dict, origin: str | None):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self._cors_headers(origin)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        origin = self.headers.get("Origin")
        if not _origin_allowed(origin):
            self.send_response(403)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        self.send_response(204)
        self._cors_headers(origin)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self):
        origin = self.headers.get("Origin")
        path = urlparse(self.path).path
        if path == "/health":
            self._send_json(200, {"ok": True}, origin)
            return
        self._send_json(404, {"error": "not found"}, origin)

    def do_POST(self):
        origin = self.headers.get("Origin")
        path = urlparse(self.path).path
        if path != "/utterance":
            self._send_json(404, {"error": "not found"}, origin)
            return
        # Browser JS talking to /utterance always sends an Origin header;
        # reject anything else outright (also covers non-browser CORS probes).
        if not _origin_allowed(origin):
            self._send_json(403, {"error": "origin not allowed"}, origin)
            return
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            self._send_json(400, {"error": "empty body"}, origin)
            return
        if length > MAX_BODY_BYTES:
            # Drain the body so the client's write doesn't hit a reset
            # socket before it finishes sending (keep-alive HTTP/1.1).
            self._drain(length)
            self._send_json(413, {"error": "body too large"}, origin)
            return
        raw = self.rfile.read(length)
        content_type = self.headers.get("Content-Type", "audio/webm;codecs=opus")

        try:
            x = decode_to_wav_array(raw, content_type)
        except RuntimeError as e:
            self._send_json(500, {"error": str(e)}, origin)
            return

        duration_s = len(x) / audio.SR
        if duration_s > MAX_AUDIO_SECONDS:
            self._send_json(413, {"error": f"audio too long ({duration_s:.1f}s > {MAX_AUDIO_SECONDS}s)"}, origin)
            return

        cfg = config.load()
        result = attest_audio(x, cfg, submit=True)

        response = {
            "transcript": result.get("transcript"),
            "speaker": result.get("member"),
            "confidence": result.get("confidence"),
            "attestationId": (result.get("submitted") or {}).get("id"),
            "spoofRisk": result.get("spoofRisk"),
        }
        if result["status"] != "recognised":
            response["status"] = result["status"]
        self._send_json(200, response, origin)


def serve(host: str = HOST, port: int = PORT):
    """Load models once, keep them resident, then serve forever."""
    from . import models
    models.titanet()
    models.parakeet()
    print(f"models resident: {models.load_times()}")
    httpd = ThreadingHTTPServer((host, port), Handler)
    print(f"vouch_hub serve listening on http://{host}:{port} (127.0.0.1 only)")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()
