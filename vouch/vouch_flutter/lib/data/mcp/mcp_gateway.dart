import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:vouch_client/vouch_client.dart';

import '../../app/theme.dart' show tierLabel;

/// One tick/cross/hourglass step of the Alexa simulator's decision-trace
/// panel. [tier] (when set) tints the step with the tier colour
/// (T0 grey/T1 blue/T2 amber — see app/theme.dart's `tierColor`), so the
/// panel reads at a glance which tier was in play for that step.
class TraceStep {
  const TraceStep({
    required this.label,
    required this.status,
    this.detail,
    this.tier,
  });

  final String label;
  final TraceStepStatus status;
  final String? detail;
  final TrustTier? tier;
}

/// [skipped] is a step that did not apply ("Not required"): it gets a dash,
/// never a check mark.
enum TraceStepStatus { ok, fail, pending, skipped }

/// A readable one-liner for a tool call, e.g. "Order: new PlayStation · EUR
/// 500", instead of the raw `place_order({...})` JSON.
String describeToolCall(String toolName, Map<String, dynamic> args) {
  String amount(Object? v) {
    if (v is num && v == v.roundToDouble()) return v.round().toString();
    return '$v';
  }

  switch (toolName) {
    case 'place_order':
      return 'Order: ${args['item'] ?? 'item'} · '
          '${args['currency'] ?? 'EUR'} ${amount(args['amount'])}';
    case 'unlock_front_door':
      return 'Unlock the front door';
    case 'add_to_list':
      return 'Add to the shopping list: ${args['item'] ?? 'item'}';
    case 'send_message':
      return 'Message to ${args['to'] ?? '?'}: ${args['text'] ?? ''}';
    case 'get_weather':
      return 'Weather';
    case 'play_music':
      return 'Play music';
    case 'read_calendar':
      return 'Read the calendar';
    default:
      return toolName;
  }
}

/// Outcome of one `tools/call` (or retry) against the real MCP endpoint,
/// modern era (2026-07-28): either it completed, failed, or needs input
/// (MRTR `input_required`) — see vouch_server's mcp_route.dart for the
/// exact response shapes this mirrors.
sealed class McpCallResult {
  const McpCallResult(this.steps, {this.vouch});
  final List<TraceStep> steps;

  /// Raw `structuredContent.vouch` (see vouch_server's `VouchTrace.toJson`),
  /// carried through so the caller can drive the `ui://vouch/verdict` MCP
  /// Apps card without re-deriving it from [steps].
  final Map<String, dynamic>? vouch;
}

class McpComplete extends McpCallResult {
  const McpComplete(
    super.steps, {
    required this.text,
    required this.isError,
    super.vouch,
  });
  final String text;
  final bool isError;
}

class McpInputRequired extends McpCallResult {
  const McpInputRequired(
    super.steps, {
    required this.requestState,
    required this.message,
    super.vouch,
  });
  final String requestState;
  final String message;
}

class McpProtocolError extends McpCallResult {
  const McpProtocolError(super.steps, {required this.message});
  final String message;
}

/// Talks to the real MCP endpoint (POST /mcp) over Streamable HTTP, modern
/// era only (`_meta["io.modelcontextprotocol/protocolVersion"] =
/// "2026-07-28"`), per vouch-mcp-alexa. Abstracted behind [McpGateway] so
/// widget tests can substitute a fake instead of making real HTTP calls.
abstract class McpGateway {
  Future<McpCallResult> callTool({
    required String toolName,
    required Map<String, dynamic> args,
    required String utterance,
    String? requestState,
    Map<String, dynamic>? inputResponses,
  });

  /// Fetches an MCP Apps `ui://` resource's HTML via `resources/read`
  /// (SEP-1865, stable spec 2026-01-26 — field names verified against
  /// specification/2026-01-26/apps.mdx in modelcontextprotocol/ext-apps;
  /// see vouch_server's verdict_card.dart doc comment). Returns null if the
  /// server doesn't have the resource or the call fails.
  Future<String?> fetchResourceHtml(String uri);
}

