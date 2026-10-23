"""Hub signing wrapper round-trip + MCP response interpretation (server mocked)."""
import base64
import json
from datetime import datetime, timezone

from vouch_hub import keys, mcp, signing
from vouch_hub.normalise import normalise, transcript_hash


def test_sign_verify_roundtrip(tmp_path):
    sk = keys.generate_keypair(tmp_path)
    assert (tmp_path / "hub_ed25519.key").stat().st_mode & 0o777 == 0o600
    pub = signing.public_key_b64(sk)
    assert len(base64.b64decode(pub)) == 32
    at = datetime(2026, 9, 24, 10, 0, 0, 123000, tzinfo=timezone.utc)
    norm = normalise("Alexa, unlock the front door.")
    p, sig = signing.sign_attestation(sk, hub_id=2, member_id=3, tier="t1", confidence=0.859,
                                      spoof_risk="low", transcript_normalised=norm, captured_at=at)
    assert p == ('{"hubId":2,"memberId":3,"tier":"t1","confidence":0.859,"spoofRisk":"low",'
                 f'"transcriptHash":"{transcript_hash(norm)}","capturedAt":"2026-09-24T10:00:00.123Z"}}')
    assert signing.verify(pub, p, sig)
    assert not signing.verify(pub, p.replace('"t1"', '"t2"'), sig)


def test_now_ms_truncates():
    assert signing.now_ms().microsecond % 1000 == 0


def _state(aid):
    seg = base64.urlsafe_b64encode(json.dumps({"approvalId": aid}).encode()).decode()
    return seg + ".sig"


def test_interpret_mrtr():
    r = mcp.interpret(200, {"result": {"resultType": "input_required", "requestState": _state(7),
                                       "inputRequests": {"challenge": {"params": {"message": "wait"}}}}})
    assert (r["decision"], r["mode"], r["approvalId"], r["text"]) == ("APPROVAL PENDING", "mrtr", 7, "wait")


def test_interpret_legacy():
    r = mcp.interpret(200, {"result": {"content": [{"type": "text", "text": "ask owner"}],
                                       "structuredContent": {"approvalRef": _state(9)}, "isError": False}})
    assert (r["decision"], r["mode"], r["approvalId"]) == ("APPROVAL PENDING", "legacy", 9)


def test_interpret_allowed_denied_error():
    ok = {"result": {"content": [{"type": "text", "text": "Front door unlocked."}], "isError": False}}
    no = {"result": {"content": [{"type": "text", "text": "speaker not recognised"}], "isError": True}}
    assert mcp.interpret(200, ok)["decision"] == "ALLOWED"
    assert mcp.interpret(200, no)["decision"] == "DENIED"
    assert mcp.interpret(400, {"error": {"code": -32600, "message": "x"}})["decision"] == "ERROR"


class _Resp:
    def __init__(self, body, headers=None):
        self.text, self.status_code, self.headers = json.dumps(body) if body else "", 200, headers or {}


class _Http:
    def __init__(self, replies):
        self.replies, self.sent = replies, []

    def post(self, url, json=None, headers=None, timeout=None):
        self.sent.append((json, headers))
        return self.replies.pop(0)


def test_modern_call_carries_meta_and_retry_state():
    http = _Http([_Resp({"result": {"content": [], "isError": False}})])
    m = mcp.Mcp("http://x/mcp", "tok", session=http)
    m.call_tool("unlock_front_door", {"utterance": "u"}, request_state="S")
    body, headers = http.sent[0]
    assert headers["Authorization"] == "Bearer tok"
    assert body["params"]["_meta"]["io.modelcontextprotocol/protocolVersion"] == "2026-07-28"
    assert body["params"]["requestState"] == "S" and "challenge" in body["params"]["inputResponses"]


def test_legacy_handshake_then_session_header():
    http = _Http([_Resp({"result": {}}, {"Mcp-Session-Id": "sid"}), _Resp(None),
                  _Resp({"result": {"content": [], "isError": False}})])
    m = mcp.Mcp("http://x/mcp", "tok", session=http, legacy=True)
    m.call_tool("unlock_front_door", {"utterance": "u", "approvalRef": "R"})
    assert [b["method"] for b, _ in http.sent] == ["initialize", "notifications/initialized", "tools/call"]
    assert "id" not in http.sent[1][0]
    assert http.sent[2][1]["Mcp-Session-Id"] == "sid"
    assert "_meta" not in http.sent[2][0]["params"]
