"""Minimal Serverpod HTTP RPC client.

Wire format reverse-engineered from
`~/.pub-cache/hosted/pub.dev/serverpod_client-4.0.1/lib/src/`:

- URL: `<host><endpoint>/<method>` (serverpod_client_shared.dart,
  `_callServerEndpoint`) — `host` already ends with a trailing slash in
  generated clients (e.g. "http://localhost:8080/"), and endpoint/method
  are joined with '/' with no extra separator.
- Method: HTTP POST.
- Headers: `Content-Type: application/json` (serverpod_client_io.dart
  uses `ContentType.json`). No auth header for unauthenticated calls.
- Body: `SerializationManager.encode(args)` (serverpod_serialization,
  `serialization.dart`) — this is just `jsonEncode` of the args map with
  a custom `toEncodable`: notably `DateTime` -> `toUtc().toIso8601String()`,
  everything else (bool/num/String/List/Map<String,_>) passes through as
  plain JSON. The method name is NOT included in the body — it's part of
  the URL. We don't need enum/model encoding for the `greeting.hello`
  smoke test, so it's not implemented here.
- Response: 200 with a JSON body (the decoded return value, itself
  produced by the same encode() on the server side) on success; non-200
  carries an error payload (see serverpod_client_shared_private.dart,
  `getExceptionFrom`) which we surface as `ServerpodRpcError`.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from typing import Any

import requests


class ServerpodRpcError(RuntimeError):
    def __init__(self, status_code: int, body: str):
        super().__init__(f"Serverpod RPC failed ({status_code}): {body}")
        self.status_code = status_code
        self.body = body


def _to_encodable(value: Any) -> Any:
    if isinstance(value, datetime):
        v = value.astimezone(timezone.utc) if value.tzinfo else value.replace(tzinfo=timezone.utc)
        millis = v.microsecond // 1000
        return v.strftime("%Y-%m-%dT%H:%M:%S") + f".{millis:03d}Z"
    if isinstance(value, dict):
        return {k: _to_encodable(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_to_encodable(v) for v in value]
    return value


class ServerpodRpcClient:
    """Bare-bones client: POSTs `<host><endpoint>/<method>` with a JSON
    body of `args`, returns the parsed JSON response.
    """

    def __init__(self, host: str, timeout: float = 10.0):
        self.host = host if host.endswith("/") else host + "/"
        self.timeout = timeout

    def call(self, endpoint: str, method: str, args: dict[str, Any] | None = None) -> Any:
        args = args or {}
        url = f"{self.host}{endpoint}/{method}"
        body = json.dumps(_to_encodable(args))
        response = requests.post(
            url,
            data=body,
            headers={"Content-Type": "application/json"},
            timeout=self.timeout,
        )
        if response.status_code != 200:
            raise ServerpodRpcError(response.status_code, response.text)
        text = response.text
        if not text:
            return None
        return json.loads(text)
