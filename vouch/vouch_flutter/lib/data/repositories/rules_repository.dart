import 'package:vouch_client/vouch_client.dart';

abstract class RulesRepository {
  Future<RulePreviewResult> preview(int householdId, String text);
  Future<List<PolicyRule>> confirm(
    int householdId,
    List<RuleProposal> proposals,
    String sourceText,
  );
  Future<List<PolicyRule>> list(int householdId);
  Future<PolicyRule?> disable(int ruleId);
}

class ServerpodRulesRepository implements RulesRepository {
  ServerpodRulesRepository(this._client);

  final Client _client;

  @override
  Future<RulePreviewResult> preview(int householdId, String text) =>
      _client.rules.preview(householdId, text);

  @override
  Future<List<PolicyRule>> confirm(
    int householdId,
    List<RuleProposal> proposals,
    String sourceText,
  ) => _client.rules.confirm(householdId, proposals, sourceText);

  @override
  Future<List<PolicyRule>> list(int householdId) =>
      _client.rules.list(householdId);

  @override
  Future<PolicyRule?> disable(int ruleId) => _client.rules.disable(ruleId);
}
