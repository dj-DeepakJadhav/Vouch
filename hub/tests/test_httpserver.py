"""Tests for vouch_hub/httpserver.py (task F3's `vouch_hub serve`).

No models are loaded: `decode_to_wav_array` and `attest_audio` are
monkeypatched so these tests exercise only the HTTP handler logic (CORS,
size/duration limits, health, response shape).
"""
import http.client
import json
import threading

import numpy as np
import pytest

from vouch_hub import httpserver


@pytest.fixture
def server(monkeypatch):
    monkeypatch.setattr(httpserver, "decode_to_wav_array", lambda raw, ct: np.zeros(16000, dtype=np.float32))
    monkeypatch.setattr(httpserver.config, "load", lambda: {"threshold": 0.6, "members": {}})
    monkeypatch.setattr(
        httpserver,
        "attest_audio",
        lambda x, cfg, submit=True: {
            "status": "recognised",
            "transcript": "Alexa, unlock the front door.",
            "member": "owner",
            "confidence": 0.91,
            "spoofRisk": "low",
            "submitted": {"id": 42},
        },
    )
    httpd = httpserver.ThreadingHTTPServer(("127.0.0.1", 0), httpserver.Handler)
    port = httpd.server_address[1]
    t = threading.Thread(target=httpd.serve_forever, daemon=True)
    t.start()
    try:
        yield port
    finally:
        httpd.shutdown()
        httpd.server_close()


def _post(port, body, headers):
    conn = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
    conn.request("POST", "/utterance", body=body, headers=headers)
    resp = conn.getresponse()
    data = resp.read()
    conn.close()
    return resp, data


def test_health(server):
    conn = http.client.HTTPConnection("127.0.0.1", server, timeout=5)
    conn.request("GET", "/health")
    resp = conn.getresponse()
    assert resp.status == 200
    assert json.loads(resp.read()) == {"ok": True}
    conn.close()


def test_happy_path(server):
    resp, data = _post(
        server,
        b"fake-webm-bytes",
        {"Origin": "http://localhost:53143", "Content-Type": "audio/webm;codecs=opus"},
    )
    assert resp.status == 200
    payload = json.loads(data)
    assert payload["transcript"] == "Alexa, unlock the front door."
    assert payload["speaker"] == "owner"
    assert payload["confidence"] == 0.91
    assert payload["attestationId"] == 42
    assert payload["spoofRisk"] == "low"
    assert resp.getheader("Access-Control-Allow-Origin") == "http://localhost:53143"


def test_cors_rejection(server):
    resp, data = _post(
        server,
        b"fake-webm-bytes",
        {"Origin": "http://evil.example", "Content-Type": "audio/webm;codecs=opus"},
    )
    assert resp.status == 403
    assert resp.getheader("Access-Control-Allow-Origin") is None


def test_cors_allows_127_0_0_1_any_port(server):
    resp, _ = _post(
        server,
        b"fake-webm-bytes",
        {"Origin": "http://127.0.0.1:9999", "Content-Type": "audio/webm;codecs=opus"},
    )
    assert resp.status == 200


def test_size_limit_413(server):
    body = b"x" * (httpserver.MAX_BODY_BYTES + 1)
    resp, data = _post(
        server, body, {"Origin": "http://localhost:1234", "Content-Type": "audio/wav"},
    )
    assert resp.status == 413
    assert "too large" in json.loads(data)["error"]


def test_duration_limit_413(server, monkeypatch):
    # 11 seconds of audio at 16kHz -> over the 10s cap.
    monkeypatch.setattr(
        httpserver, "decode_to_wav_array", lambda raw, ct: np.zeros(16000 * 11, dtype=np.float32)
    )
    resp, data = _post(
        server, b"short-body", {"Origin": "http://localhost:1234", "Content-Type": "audio/wav"},
    )
    assert resp.status == 413
    assert "too long" in json.loads(data)["error"]


def test_options_preflight(server):
    conn = http.client.HTTPConnection("127.0.0.1", server, timeout=5)
    conn.request("OPTIONS", "/utterance", headers={"Origin": "http://localhost:1234"})
    resp = conn.getresponse()
    resp.read()
    assert resp.status == 204
    assert resp.getheader("Access-Control-Allow-Origin") == "http://localhost:1234"
    conn.close()


def test_options_preflight_rejects_bad_origin(server):
    conn = http.client.HTTPConnection("127.0.0.1", server, timeout=5)
    conn.request("OPTIONS", "/utterance", headers={"Origin": "http://evil.example"})
    resp = conn.getresponse()
    resp.read()
    assert resp.status == 403
    conn.close()
