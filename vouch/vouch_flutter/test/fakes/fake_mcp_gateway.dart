import 'package:vouch_flutter/data/mcp/mcp_gateway.dart';

/// A scripted [McpGateway] for widget tests — no real HTTP call, just a
/// fixed queue of results returned in order (one per `callTool`).
class FakeMcpGateway implements McpGateway {
  FakeMcpGateway(this._results);

  final List<McpCallResult> _results;
  int _i = 0;
  final calls = <String>[];
  final requestStates = <String?>[];

  @override
  Future<McpCallResult> callTool({
    required String toolName,
    required Map<String, dynamic> args,
    required String utterance,
    String? requestState,
    Map<String, dynamic>? inputResponses,
  }) async {
    calls.add(toolName);
    requestStates.add(requestState);
    final result = _results[_i.clamp(0, _results.length - 1)];
    if (_i < _results.length - 1) _i++;
    return result;
  }

  String? verdictHtmlToReturn;

  @override
  Future<String?> fetchResourceHtml(String uri) async => verdictHtmlToReturn;
}
