import 'dart:async';
import 'dart:convert';

import '../generated/protocol.dart';
import 'model_routing.dart';
import 'nebius_client.dart';

/// The result of classifying an unknown tool's risk. Always produced — a
/// classification failure never throws past [ToolRiskClassifier.classify];
/// it is folded into a fail-safe [tier] of [TrustTier.t2] instead (see
/// class doc).
class ToolRiskClassification {
  const ToolRiskClassification({required this.tier, required this.reason});

  final TrustTier tier;
  final String reason;

  Map<String, dynamic> toJson() => {'tier': tier.name, 'reason': reason};
}

/// Classifies an MCP tool the household has no explicit rule for, and that
/// has no built-in default tier, into a minimum trust tier — via a fast
/// Nemotron call (see [ModelRouting.toolRiskClassification]).
///
/// This is a *risk signal for an unrecognised tool*, never a security
/// boundary on its own: any error, timeout, or output that doesn't
/// strictly validate fails SAFE to [TrustTier.t2] (the highest tier,
/// always requiring a fresh step-up) rather than ever silently loosening
/// access. Nothing here is trusted at face value — see [_parse].
class ToolRiskClassifier {
  const ToolRiskClassifier._();

  static const _failSafe = ToolRiskClassification(
    tier: TrustTier.t2,
    reason: 'classification unavailable; failing safe to the highest tier',
  );

  static const Duration _timeout = Duration(seconds: 8);

  static String _buildPrompt({
    required String name,
    required String description,
    required String inputSchemaJson,
  }) {
    return '''
You assess the risk of a tool a voice assistant (Alexa+) might be asked to
call on behalf of a household, for a step-up voice authentication gateway.
Classify it into the MINIMUM trust tier that should be required before it
may run:

- "t0": no risk — read-only, no side effects outside trivial personal
  convenience (e.g. weather, time, playing music).
- "t1": a low-stakes action with a reversible or minor side effect (e.g.
  adding an item to a list, reading private-but-non-sensitive data).
- "t2": anything involving money, physical access (locks/doors/garage),
  sending communications on the household's behalf, changing security or
  account settings, deleting/destroying data, or anything whose blast
  radius you are not confident is small. When genuinely unsure, choose t2.

Tool name: $name
Tool description: $description
Tool input schema (JSON Schema): $inputSchemaJson

Reply with ONLY a JSON object of the exact form {"tier": "t0"|"t1"|"t2",
"reason": "<one short plain-English sentence>"}. No other fields, no prose
outside the JSON object.
''';
  }

  /// Classifies [name]/[description]/[inputSchemaJson] via [client]. Never
  /// throws: any transport failure, timeout, non-JSON output, or output
  /// missing/mis-typing a required field is caught and converted to the
  /// fail-safe t2 result.
  static Future<ToolRiskClassification> classify(
    NebiusChatCompleter client, {
    required String name,
    required String description,
    required String inputSchemaJson,
  }) async {
    final prompt = _buildPrompt(
      name: name,
      description: description,
      inputSchemaJson: inputSchemaJson,
    );
    try {
      final result = await client
          .chatCompletion(
            model: ModelRouting.toolRiskClassification,
            messages: [
              {'role': 'user', 'content': prompt},
            ],
            responseFormat: const {'type': 'json_object'},
          )
          .timeout(_timeout);
      return _parse(result.content);
    } on TimeoutException {
      return _failSafe;
    } on NebiusApiException {
      // Structured output may not be supported; try once more without it
      // before giving up and failing safe.
      try {
        final result = await client
            .chatCompletion(
              model: ModelRouting.toolRiskClassification,
              messages: [
                {'role': 'user', 'content': prompt},
              ],
            )
            .timeout(_timeout);
        return _parse(result.content);
      } catch (_) {
        return _failSafe;
      }
    } catch (_) {
      return _failSafe;
    }
  }

  /// Strictly parses and validates model output. Anything that doesn't
  /// come back as exactly `{"tier": "t0"|"t1"|"t2", "reason": "<non-empty
  /// string>"}` (garbage, extra/missing fields, wrong types, an invalid
  /// tier name) is treated as a classification failure, not "best effort"
  /// — this is what keeps a misbehaving or manipulated model response from
  /// ever granting a tier looser than the safe default.
  static ToolRiskClassification _parse(String content) {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      return _failSafe;
    }
    if (decoded is! Map) return _failSafe;

    final tierRaw = decoded['tier'];
    if (tierRaw is! String) return _failSafe;
    final tier = TrustTier.values.where((t) => t.name == tierRaw).toList();
    if (tier.length != 1) return _failSafe;

    final reasonRaw = decoded['reason'];
    if (reasonRaw is! String || reasonRaw.isEmpty) return _failSafe;

    return ToolRiskClassification(tier: tier.single, reason: reasonRaw);
  }
}
