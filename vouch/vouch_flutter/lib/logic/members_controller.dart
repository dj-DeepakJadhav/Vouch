import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/repositories/household_repository.dart';

/// Backs the Members screen: members plus, where present, their enrolment
/// status (quality, sample count) via `HouseholdRepository.enrolments`.
class MembersController extends ChangeNotifier {
  MembersController({required HouseholdRepository repository, required this.householdId})
      : _repository = repository;

  final HouseholdRepository _repository;
  final int householdId;

  List<Member> members = [];
  Map<int, Enrolment> enrolmentByMemberId = {};
  bool loading = true;
  Object? error;

  /// Member ids with a revoke/restore call in flight, so the Members screen
  /// can disable that member's action button and avoid a double-submit.
  final Set<int> pendingMemberIds = {};

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.members(householdId),
        _repository.enrolments(householdId),
      ]);
      members = results[0] as List<Member>;
      final enrolments = results[1] as List<Enrolment>;
      enrolmentByMemberId = {
        for (final e in enrolments) e.memberId: e,
      };
      error = null;
    } catch (e) {
      error = e;
    }
    loading = false;
    notifyListeners();
  }

  /// Revokes [member]'s voice trust immediately. On success, updates the
  /// member locally to `MemberStatus.revoked` so the Members screen reflects
  /// it without waiting for a full reload — the live household feed (Home /
  /// Activity) picks up the audit event on its own stream.
  Future<void> revokeMember(Member member) async {
    final id = member.id;
    if (id == null || pendingMemberIds.contains(id)) return;
    pendingMemberIds.add(id);
    notifyListeners();
    try {
      final updated = await _repository.revokeMember(id);
      _replaceMember(updated);
      error = null;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      pendingMemberIds.remove(id);
      notifyListeners();
    }
  }

  /// Restores [member] back to active, so future attestations can be minted
  /// for them again.
  Future<void> restoreMember(Member member) async {
    final id = member.id;
    if (id == null || pendingMemberIds.contains(id)) return;
    pendingMemberIds.add(id);
    notifyListeners();
    try {
      final updated = await _repository.restoreMember(id);
      _replaceMember(updated);
      error = null;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      pendingMemberIds.remove(id);
      notifyListeners();
    }
  }

  void _replaceMember(Member updated) {
    members = [
      for (final m in members)
        if (m.id == updated.id) updated else m,
    ];
  }
}
