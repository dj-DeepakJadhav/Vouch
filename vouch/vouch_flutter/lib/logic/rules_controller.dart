import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/repositories/rules_repository.dart';

/// Backs the Rules screen: existing rules, plus the preview -> confirm flow
/// for a plain-language rule (Nemotron-compiled server-side).
class RulesController extends ChangeNotifier {
  RulesController({required RulesRepository repository, required this.householdId})
      : _repository = repository;

  final RulesRepository _repository;
  final int householdId;

  List<PolicyRule> rules = [];
  bool loading = true;
  Object? error;

  RulePreviewResult? preview;
  bool previewing = false;
  Object? previewError;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      rules = await _repository.list(householdId);
      error = null;
    } catch (e) {
      error = e;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> requestPreview(String text) async {
    previewing = true;
    previewError = null;
    preview = null;
    notifyListeners();
    try {
      preview = await _repository.preview(householdId, text);
    } catch (e) {
      previewError = e;
    }
    previewing = false;
    notifyListeners();
  }

  void clearPreview() {
    preview = null;
    previewError = null;
    notifyListeners();
  }

  Future<void> confirm(List<RuleProposal> proposals, String sourceText) async {
    final saved = await _repository.confirm(householdId, proposals, sourceText);
    rules = [...rules, ...saved];
    preview = null;
    notifyListeners();
  }

  Future<void> disable(int ruleId) async {
    final updated = await _repository.disable(ruleId);
    if (updated != null) {
      rules = [for (final r in rules) r.id == ruleId ? updated : r];
      notifyListeners();
    }
  }
}
