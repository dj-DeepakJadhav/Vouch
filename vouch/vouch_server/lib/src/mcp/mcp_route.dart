import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'mcp_guard.dart';
import 'tools.dart';
import 'verdict_card.dart';

/// JSON-RPC 2.0 reserved error codes used below (spec-mandated values).
class _RpcError {
  static const parseError = -32700;
  static const invalidRequest = -32600;
  static const methodNotFound = -32601;
  static const invalidParams = -32602;
  static const internalError = -32603;
}

/// One legacy (2025-11-25) session. Per the spec page (see class doc on
/// [McpRoute]), the server MAY mint an `Mcp-Session-Id` on `initialize` and
/// the client must echo it on every later request; unknown/expired ->
/// `404`. There is no persistence requirement in the spec, so an in-memory
/// map with a TTL is spec-compliant and adequate for this hackathon (single
/// server process, not clustered).
class _LegacySession {
  _LegacySession({required this.householdId, required this.createdAt});
  final int householdId;
  final DateTime createdAt;
}

/// MCP over Streamable HTTP.
///
/// Dual-era per request, per the vouch-mcp-alexa skill's
/// `references/streamable-http.md` note (era detection, verified against
/// the live spec pages, both fetched and quoted in code comments below):
///   - https://modelcontextprotocol.io/specification/2025-11-25/basic/transports#streamable-http
///   - https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http
///
/// Era detection rule actually implemented here (matches the skill notes'
/// "Era detection (server side, per request)" section):
///   1. Body `method == "initialize"` -> legacy (2025-11-25) handshake.
///   2. Else body has `params._meta["io.modelcontextprotocol/protocolVersion"]`
///      -> modern (2026-07-28) path.
///   3. Else -> legacy, keyed off the `Mcp-Session-Id` request header (missing
///      -> 400, unknown/expired -> 404).
///
/// Modern-era behaviour (2026-07-28: no `initialize`, no sessions, MRTR
/// `input_required`/`inputResponses`) is unchanged from the original B3 cut.
/// Legacy-era (2025-11-25) behaviour is new: `initialize` handshake with a
/// minted `Mcp-Session-Id`, `notifications/initialized` -> 202, GET/DELETE
/// handling, and step-up via a plain tool result carrying a
/// `structuredContent.approvalRef` instead of MRTR (legacy clients predate
/// MRTR/elicitation-as-retry; see TASKS item 2 in the brief).
class McpRoute extends Route {
  McpRoute()
    : super(methods: {Method.post, Method.get, Method.delete, Method.options});

  static const String modernProtocolVersion = '2026-07-28';
  static const String legacyProtocolVersion = '2025-11-25';
  static const String serverName = 'vouch-mcp';
  static const String serverVersion = '0.1.0';

  /// How long an unused legacy session stays valid. Hackathon-scale value;
  /// documented rather than tuned — see class doc.
  static const Duration _sessionTtl = Duration(hours: 2);

  static final Map<String, _LegacySession> _legacySessions = {};
  static final Random _rand = Random.secure();

  /// Origin allowlist for the DNS-rebinding defence both spec pages require
  /// ("If it's present and invalid, return 403" — see class doc URLs, "##
  /// Shared by both" > Security). localhost/127.0.0.1 on any port always
  /// allowed; extra hosts can be added here for real deployments.
  static const List<String> _extraAllowedOriginHosts = [];

  String _mintSessionId() {
    final bytes = List<int>.generate(32, (_) => _rand.nextInt(256));
    // Visible ASCII, base64url has no padding issues for our purposes.
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  void _pruneExpiredSessions() {
    final now = DateTime.now().toUtc();
    _legacySessions.removeWhere(
      (_, s) => now.difference(s.createdAt) > _sessionTtl,
    );
  }

  bool _originAllowed(String origin) {
    Uri uri;
    try {
      uri = Uri.parse(origin);
    } catch (_) {
      return false;
    }
    final host = uri.host;
    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      return true;
    }
    return _extraAllowedOriginHosts.contains(host);
  }

