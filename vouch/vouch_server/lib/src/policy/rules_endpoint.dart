import 'package:serverpod/serverpod.dart';

import '../ai/nebius_client.dart';
import '../ai/tool_risk_classifier.dart';
import '../approval/approval_endpoint.dart';
import '../generated/protocol.dart';
import 'rule_compiler.dart';

/// Serverpod endpoint for the Flutter admin app's Rules screen: preview a
/// plain-language rule (Nemotron-compiled, not saved), confirm it (saved),
/// list a household's rules, and disable one. Owner-only throughout — same
/// `Member.authUserId` -> owner-of-this-household check as
/// `ApprovalEndpoint`/`HouseholdEndpoint`.
class RulesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Compiles [text] into proposed [PolicyRule]s for [householdId] via
  /// Nemotron. Nothing is saved — the Flutter app shows [RulePreviewResult
  /// .proposals] for confirmation and calls [confirm] with whichever the
  /// admin accepts (which may be a subset, or edited).
  Future<RulePreviewResult> preview(
    Session session,
    int householdId,
    String text,
  ) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return RuleCompiler.preview(session, householdId: householdId, text: text);
  }

  /// Re-validates and saves [proposals] as [PolicyRule] rows, all sourced
  /// from [sourceText] (the original plain-language input). All-or-nothing:
  /// if any proposal fails re-validation, nothing is saved.
  Future<List<PolicyRule>> confirm(
    Session session,
    int householdId,
    List<RuleProposal> proposals,
    String sourceText,
  ) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return RuleCompiler.confirm(
      session,
      householdId: householdId,
      proposals: proposals,
      sourceText: sourceText,
    );
  }

  /// Lists every [PolicyRule] (enabled or not) for [householdId].
  Future<List<PolicyRule>> list(Session session, int householdId) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return PolicyRule.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
      orderBy: (t) => t.id,
    );
  }

  /// Disables [ruleId] (`enabled = false`) — rules are never deleted, only
  /// disabled, so the audit trail of "what was ever configured" survives.
  Future<PolicyRule?> disable(Session session, int ruleId) async {
    final rule = await PolicyRule.db.findById(session, ruleId);
    if (rule == null) return null;
    await ApprovalEndpoint.requireOwner(session, rule.householdId);
    final updated = rule.copyWith(enabled: false);
    return PolicyRule.db.updateRow(session, updated);
  }

  /// Owner-only: classifies an unknown tool's risk via
  /// [ToolRiskClassifier] and caches the result in [ToolClassification]
  /// (keyed by tool name, upserted) so the guard path can reuse it instead
  /// of calling Nemotron on every evaluation. [householdId] is only used
  /// to authorize the caller as an owner — the cached result itself is
  /// shared across households, matching the shared MCP tool catalogue.
  Future<ToolClassification> classifyTool(
    Session session,
    int householdId,
    String name,
    String description,
    String inputSchemaJson,
  ) async {
    await ApprovalEndpoint.requireOwner(session, householdId);

    final apiKey = session.passwords['nebiusApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const RuleCompilationException(
        'nebiusApiKey is not configured for this run mode',
      );
    }
    final client = NebiusClient(apiKey: apiKey);
    final result = await ToolRiskClassifier.classify(
      client,
      name: name,
      description: description,
      inputSchemaJson: inputSchemaJson,
    );

    final existing = await ToolClassification.db.findFirstRow(
      session,
      where: (t) => t.toolName.equals(name),
    );
    final row = ToolClassification(
      toolName: name,
      tier: result.tier,
      reason: result.reason,
      model: NebiusClient.modelFast,
      createdAt: DateTime.now().toUtc(),
    );
    if (existing == null) {
      return ToolClassification.db.insertRow(session, row);
    }
    return ToolClassification.db.updateRow(
      session,
      row.copyWith(id: existing.id),
    );
  }
}
