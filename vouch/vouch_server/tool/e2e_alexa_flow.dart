// Live end-to-end smoke test for the demo: exercises the exact same path
// the Flutter admin app's Alexa screen drives (see
// vouch_flutter/lib/data/mcp/mcp_gateway.dart and logic/alexa_controller.dart)
// against a REAL, RUNNING `serverpod start` server — real RPC calls to the
// API port, real HTTP `tools/call` requests to the MCP endpoint (modern
// era, 2026-07-28), no mocks.
//
// What it does, in order:
//   1. Seeds a fresh demo household (owner + child + hub with a real
//      Ed25519 keypair minted server-side) via `dev.seedDemoHousehold`.
//   2. Owner attestation "unlock the front door" (T1, real signed
//      attestation via `dev.issueTestAttestation`) -> `tools/call
//      unlock_front_door` -> expect `input_required` (T2 step-up) ->
//      approve via `dev.approveAsOwner` -> retry the same tools/call with
//      the returned `requestState` -> expect ALLOWED.
//   3. Child attestation "order the new playstation for 500 euros" ->
//      `tools/call place_order` -> expect DENIED outright (household's
//      dev-seeded child deny-rule for `place_*`, no step-up offered).
//   4. No attestation at all -> `tools/call add_to_list` -> expect DENIED
//      (T1 required, nothing recognised) and `tools/call get_weather` ->
//      expect ALLOWED (T0, no attestation needed).
//
// Usage (server must already be running — `serverpod start` — API on
// :8080, MCP on :8082; both overridable):
//   dart run tool/e2e_alexa_flow.dart
//   dart run tool/e2e_alexa_flow.dart --api http://localhost:8080 --mcp http://localhost:8082/mcp
//
// Exits 0 iff every step's actual outcome matched its expectation, printing
// one PASS/FAIL line per step either way.
import 'dart:convert';
import 'dart:io';

class RpcClient {
  RpcClient(this.baseUrl);
  final String baseUrl;
  final HttpClient _http = HttpClient();

  Future<dynamic> call(String endpoint, String method, Map<String, dynamic> args) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$method');
    final request = await _http.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(args));
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != 200) {
      throw Exception('RPC $endpoint/$method failed (${response.statusCode}): $body');
    }
    if (body.isEmpty) return null;
    return jsonDecode(body);
  }

  void close() => _http.close(force: true);
}

class McpOutcome {
  McpOutcome({required this.decision, this.text, this.requestState});
  final String decision; // ALLOWED | DENIED | APPROVAL_PENDING | ERROR
  final String? text;
  final String? requestState;
}

class McpClientDart {
  McpClientDart(this.mcpUrl, this.token);
  final String mcpUrl;
  final String token;
  final HttpClient _http = HttpClient();
  int _nextId = 1;

  static const protocolVersion = '2026-07-28';

  Future<McpOutcome> callTool(
    String name,
    Map<String, dynamic> args,
    String utterance, {
    String? requestState,
  }) async {
    final params = <String, dynamic>{
      'name': name,
      'arguments': {...args, 'utterance': utterance},
      '_meta': {'io.modelcontextprotocol/protocolVersion': protocolVersion},
      if (requestState != null) 'requestState': requestState,
      if (requestState != null)
        'inputResponses': {
          'challenge': {
            'action': 'accept',
            'content': {'confirm': true},
          },
        },
    };
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': _nextId++,
      'method': 'tools/call',
      'params': params,
    });

    final request = await _http.postUrl(Uri.parse(mcpUrl));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $token');
    request.write(body);
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(text) as Map<String, dynamic>;

    if (decoded['error'] != null) {
      final err = decoded['error'] as Map<String, dynamic>;
      return McpOutcome(decision: 'ERROR', text: '${err['code']}: ${err['message']}');
    }
    final result = decoded['result'] as Map<String, dynamic>?;
    if (result == null) {
      return McpOutcome(decision: 'ERROR', text: 'missing result');
    }
    if (result['resultType'] == 'input_required') {
      return McpOutcome(
        decision: 'APPROVAL_PENDING',
        requestState: result['requestState'] as String?,
        text: 'step-up required',
      );
    }
    final content = (result['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final resultText = content.isNotEmpty ? content.first['text']?.toString() ?? '' : '';
    final isError = result['isError'] as bool? ?? false;
    return McpOutcome(decision: isError ? 'DENIED' : 'ALLOWED', text: resultText);
  }

  void close() => _http.close(force: true);
}

int _passCount = 0;
int _failCount = 0;

