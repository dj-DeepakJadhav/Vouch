"""MCP client for the Vouch guard (Streamable HTTP, JSON-RPC over POST).

Handles both step-up shapes:
  * modern MRTR: result.resultType == "input_required" with inputRequests +
    requestState; retry the same tools/call with requestState +
    inputResponses. The approval id is read from requestState's (HMAC-signed,
    but not encrypted) payload segment for display / dev approval only — the
    hub never relies on it for trust.
  * legacy: a result carrying approvalRef / approvalId (pending); retry with
    arguments.approvalRef.
"""
import base64
import itertools
import json

import requests

PROTOCOL_VERSION = "2026-07-28"
LEGACY_PROTOCOL_VERSION = "2025-11-25"
_ids = itertools.count(1)


def approval_id_from_state(state: str) -> int | None:
    try:
        seg = state.split(".")[0]
        return int(json.loads(base64.urlsafe_b64decode(seg + "=" * (-len(seg) % 4)))["approvalId"])
    except Exception:
        return None


class Mcp:
    def __init__(self, url, token, session=None, timeout=15, legacy=False):
        self.url, self.token, self.legacy = url, token, legacy
        self.session_id = None
        self.http = session or requests.Session()
        self.timeout = timeout

    def _post(self, method, params, name=None, notification=False):
        headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json",
                   "Accept": "application/json, text/event-stream",
                   "MCP-Protocol-Version": LEGACY_PROTOCOL_VERSION if self.legacy else PROTOCOL_VERSION,
                   "Mcp-Method": method}
        if self.legacy:
            if self.session_id is None and method != "initialize":
                self._initialize()
            if self.session_id:
                headers["Mcp-Session-Id"] = self.session_id
        else:
            # 2026-07-28 is sessionless; the version travels in params._meta.
            params = {**params, "_meta": {**params.get("_meta", {}),
                                          "io.modelcontextprotocol/protocolVersion": PROTOCOL_VERSION}}
        if name:
            headers["Mcp-Name"] = name
        body = {"jsonrpc": "2.0", "method": method, "params": params}
        if not notification:
            body["id"] = next(_ids)
        r = self.http.post(self.url, json=body, headers=headers, timeout=self.timeout)
        if method == "initialize":
            self.session_id = r.headers.get("Mcp-Session-Id")
        text = r.text
        if notification or not text:
            return r.status_code, {}
        if text.startswith("event:") or text.startswith("data:"):  # SSE fallback
            text = next(l[5:] for l in text.splitlines() if l.startswith("data:"))
        try:
            return r.status_code, json.loads(text)
        except ValueError:
            return r.status_code, {"error": {"code": r.status_code, "message": text[:300]}}

    def _initialize(self):
        self._post("initialize", {"protocolVersion": LEGACY_PROTOCOL_VERSION, "capabilities": {},
                                  "clientInfo": {"name": "vouch-hub-alexa-sim", "version": "0.1"}})
        if not self.session_id:
            raise RuntimeError("legacy initialize returned no Mcp-Session-Id")
        self._post("notifications/initialized", {}, notification=True)

    def call_tool(self, name, arguments, request_state=None, input_responses=None):
        params = {"name": name, "arguments": arguments}
        if request_state is not None:
            params["requestState"] = request_state
            params["inputResponses"] = input_responses or {
                "challenge": {"action": "accept", "content": {"confirm": True}}}
        return interpret(*self._post("tools/call", params, name))

    def list_tools(self):
        return self._post("tools/list", {})[1]


def interpret(status, msg) -> dict:
    """Normalise a tools/call response to {decision, text, ...}."""
    if "error" in msg:
        e = msg["error"]
        return {"decision": "ERROR", "text": f"{e.get('code')}: {e.get('message')}", "raw": msg}
    res = msg.get("result", {})
    if res.get("resultType") == "input_required":
        state = res.get("requestState")
        msgs = [v.get("params", {}).get("message") for v in res.get("inputRequests", {}).values()]
        return {"decision": "APPROVAL PENDING", "mode": "mrtr", "requestState": state,
                "approvalId": approval_id_from_state(state or ""), "text": " ".join(filter(None, msgs)),
                "raw": msg}
    sc = res.get("structuredContent") or {}
    ref = res.get("approvalRef") or sc.get("approvalRef")
    if ref is not None or res.get("status") == "pending" or sc.get("status") == "pending":
        aid = res.get("approvalId") or sc.get("approvalId") or approval_id_from_state(ref or "")
        return {"decision": "APPROVAL PENDING", "mode": "legacy", "approvalRef": ref,
                "approvalId": aid, "text": _text(res), "raw": msg}
    text = _text(res)
    return {"decision": "DENIED" if res.get("isError") else "ALLOWED", "text": text, "raw": msg}


def _text(res):
    return " ".join(c.get("text", "") for c in res.get("content", []) if c.get("type") == "text")
