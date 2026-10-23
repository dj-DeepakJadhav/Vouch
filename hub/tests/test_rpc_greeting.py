"""Live smoke test: calls the example `greeting.hello` endpoint on the
running Serverpod dev server. Requires the server to already be running
on http://localhost:8080 (started separately via `serverpod start` /
the serverpod MCP) — this test does not start or stop it.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pytest
import requests

from vouch_hub.rpc import ServerpodRpcClient

HOST = "http://localhost:8080"


def _server_reachable() -> bool:
    try:
        requests.post(f"{HOST}/greeting/hello", json={"name": "ping"}, timeout=2)
        return True
    except requests.RequestException:
        return False


@pytest.mark.live
@pytest.mark.skipif(
    not _server_reachable(), reason="Serverpod dev server not reachable on :8080"
)
def test_greeting_hello():
    client = ServerpodRpcClient(HOST)
    result = client.call("greeting", "hello", {"name": "Vouch"})
    assert result["message"] == "Hello Vouch"
    assert result["author"] == "Serverpod"
    assert "timestamp" in result