void _report(String step, String expected, String actual, {String? detail}) {
  final ok = expected == actual;
  if (ok) {
    _passCount++;
  } else {
    _failCount++;
  }
  final tag = ok ? 'PASS' : 'FAIL';
  final suffix = detail != null ? ' — $detail' : '';
  // ignore: avoid_print
  print('[$tag] $step: expected $expected, got $actual$suffix');
}

Future<void> main(List<String> args) async {
  String apiUrl = 'http://localhost:8080';
  String mcpUrl = 'http://localhost:8082/mcp';
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--api' && i + 1 < args.length) apiUrl = args[++i];
    if (args[i] == '--mcp' && i + 1 < args.length) mcpUrl = args[++i];
  }

  final rpc = RpcClient(apiUrl);

  // ignore: avoid_print
  print('--- Vouch live E2E: Alexa+ flow against $apiUrl / $mcpUrl ---\n');

  // 1. Seed a fresh demo household with a real hub + Ed25519 key.
  final seed = await rpc.call('dev', 'seedDemoHousehold', {
    'ownerName': 'E2E Owner',
    'childName': 'E2E Kid',
    'hubPublicKeyBase64': 'placeholder-overwritten-by-issueTestAttestation',
  }) as Map<String, dynamic>;
  final householdId = seed['householdId'] as int;
  final hubId = seed['hubId'] as int;
  final ownerMemberId = seed['ownerMemberId'] as int;
  final childMemberId = seed['childMemberId'] as int;
  final mcpToken = seed['mcpToken'] as String;
  // ignore: avoid_print
  print(
    'seeded household=$householdId hub=$hubId owner=$ownerMemberId '
    'child=$childMemberId\n',
  );

  final mcp = McpClientDart(mcpUrl, mcpToken);

  // 2. Owner: "unlock the front door" -> step-up -> approve -> retry -> allowed.
  await rpc.call('dev', 'issueTestAttestation', {
    'hubId': hubId,
    'memberId': ownerMemberId,
    'tier': 't1',
    'utterance': 'unlock the front door',
  });
  final unlockFirst = await mcp.callTool(
    'unlock_front_door',
    {},
    'unlock the front door',
  );
  _report(
    'owner unlock_front_door (first call)',
    'APPROVAL_PENDING',
    unlockFirst.decision,
    detail: unlockFirst.text,
  );

  if (unlockFirst.decision == 'APPROVAL_PENDING') {
    final approvalId = await rpc.call('dev', 'latestPendingApprovalId', {
      'householdId': householdId,
    });
    await rpc.call('dev', 'approveAsOwner', {'approvalId': approvalId});
    final unlockRetry = await mcp.callTool(
      'unlock_front_door',
      {},
      'unlock the front door',
      requestState: unlockFirst.requestState,
    );
    _report(
      'owner unlock_front_door (after approval, retry)',
      'ALLOWED',
      unlockRetry.decision,
      detail: unlockRetry.text,
    );
  } else {
    _report('owner unlock_front_door (after approval, retry)', 'ALLOWED', 'SKIPPED');
  }

  // 3. Child: "order the new playstation for 500 euros" -> denied outright.
  await rpc.call('dev', 'issueTestAttestation', {
    'hubId': hubId,
    'memberId': childMemberId,
    'tier': 't1',
    'utterance': 'order the new playstation for 500 euros',
  });
  final childOrder = await mcp.callTool(
    'place_order',
    {'item': 'playstation', 'amount': 500, 'currency': 'EUR'},
    'order the new playstation for 500 euros',
  );
  _report(
    'child place_order (playstation, 500 EUR)',
    'DENIED',
    childOrder.decision,
    detail: childOrder.text,
  );

  // 4. No attestation at all: add_to_list denied (T1 required), get_weather
  // allowed (T0, no attestation needed).
  final noAttestationList = await mcp.callTool(
    'add_to_list',
    {'item': 'milk'},
    'add milk to the shopping list',
  );
  _report(
    'no attestation: add_to_list',
    'DENIED',
    noAttestationList.decision,
    detail: noAttestationList.text,
  );

  final noAttestationWeather = await mcp.callTool(
    'get_weather',
    {},
    "what's the weather today",
  );
  _report(
    'no attestation: get_weather',
    'ALLOWED',
    noAttestationWeather.decision,
    detail: noAttestationWeather.text,
  );

  mcp.close();
  rpc.close();

  // ignore: avoid_print
  print('\n--- $_passCount passed, $_failCount failed ---');
  exit(_failCount == 0 ? 0 : 1);
}
