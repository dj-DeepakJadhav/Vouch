import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/data/repositories/approval_repository.dart';
import 'package:vouch_flutter/data/repositories/audit_repository.dart';
import 'package:vouch_flutter/data/repositories/demo_repository.dart';
import 'package:vouch_flutter/data/repositories/household_repository.dart';
import 'package:vouch_flutter/data/repositories/rules_repository.dart';

/// In-memory fakes for every repository interface, used by widget tests so
/// no test ever talks to a real Serverpod client (VOUCH task D2 item 10).

class FakeHouseholdRepository implements HouseholdRepository {
  FakeHouseholdRepository({
    required this.overview,
    List<Enrolment>? enrolments,
  }) : _enrolments = enrolments ?? [],
       _members = List.of(overview.members);

  final HouseholdOverview overview;
  final List<Enrolment> _enrolments;
  final List<Member> _members;
  final _controller = <HouseholdEvent>[];

  /// Member ids the test asked to fail on revoke/restore, e.g. to exercise
  /// the Members screen's error handling.
  final Set<int> failMemberIds = {};

  final List<int> revokedMemberIds = [];
  final List<int> restoredMemberIds = [];

  @override
  Future<HouseholdOverview> myHousehold() async => overview;

  @override
  Future<List<Member>> members(int householdId) async => _members;

  @override
  Future<List<Enrolment>> enrolments(int householdId) async => _enrolments;

  @override
  Stream<HouseholdEvent> householdStatus(int householdId) =>
      Stream.fromIterable(_controller);

  @override
  Future<Member> revokeMember(int memberId) =>
      _setStatus(memberId, MemberStatus.revoked, revokedMemberIds);

  @override
  Future<Member> restoreMember(int memberId) =>
      _setStatus(memberId, MemberStatus.active, restoredMemberIds);

  Future<Member> _setStatus(
    int memberId,
    MemberStatus status,
    List<int> log,
  ) async {
    if (failMemberIds.contains(memberId)) {
      throw Exception('fake failure for member $memberId');
    }
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index == -1) {
      throw Exception('unknown member $memberId');
    }
    final updated = _members[index].copyWith(status: status);
    _members[index] = updated;
    log.add(memberId);
    return updated;
  }
}

class FakeApprovalRepository implements ApprovalRepository {
  FakeApprovalRepository({List<Approval>? pending}) : _pending = pending ?? [];

  final List<Approval> _pending;
  final Map<int, Approval> decided = {};

  @override
  Future<List<Approval>> listPending(int householdId) async => _pending;

  @override
  Future<Approval?> decide(int approvalId, bool approve) async {
    final existing = _pending.firstWhere((a) => a.id == approvalId);
    final updated = existing.copyWith(
      status: approve ? ApprovalStatus.approved : ApprovalStatus.denied,
      decidedAt: DateTime.now().toUtc(),
    );
    decided[approvalId] = updated;
    return updated;
  }

  @override
  Stream<Approval> pendingApprovals(int householdId) => const Stream.empty();
}

class FakeRulesRepository implements RulesRepository {
  FakeRulesRepository({
    List<PolicyRule>? rules,
    this.previewResult,
    this.previewError,
  }) : rules = rules ?? [];

  List<PolicyRule> rules;
  RulePreviewResult? previewResult;
  Object? previewError;

  @override
  Future<List<PolicyRule>> list(int householdId) async => rules;

  @override
  Future<RulePreviewResult> preview(int householdId, String text) async {
    if (previewError != null) throw previewError!;
    return previewResult!;
  }

  @override
  Future<List<PolicyRule>> confirm(
    int householdId,
    List<RuleProposal> proposals,
    String sourceText,
  ) async {
    final saved = [
      for (final p in proposals)
        PolicyRule(
          householdId: householdId,
          memberId: p.memberId,
          role: p.role,
          actionPattern: p.actionPattern,
          requiredTier: p.requiredTier,
          effect: p.effect,
          sourceText: sourceText,
          argConditions: p.argConditions,
          enabled: true,
        ),
    ];
    rules = [...rules, ...saved];
    return saved;
  }

  @override
  Future<PolicyRule?> disable(int ruleId) async {
    final i = rules.indexWhere((r) => r.id == ruleId);
    if (i < 0) return null;
    final updated = rules[i].copyWith(enabled: false);
    rules[i] = updated;
    return updated;
  }
}

class FakeAuditRepository implements AuditRepository {
  FakeAuditRepository({List<AuditEvent>? events}) : events = events ?? [];

  List<AuditEvent> events;

  @override
  Future<List<AuditEvent>> listRecent(
    int householdId, {
    int page = 0,
    int pageSize = 25,
  }) async => events;
}

class FakeDemoRepository implements DemoRepository {
  FakeDemoRepository({this.token = 'fake-token'});

  final String token;

  /// `(memberId, utterance)` for every attestation the demo path issued.
  final List<(int, String)> issuedAttestations = [];

  int starts = 0;

  @override
  Future<DemoStart> start() async {
    starts++;
    return DemoStart(
      householdId: 1,
      hubId: 2,
      ownerMemberId: 3,
      childMemberId: 4,
    );
  }

  @override
  Future<String> mintMcpToken(int householdId) async => token;

  @override
  Future<void> attest({
    required int hubId,
    required int memberId,
    required String utterance,
  }) async {
    issuedAttestations.add((memberId, utterance));
    throw UnimplementedError('fake: attestation is recorded only');
  }
}
