#!/usr/bin/env bash
# Smoke-tests the /mcp route's legacy (2025-11-25) transport mechanics
# against the RUNNING dev server (API on :8080, MCP on :8082). Does not
# start or stop anything — the server must already be up.
#
# Covers: dev seed, legacy `initialize` + Mcp-Session-Id issuance, missing
# session -> 400, unknown session -> 404, bad Origin -> 403, GET -> 405,
# a notification -> 202 with no body.
#
# Usage: bash tool/smoke.sh

set -euo pipefail

API_URL="${API_URL:-http://localhost:8080}"
MCP_URL="${MCP_URL:-http://localhost:8082/mcp}"

pass=0
fail=0

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "PASS: $desc (got $actual)"
    pass=$((pass + 1))
  else
    echo "FAIL: $desc (expected $expected, got $actual)"
    fail=$((fail + 1))
  fi
}

echo "== seeding a fresh demo household =="
HUB_KEY="$(openssl rand -base64 32)"
SEED_JSON="$(curl -s -X POST "$API_URL/dev/seedDemoHousehold" \
  -H 'content-type: application/json' \
  -d "{\"ownerName\":\"Smoke Owner\",\"childName\":\"Smoke Kid\",\"hubPublicKeyBase64\":\"$HUB_KEY\"}")"
echo "$SEED_JSON"
TOKEN="$(echo "$SEED_JSON" | sed -n 's/.*"mcpToken":"\([^"]*\)".*/\1/p')"
if [[ -z "$TOKEN" ]]; then
  echo "FAIL: could not extract mcpToken from seed response"
  exit 1
fi
echo

echo "== legacy initialize -> 200 + Mcp-Session-Id + MCP-Protocol-Version =="
INIT_HEADERS="$(mktemp)"
INIT_BODY="$(curl -s -D "$INIT_HEADERS" -o - -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}')"
echo "$INIT_BODY"
STATUS="$(head -1 "$INIT_HEADERS" | tr -d '\r' | awk '{print $2}')"
SESSION_ID="$(grep -i '^mcp-session-id:' "$INIT_HEADERS" | tr -d '\r' | sed 's/^[Mm][Cc][Pp]-[Ss]ession-[Ii]d: //')"
PROTO_VERSION="$(grep -i '^mcp-protocol-version:' "$INIT_HEADERS" | tr -d '\r' | sed 's/^[Mm][Cc][Pp]-[Pp]rotocol-[Vv]ersion: //')"
check "initialize status" "200" "$STATUS"
check "MCP-Protocol-Version header" "2025-11-25" "$PROTO_VERSION"
if [[ -n "$SESSION_ID" ]]; then
  echo "PASS: Mcp-Session-Id issued ($SESSION_ID)"
  pass=$((pass + 1))
else
  echo "FAIL: no Mcp-Session-Id header on initialize response"
  fail=$((fail + 1))
fi
rm -f "$INIT_HEADERS"
echo

echo "== tools/list with valid session -> 200 =="
LIST_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}')"
check "tools/list with valid session status" "200" "$LIST_STATUS"
echo

echo "== tools/list with MISSING session header -> 400 =="
MISSING_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}')"
check "missing session status" "400" "$MISSING_STATUS"
echo

echo "== tools/list with UNKNOWN session header -> 404 =="
UNKNOWN_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Mcp-Session-Id: totally-bogus-session-id' \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":4,"method":"tools/list","params":{}}')"
check "unknown session status" "404" "$UNKNOWN_STATUS"
echo

echo "== bad Origin header -> 403 =="
BAD_ORIGIN_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -H 'Origin: https://evil.example.com' \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":5,"method":"tools/list","params":{}}')"
check "bad Origin status" "403" "$BAD_ORIGIN_STATUS"
echo

echo "== GET /mcp -> 405 =="
GET_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X GET "$MCP_URL")"
check "GET status" "405" "$GET_STATUS"
echo

echo "== notification (no id) -> 202, empty body =="
NOTIF_HEADERS="$(mktemp)"
NOTIF_BODY="$(curl -s -D "$NOTIF_HEADERS" -o - -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}')"
NOTIF_STATUS="$(head -1 "$NOTIF_HEADERS" | tr -d '\r' | awk '{print $2}')"
check "notification status" "202" "$NOTIF_STATUS"
check "notification body is empty" "" "$NOTIF_BODY"
rm -f "$NOTIF_HEADERS"
echo

echo "== DELETE /mcp with valid session -> 204 =="
DELETE_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$MCP_URL" \
  -H "Mcp-Session-Id: $SESSION_ID")"
check "DELETE status" "204" "$DELETE_STATUS"
echo

echo "== tools/list with just-deleted session -> 404 =="
POST_DELETE_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$MCP_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":6,"method":"tools/list","params":{}}')"
check "post-delete session status" "404" "$POST_DELETE_STATUS"
echo

echo "== summary: $pass passed, $fail failed =="
if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