  /// CORS request headers a browser (Flutter web, in development) may need
  /// to send, allow-listed for the preflight response. Comma-and-space
  /// separated per the `Access-Control-Allow-Headers` header contract.
  static const List<String> _corsAllowedRequestHeaders = [
    'Content-Type',
    'Authorization',
    'Mcp-Session-Id',
    'Mcp-Protocol-Version',
  ];

  @override
  Future<Result> handleCall(Session session, Request request) async {
    // --- CORS (development only): the Flutter web app runs on its own
    // localhost:<port> origin, a different origin than this server, so the
    // browser preflights every call and expects the response (including
    // the actual POST/GET/DELETE response, not just the OPTIONS one) to
    // carry Access-Control-Allow-* headers. This sits ahead of every other
    // check — a preflight carries no bearer token or JSON-RPC body — but
    // reuses exactly the same [_originAllowed] allowlist as the existing
    // DNS-rebinding defence below, so the Origin allowlist behaviour for
    // real (non-preflight) requests is unchanged.
    if (request.method == Method.options) {
      return _handlePreflight(request);
    }

    final result = await _handleCallInner(session, request);
    return _withCors(result, request);
  }

  Result _handlePreflight(Request request) {
    final originValues = request.headers['origin'];
    if (originValues != null &&
        originValues.isNotEmpty &&
        !_originAllowed(originValues.first)) {
      return Response(403);
    }
    return Response(
      204,
      headers: Headers.build((h) {
        if (originValues != null && originValues.isNotEmpty) {
          h['access-control-allow-origin'] = [originValues.first];
        }
        h['access-control-allow-methods'] = ['GET, POST, DELETE, OPTIONS'];
        h['access-control-allow-headers'] = [
          _corsAllowedRequestHeaders.join(', '),
        ];
        h['access-control-expose-headers'] = ['Mcp-Session-Id'];
        h['vary'] = ['Origin'];
      }),
    );
  }

  /// Attaches CORS response headers to [result] when the request carried an
  /// allowed `Origin` — a browser needs these on the *actual* response, not
  /// just the OPTIONS preflight, or it discards the response before handing
  /// it to the calling code.
  Result _withCors(Result result, Request request) {
    if (result is! Response) return result;
    final originValues = request.headers['origin'];
    if (originValues == null || originValues.isEmpty) return result;
    if (!_originAllowed(originValues.first)) return result;

    return result.copyWith(
      headers: result.headers.transform((h) {
        h['access-control-allow-origin'] = [originValues.first];
        h['access-control-expose-headers'] = ['Mcp-Session-Id'];
        final vary = h['vary'];
        if (vary == null || vary.isEmpty) {
          h['vary'] = ['Origin'];
        } else if (!vary.contains('Origin')) {
          h['vary'] = [...vary, 'Origin'];
        }
      }),
    );
  }

