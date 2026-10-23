import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/repositories/approval_repository.dart';
import 'friendly_error.dart';

/// Backs the Approvals screen: the live pending list (via
/// `ApprovalRepository.pendingApprovals`) plus a small trailing history of
/// just-decided approvals so a card doesn't just vanish the instant it's
/// decided (VOUCH task D2 item 4: "Show decided state").
class ApprovalsController extends ChangeNotifier {
  ApprovalsController({
    required ApprovalRepository repository,
    required this.householdId,
  }) : _repository = repository;

  final ApprovalRepository _repository;
  final int householdId;

  final Map<int, Approval> _byId = {};
  StreamSubscription<Approval>? _sub;
  bool loading = true;
  Object? error;

  List<Approval> get approvals =>
      _byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get pendingCount =>
      _byId.values.where((a) => a.status == ApprovalStatus.pending).length;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final pending = await _repository.listPending(householdId);
      for (final a in pending) {
        if (a.id != null) _byId[a.id!] = a;
      }
      loading = false;
      notifyListeners();
      _sub ??= _repository.pendingApprovals(householdId).listen((a) {
        if (a.id != null) {
          _byId[a.id!] = a;
          notifyListeners();
        }
      });
    } catch (e) {
      error = e;
      loading = false;
      notifyListeners();
    }
  }

  /// Decides [approvalId]. Returns null on success, else a short
  /// user-facing message (never the raw server exception).
  Future<String?> decide(int approvalId, bool approve) async {
    try {
      final decided = await _repository.decide(approvalId, approve);
      if (decided == null) return 'That request no longer exists.';
      _byId[approvalId] = decided;
      notifyListeners();
      if (decided.status == ApprovalStatus.expired) {
        return 'Too late: this request expired before you decided.';
      }
      return null;
    } catch (e) {
      return friendlyError(e, what: approve ? 'approve' : 'deny');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