class HttpMcpGateway implements McpGateway {
  HttpMcpGateway({
    required this.mcpUrl,
    required this.bearerToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String mcpUrl;
  final String bearerToken;
  final http.Client _http;

  static const String protocolVersion = '2026-07-28';

  int _nextId = 1;

  @override
  Future<McpCallResult> callTool({
    required String toolName,
    required Map<String, dynamic> args,
    required String utterance,
    String? requestState,
    Map<String, dynamic>? inputResponses,
  }) async {
    final steps = <TraceStep>[
      TraceStep(
        label: 'Request',
        status: TraceStepStatus.ok,
        detail: describeToolCall(toolName, args),
      ),
    ];

    final params = <String, dynamic>{
      'name': toolName,
      'arguments': {...args, 'utterance': utterance},
      '_meta': {'io.modelcontextprotocol/protocolVersion': protocolVersion},
      if (requestState != null) 'requestState': requestState,
      if (inputResponses != null) 'inputResponses': inputResponses,
    };

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': _nextId++,
      'method': 'tools/call',
      'params': params,
    });

    http.Response response;
    try {
      response = await _http.post(
        Uri.parse(mcpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: body,
      );
    } catch (e) {
      return McpProtocolError(
        [
          ...steps,
          TraceStep(
            label: 'Transport',
            status: TraceStepStatus.fail,
            detail: '$e',
          ),
        ],
        message: 'Could not reach the MCP server: $e',
      );
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return McpProtocolError(
        [
          ...steps,
          TraceStep(
            label: 'Transport',
            status: TraceStepStatus.fail,
            detail: 'HTTP ${response.statusCode}: non-JSON response',
          ),
        ],
        message: 'Malformed response (HTTP ${response.statusCode}).',
      );
    }

    if (decoded['error'] != null) {
      final err = decoded['error'] as Map<String, dynamic>;
      return McpProtocolError(
        [
          ...steps,
          TraceStep(
            label: 'Protocol',
            status: TraceStepStatus.fail,
            detail: '${err['code']}: ${err['message']}',
          ),
        ],
        message: err['message']?.toString() ?? 'protocol error',
      );
    }

    final result = decoded['result'] as Map<String, dynamic>?;
    if (result == null) {
      return McpProtocolError(
        [
          ...steps,
          const TraceStep(
            label: 'Protocol',
            status: TraceStepStatus.fail,
            detail: 'missing result',
          ),
        ],
        message: 'Missing result in response.',
      );
    }

    final resultType = result['resultType'] as String?;
    final structuredContent =
        result['structuredContent'] as Map<String, dynamic>?;
    final vouch = structuredContent?['vouch'] as Map<String, dynamic>?;
    final vouchSteps = vouch == null
        ? const <TraceStep>[]
        : buildVouchTraceSteps(utterance: utterance, vouch: vouch);

    if (resultType == 'input_required') {
      final inputRequests = result['inputRequests'] as Map<String, dynamic>?;
      final challenge = inputRequests?['challenge'] as Map<String, dynamic>?;
      final message =
          (challenge?['params'] as Map<String, dynamic>?)?['message']
              as String? ??
          'Approval required.';
      return McpInputRequired(
        [...steps, ...vouchSteps],
        requestState: result['requestState'] as String,
        message: message,
        vouch: vouch,
      );
    }

    final content =
        (result['content'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final text = content.isNotEmpty
        ? content.first['text']?.toString() ?? ''
        : '';
    final isError = result['isError'] as bool? ?? false;

    return McpComplete(
      [...steps, ...vouchSteps],
      text: text,
      isError: isError,
      vouch: vouch,
    );
  }

  @override
  Future<String?> fetchResourceHtml(String uri) async {
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': _nextId++,
      'method': 'resources/read',
      'params': {
        'uri': uri,
        '_meta': {'io.modelcontextprotocol/protocolVersion': protocolVersion},
      },
    });
    try {
      final response = await _http.post(
        Uri.parse(mcpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: body,
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final result = decoded['result'] as Map<String, dynamic>?;
      final contents = (result?['contents'] as List?)
          ?.cast<Map<String, dynamic>>();
      if (contents == null || contents.isEmpty) return null;
      return contents.first['text'] as String?;
    } catch (_) {
      return null;
    }
  }
}

/// Turns a `structuredContent.vouch` trace (see vouch_server's
/// mcp_guard.dart `VouchTrace`) into the Alexa simulator's 6-step decision
/// trace: Heard -> Voice recognised -> Transcript matches Alexa -> Rule ->
/// Owner approval -> Result. This is the core of the pitch — it shows WHO
/// SPOKE, not just whether the call was allowed.
List<TraceStep> buildVouchTraceSteps({
  required String utterance,
  required Map<String, dynamic> vouch,
}) {
  final speaker = vouch['speaker'] as Map<String, dynamic>?;
  final confidence = (vouch['confidence'] as num?)?.toDouble();
  final attestationMatched = vouch['attestationMatched'] as bool? ?? false;
  final matchedTranscript = vouch['matchedTranscript'] as String?;
  final requiredTierName = vouch['requiredTier'] as String?;
  final presentTierName = vouch['presentTier'] as String?;
  final decision = vouch['decision'] as String?;
  final reason = vouch['reason'] as String?;
  final ruleSource = vouch['ruleSource'] as String?;

  final requiredTier = _tierFromName(requiredTierName);
  final presentTier = _tierFromName(presentTierName);

  final heard = TraceStep(
    label: 'Heard',
    status: TraceStepStatus.ok,
    detail: '"$utterance"',
  );

  final voiceRecognised = speaker == null
      ? const TraceStep(
          label: 'Voice recognised',
          status: TraceStepStatus.fail,
          detail: 'Not recognised',
        )
      : TraceStep(
          label: 'Voice recognised',
          status: TraceStepStatus.ok,
          detail:
              '${speaker['displayName']} · ${speaker['role']}'
              '${confidence != null ? ' · ${(confidence * 100).round()}%' : ''}',
        );

  final transcriptMatches = TraceStep(
    label: 'Transcript matches Alexa',
    status: attestationMatched ? TraceStepStatus.ok : TraceStepStatus.fail,
    detail: matchedTranscript == null
        ? 'No matching voice attestation for this utterance'
        : '"$matchedTranscript"',
  );

  final ruleStep = TraceStep(
    label: 'Rule',
    status: decision == 'deny' ? TraceStepStatus.fail : TraceStepStatus.ok,
    detail:
        '${ruleSource ?? 'Default policy'} · needs '
        '${requiredTier == null ? '?' : tierLabel(requiredTier)}, had '
        '${presentTier == null ? '?' : tierLabel(presentTier)}',
    tier: requiredTier ?? presentTier,
  );

  final TraceStepStatus approvalStatus;
  final String approvalDetail;
  switch (decision) {
    case 'stepUp':
    case 'pending':
      approvalStatus = TraceStepStatus.pending;
      approvalDetail = "Waiting on the owner's phone…";
    case 'approved':
      approvalStatus = TraceStepStatus.ok;
      approvalDetail = 'Approved by the owner';
    case 'denied':
    case 'expired':
      approvalStatus = TraceStepStatus.fail;
      approvalDetail = decision == 'expired'
          ? 'Approval window expired'
          : 'Denied by the owner';
    default:
      approvalStatus = TraceStepStatus.skipped;
      approvalDetail = 'Not required';
  }
  final ownerApproval = TraceStep(
    label: 'Owner approval',
    status: approvalStatus,
    detail: approvalDetail,
    tier: TrustTier.t2,
  );

  final resultOk = decision == 'allow' || decision == 'approved';
  final resultWaiting = decision == 'stepUp' || decision == 'pending';
  final resultStep = TraceStep(
    label: 'Result',
    status: resultOk
        ? TraceStepStatus.ok
        : resultWaiting
        ? TraceStepStatus.pending
        : TraceStepStatus.fail,
    detail: resultWaiting ? 'Waiting for the owner' : reason,
  );

  return [
    heard,
    voiceRecognised,
    transcriptMatches,
    ruleStep,
    ownerApproval,
    resultStep,
  ];
}

TrustTier? _tierFromName(String? name) {
  if (name == null) return null;
  for (final t in TrustTier.values) {
    if (t.name == name) return t;
  }
  return null;
}

/// Generates a short client-side correlation id for the trace panel only
/// (not part of the MCP protocol itself).
String newTraceId() => Random().nextInt(1 << 32).toRadixString(16);

/// Merges a retry leg's trace into the fresh call's trace. A retry carries
/// no attestation of its own (the server's retry trace only knows the
/// approval), so the evidence steps — Heard, Voice recognised, Transcript
/// matches Alexa, Rule — stay as the fresh call reported them; only the
/// approval outcome and the result are taken from the retry. Without this a
/// paraphrased (near-miss) command would flip to "Transcript matches" on the
/// first poll.
List<TraceStep> mergeRetryTrace(List<TraceStep> first, List<TraceStep> retry) {
  if (first.isEmpty) return retry;
  const fromRetry = {'Owner approval', 'Result'};
  final byLabel = {for (final s in retry) s.label: s};
  return [
    for (final s in first)
      fromRetry.contains(s.label) ? (byLabel[s.label] ?? s) : s,
  ];
}

/// Same idea for the raw `structuredContent.vouch` map that feeds the
/// verdict card: keep the fresh call's evidence, take the retry's verdict.
Map<String, dynamic>? mergeRetryVouch(
  Map<String, dynamic>? first,
  Map<String, dynamic>? retry,
) {
  if (first == null || retry == null) return retry ?? first;
  return {...first, 'decision': retry['decision'], 'reason': retry['reason']};
}