  Future<Result> _handleCallInner(Session session, Request request) async {
    // --- Origin check (both eras): DNS-rebinding defence. -----------------
    // Spec (both pages, "Security" bullet under "Shared by both" in the
    // vouch-mcp-alexa notes, verified against the live pages): "validate
    // Origin on every request. If it's present and invalid, return 403."
    // Absent Origin header is allowed through (non-browser clients, e.g.
    // Alexa+'s server-to-server call, typically don't send one).
    final originValues = request.headers['origin'];
    if (originValues != null && originValues.isNotEmpty) {
      final origin = originValues.first;
      if (!_originAllowed(origin)) {
        return _jsonResponse(403, {
          'jsonrpc': '2.0',
          'id': null,
          'error': {
            'code': _RpcError.invalidRequest,
            'message': 'origin not allowed: $origin',
          },
        });
      }
    }

    if (request.method == Method.get) {
      return _handleGet(request);
    }
    if (request.method == Method.delete) {
      return _handleDelete(request);
    }

    // --- Auth: per-household bearer token -> McpClient -> householdId. ---
    final auth = request.headers.authorization;
    String? rawToken;
    if (auth is BearerAuthorizationHeader) {
      rawToken = auth.token;
    }
    if (rawToken == null || rawToken.isEmpty) {
      return _jsonResponse(401, {
        'jsonrpc': '2.0',
        'id': null,
        'error': {
          'code': _RpcError.invalidRequest,
          'message': 'missing bearer token',
        },
      });
    }

    final tokenHash = sha256Hex(rawToken);
    final client = await McpClient.db.findFirstRow(
      session,
      where: (t) => t.tokenHash.equals(tokenHash) & t.revoked.equals(false),
    );
    if (client == null) {
      return _jsonResponse(401, {
        'jsonrpc': '2.0',
        'id': null,
        'error': {
          'code': _RpcError.invalidRequest,
          'message': 'invalid or revoked bearer token',
        },
      });
    }
    final householdId = client.householdId;

    // --- Parse JSON-RPC envelope. ------------------------------------------
    final bodyText = await request.readAsString();
    Map<String, dynamic> rpc;
    try {
      final decoded = jsonDecode(bodyText);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('not an object');
      }
      rpc = decoded;
    } catch (_) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': null,
        'error': {'code': _RpcError.parseError, 'message': 'parse error'},
      });
    }

    final id = rpc['id'];
    final method = rpc['method'];
    final params = (rpc['params'] as Map?)?.cast<String, dynamic>() ?? {};

    if (method is! String) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': id,
        'error': {
          'code': _RpcError.invalidRequest,
          'message': 'missing "method"',
        },
      });
    }

    // A JSON-RPC *notification* has no "id" — no response body is sent,
    // only a bare 202 Accepted (Streamable HTTP convention for
    // notifications/*, since there is nothing to correlate a response to).
    final isNotification = !rpc.containsKey('id');

    // --- Era detection, per request (see class doc). -----------------------
    _pruneExpiredSessions();
    final meta = (params['_meta'] as Map?)?.cast<String, dynamic>();
    final modernVersion =
        meta?['io.modelcontextprotocol/protocolVersion'] as String?;

    final isLegacyHandshake = method == 'initialize';
    final isModern = !isLegacyHandshake && modernVersion != null;

    if (isLegacyHandshake) {
      return _handleLegacyInitialize(id, householdId);
    }

    if (!isModern) {
      // Legacy, non-initialize request: must carry a known session id.
      // "Missing -> 400. Terminated [unknown/expired] -> 404" per the spec
      // notes (Sessions row).
      final sessionIdValues = request.headers['mcp-session-id'];
      if (sessionIdValues == null || sessionIdValues.isEmpty) {
        return _jsonResponse(400, {
          'jsonrpc': '2.0',
          'id': id,
          'error': {
            'code': _RpcError.invalidRequest,
            'message': 'missing Mcp-Session-Id header',
          },
        });
      }
      final sid = sessionIdValues.first;
      final legacySession = _legacySessions[sid];
      if (legacySession == null) {
        return _jsonResponse(404, {
          'jsonrpc': '2.0',
          'id': id,
          'error': {
            'code': _RpcError.invalidRequest,
            'message': 'unknown or expired Mcp-Session-Id',
          },
        });
      }
      if (legacySession.householdId != householdId) {
        return _jsonResponse(404, {
          'jsonrpc': '2.0',
          'id': id,
          'error': {
            'code': _RpcError.invalidRequest,
            'message': 'session does not belong to this bearer token',
          },
        });
      }
    }

    try {
      switch (method) {
        case 'notifications/initialized':
          // Ack only — no JSON-RPC body for a notification, both eras.
          return Response(202);

        case 'tools/list':
          return _handleToolsList(id);

        case 'resources/list':
          return _handleResourcesList(id);

        case 'resources/read':
          return _handleResourcesRead(id, params);

        case 'tools/call':
          return await _handleToolsCall(
            session,
            id: id,
            householdId: householdId,
            params: params,
            legacy: !isModern,
          );

        default:
          if (isNotification) {
            // Unknown notification: still no response body per spec (a
            // notification never gets a reply, error or otherwise).
            return Response(202);
          }
          return _jsonResponse(200, {
            'jsonrpc': '2.0',
            'id': id,
            'error': {
              'code': _RpcError.methodNotFound,
              'message': 'method not found: $method',
            },
          });
      }
    } on McpGuardProtocolError catch (e) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': id,
        'error': {'code': e.code, 'message': e.message},
      });
    } catch (e) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': id,
        'error': {'code': _RpcError.internalError, 'message': '$e'},
      });
    }
  }

  /// GET /mcp: per the 2025-11-25 page, a client MAY GET to open a
  /// server->client SSE stream; a server that doesn't offer one MUST
  /// respond `405 Method Not Allowed` (verified against the live spec page:
  /// "the server MUST either return `Content-Type: text/event-stream` ...
  /// or else return HTTP 405"). We don't implement server-initiated SSE
  /// (out of scope — see class doc "Only ... implemented"), so we always
  /// 405 here. The 2026-07-28 page removes GET entirely (also -> 405), so
  /// one code path covers both eras.
  Result _handleGet(Request request) {
    return Response(405);
  }

  /// DELETE /mcp: 2025-11-25 lets a client explicitly end its session; a
  /// server that doesn't support client-initiated termination MAY reply
  /// `405` (verified against the live spec page). We do support it: an
  /// unknown/missing session id is a no-op 404, a known one is evicted.
  Result _handleDelete(Request request) {
    final sessionIdValues = request.headers['mcp-session-id'];
    if (sessionIdValues == null || sessionIdValues.isEmpty) {
      return Response(400);
    }
    final removed = _legacySessions.remove(sessionIdValues.first);
    return Response(removed == null ? 404 : 204);
  }

  Result _handleLegacyInitialize(dynamic id, int householdId) {
    final sid = _mintSessionId();
    _legacySessions[sid] = _LegacySession(
      householdId: householdId,
      createdAt: DateTime.now().toUtc(),
    );
    return Response(
      200,
      headers: Headers.build((h) {
        h['mcp-session-id'] = [sid];
        h['mcp-protocol-version'] = [legacyProtocolVersion];
      }),
      body: Body.fromString(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'protocolVersion': legacyProtocolVersion,
            'serverInfo': {'name': serverName, 'version': serverVersion},
            'capabilities': {
              'tools': {},
              // MCP Apps (SEP-1865) ui:// resources — advertised so a
              // legacy-era host knows resources/list + resources/read are
              // available for the verdict card. Modern (2026-07-28) has no
              // `initialize` handshake to advertise capabilities on; those
              // clients discover the resource via `_meta.ui.resourceUri` on
              // each tool (see tools.dart) and a plain resources/read.
              'resources': {},
            },
          },
        }),
        mimeType: MimeType.json,
      ),
    );
  }

  Result _handleToolsList(dynamic id) {
    return _jsonResponse(200, {
      'jsonrpc': '2.0',
      'id': id,
      'result': {'tools': mcpTools.map((t) => t.toJson()).toList()},
    });
  }

  /// `resources/list`: advertises the single `ui://vouch/verdict` MCP Apps
  /// resource, in both protocol eras (this handler sits in the shared
  /// method switch used by both — see era detection above).
  Result _handleResourcesList(dynamic id) {
    return _jsonResponse(200, {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'resources': [verdictResourceListEntry()],
      },
    });
  }

  /// `resources/read`: serves the verdict card's self-contained HTML.
  /// Per spec, `mimeType` MUST be `text/html;profile=mcp-app` and the
  /// content is returned via `text` (see verdict_card.dart doc comment for
  /// the exact source of these field names).
  Result _handleResourcesRead(dynamic id, Map<String, dynamic> params) {
    final uri = params['uri'];
    if (uri != verdictResourceUri) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': id,
        'error': {
          'code': _RpcError.invalidParams,
          'message': 'unknown resource uri: $uri',
        },
      });
    }
    return _jsonResponse(200, {
      'jsonrpc': '2.0',
      'id': id,
      'result': verdictResourceReadResult(),
    });
  }

  Future<Result> _handleToolsCall(
    Session session, {
    required dynamic id,
    required int householdId,
    required Map<String, dynamic> params,
    required bool legacy,
  }) async {
    final toolName = params['name'];
    if (toolName is! String) {
      return _jsonResponse(200, {
        'jsonrpc': '2.0',
        'id': id,
        'error': {
          'code': _RpcError.invalidParams,
          'message': 'missing "name"',
        },
      });
    }
    final args = (params['arguments'] as Map?)?.cast<String, dynamic>() ?? {};

    if (legacy) {
      // Legacy (2025-11-25) step-up: no MRTR. A T2 action either succeeds
      // outright (T0/T1, or a fresh retry with a valid `approvalRef` that
      // is already APPROVED) or comes back as a normal (isError:false)
      // tool result carrying a signed `approvalRef` the client must resend
      // verbatim as a tool argument to retry — see TASKS item 2 / class
      // doc. `approvalRef` reuses the exact same signed-blob format as
      // modern `requestState` (McpGuard/RequestStateCodec don't know or
      // care which era minted the string).
      final approvalRef = args['approvalRef'];
      final toolArgsForGuard = Map<String, dynamic>.of(args)
        ..remove('approvalRef');

      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: householdId,
        toolName: toolName,
        args: toolArgsForGuard,
        requestState: approvalRef is String ? approvalRef : null,
      );

      switch (outcome) {
        case McpGuardSuccess(:final text, :final trace):
          return _jsonResponse(200, {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'content': [
                {'type': 'text', 'text': text},
              ],
              'structuredContent': {'vouch': trace.toJson()},
              'isError': false,
            },
          });

        case McpGuardToolError(:final reason, :final trace):
          return _jsonResponse(200, {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'content': [
                {'type': 'text', 'text': reason},
              ],
              'structuredContent': {'vouch': trace.toJson()},
              'isError': true,
            },
          });

        case McpGuardInputRequired(:final requestState, :final trace):
          // Legacy step-up: a *normal* result (isError: false), not a
          // protocol-level elicitation, per TASKS item 2 — legacy clients
          // have no MRTR retry mechanism, so we hand back plain text plus
          // structuredContent the client (or a human) can act on, and the
          // client re-issues `tools/call` with `approvalRef` set once the
          // owner approves.
          return _jsonResponse(200, {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'content': [
                {
                  'type': 'text',
                  'text':
                      "Approval needed — I've asked the owner's phone. Say "
                      "'try again' once they approve.",
                },
              ],
              'structuredContent': {
                'status': 'approval_pending',
                'approvalRef': requestState,
                'vouch': trace.toJson(),
              },
              'isError': false,
            },
          });
      }
    }

    // --- Modern (2026-07-28) MRTR path — unchanged from the original cut.
    final requestState = params['requestState'];
    final inputResponses = (params['inputResponses'] as Map?)
        ?.cast<String, dynamic>();

    final outcome = await McpGuard.handleToolCall(
      session,
      householdId: householdId,
      toolName: toolName,
      args: args,
      requestState: requestState is String ? requestState : null,
      inputResponses: inputResponses,
    );

    switch (outcome) {
      case McpGuardSuccess(:final text, :final trace):
        return _jsonResponse(200, {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'resultType': 'complete',
            'content': [
              {'type': 'text', 'text': text},
            ],
            'structuredContent': {'vouch': trace.toJson()},
            'isError': false,
          },
        });

      case McpGuardToolError(:final reason, :final trace):
        // Tool-level failure (policy denial, expired/denied approval,
        // replay). Not a JSON-RPC protocol error — a normal tools/call
        // result with isError:true, so a voice client can speak `reason`
        // back to the user, per spec convention for tool execution errors.
        return _jsonResponse(200, {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'resultType': 'complete',
            'content': [
              {'type': 'text', 'text': reason},
            ],
            'structuredContent': {'vouch': trace.toJson()},
            'isError': true,
          },
        });

      case McpGuardInputRequired(
        :final requestState,
        :final message,
        :final trace,
      ):
        // Best-effort interpretation (see class doc / S2 spike): a single
        // elicitation/create entry keyed "challenge", form mode, asking the
        // owner-app-side confirmation question. requestState is echoed
        // back verbatim by the client on retry.
        return _jsonResponse(200, {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'resultType': 'input_required',
            'inputRequests': {
              'challenge': {
                'method': 'elicitation/create',
                'params': {
                  'mode': 'form',
                  'message': message,
                  'requestedSchema': {
                    'type': 'object',
                    'properties': {
                      'confirm': {'type': 'boolean'},
                    },
                  },
                },
              },
            },
            'requestState': requestState,
            'structuredContent': {'vouch': trace.toJson()},
          },
        });
    }
  }

  Result _jsonResponse(int status, Map<String, dynamic> body) {
    return Response(
      status,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
    );
  }
}
