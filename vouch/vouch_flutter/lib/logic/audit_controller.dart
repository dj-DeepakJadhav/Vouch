import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/repositories/audit_repository.dart';

/// Backs the Activity screen: the append-only audit log, newest first, with
/// a "blocked/denied first" toggle (VOUCH task D2 item 6).
class AuditController extends ChangeNotifier {
  AuditController({required AuditRepository repository, required this.householdId})
      : _repository = repository;

  final AuditRepository _repository;
  final int householdId;

  List<AuditEvent> events = [];
  bool loading = true;
  Object? error;
  bool blockedOnlyFirst = false;

  List<AuditEvent> get sorted {
    final list = [...events];
    if (blockedOnlyFirst) {
      list.sort((a, b) {
        final aBlocked = _isBlocked(a) ? 0 : 1;
        final bBlocked = _isBlocked(b) ? 0 : 1;
        if (aBlocked != bBlocked) return aBlocked.compareTo(bBlocked);
        return b.createdAt.compareTo(a.createdAt);
      });
    }
    return list;
  }

  static bool _isBlocked(AuditEvent e) =>
      e.decision == AuditDecision.denied || e.decision == AuditDecision.revoked;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      events = await _repository.listRecent(householdId, pageSize: 100);
      error = null;
    } catch (e) {
      error = e;
    }
    loading = false;
    notifyListeners();
  }

  void toggleBlockedFirst() {
    blockedOnlyFirst = !blockedOnlyFirst;
    notifyListeners();
  }
}
