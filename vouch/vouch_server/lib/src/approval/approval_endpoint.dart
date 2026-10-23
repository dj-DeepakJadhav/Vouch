import 'package:serverpod/serverpod.dart';

import '../audit/audit_service.dart';
import '../generated/protocol.dart';

/// Thrown when the authenticated caller is not the household owner (or not
/// resolvable to a `Member` at all) for an approval-scoped operation.
class NotHouseholdOwnerException implements Exception {
  NotHouseholdOwnerException(this.message);
  final String message;
  @override
  String toString() => 'NotHouseholdOwnerException: $message';
}

/// Serverpod endpoint for the Flutter admin app: list pending T2 step-up
/// approvals for a household and decide them (approve/deny).
///
/// Authorization: the authenticated Serverpod user must resolve (via
/// `Member.authUserId`) to a `Member` row that is `role == owner` AND
/// belongs to the household the approval/query is scoped to. A child,
/// adult or guest — even if signed in — is rejected. This closes the gap
/// noted in VOUCH-PLAN.md §5 ("a child could approve their own purchase").
class ApprovalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _channelPrefix = 'approval-created-household-';

  /// Resolves `session.authenticated`'s user id to an owner `Member` row
  /// scoped to [householdId]. Throws [NotHouseholdOwnerException] if the
  /// caller is not signed in, has no linked `Member`, is not `role ==
  /// owner`, or belongs to a different household.
  ///
  /// Public (not `_`-prefixed) so other owner-scoped endpoints — currently
  /// `HouseholdEndpoint.householdStatus` — can reuse the exact same
  /// authorization rule instead of duplicating it.
  static Future<Member> requireOwner(Session session, int householdId) async {
    final authInfo = session.authenticated;
    final authUserId = authInfo?.userIdentifier;
    if (authUserId == null) {
      throw NotHouseholdOwnerException('not signed in');
    }

    final member = await Member.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (member == null) {
      throw NotHouseholdOwnerException(
        'signed-in user is not linked to any household member',
      );
    }
    if (member.role != MemberRole.owner) {
      throw NotHouseholdOwnerException(
        'signed-in member is not the household owner',
      );
    }
    if (member.householdId != householdId) {
      throw NotHouseholdOwnerException(
        'signed-in owner does not belong to this household',
      );
    }
    return member;
  }

  /// Resolves `session.authenticated` to an owner `Member` row without a
  /// caller-supplied household id to check against — for endpoints like
  /// `HouseholdEndpoint.myHousehold` that are the very first call a
  /// just-signed-in Flutter app makes and don't yet know any household id.
  /// Throws [NotHouseholdOwnerException] under the same conditions as
  /// [requireOwner], minus the "wrong household" check (there is no
  /// caller-supplied household to be wrong about).
  static Future<Member> requireOwnerBySignedInUser(Session session) async {
    final authInfo = session.authenticated;
    final authUserId = authInfo?.userIdentifier;
    if (authUserId == null) {
      throw NotHouseholdOwnerException('not signed in');
    }

    final member = await Member.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (member == null) {
      throw NotHouseholdOwnerException(
        'signed-in user is not linked to any household member',
      );
    }
    if (member.role != MemberRole.owner) {
      throw NotHouseholdOwnerException(
        'signed-in member is not the household owner',
      );
    }
    return member;
  }

  Future<List<Approval>> listPending(Session session, int householdId) async {
    await requireOwner(session, householdId);
    return Approval.db.find(
      session,
      where: (t) =>
          t.householdId.equals(householdId) &
          t.status.equals(ApprovalStatus.pending),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Future<Approval?> decide(
    Session session,
    int approvalId,
    bool approve,
  ) async {
    final approval = await Approval.db.findById(session, approvalId);
    if (approval == null) return null;

    // Authorize against the approval's OWN household — never trust a
    // caller-supplied household id for this check.
    final owner = await requireOwner(session, approval.householdId);

    return decideInternal(
      session,
      approvalId: approvalId,
      approve: approve,
      deciderMemberId: owner.id,
    );
  }

  /// The actual decide logic, with no authorization check of its own —
  /// callers (the public [decide] method, and `DevEndpoint.approveAsOwner`
  /// for the dev-only terminal demo) are responsible for authorizing the
  /// caller first. Kept as a single shared code path so policy/audit
  /// behaviour is identical regardless of who is deciding.
  static Future<Approval?> decideInternal(
    Session session, {
    required int approvalId,
    required bool approve,
    int? deciderMemberId,
  }) async {
    final approval = await Approval.db.findById(session, approvalId);
    if (approval == null) return null;
    if (approval.status != ApprovalStatus.pending) return approval;

    final now = DateTime.now().toUtc();
    if (now.isAfter(approval.expiresAt)) {
      final expired = approval.copyWith(
        status: ApprovalStatus.expired,
        decidedAt: now,
      );
      return Approval.db.updateRow(session, expired);
    }

    final updated = approval.copyWith(
      status: approve ? ApprovalStatus.approved : ApprovalStatus.denied,
      decidedAt: now,
    );
    final saved = await Approval.db.updateRow(session, updated);
    await AuditService.append(
      session,
      householdId: approval.householdId,
      memberId: deciderMemberId,
      eventType: 'approval.decide',
      action: approval.action,
      decision: approve ? AuditDecision.permitted : AuditDecision.denied,
      tierRequired: TrustTier.t2,
      reason:
          '${approve ? 'approved' : 'denied'} by owner '
          '(approval ${approval.id})',
    );
    return saved;
  }

  /// Real-time stream of newly-created pending approvals for [householdId],
  /// for the admin app to show a live "approve this?" card without
  /// polling. Uses Serverpod's message/server-events channel, one channel
  /// per household. See mcp_guard.dart's step-up path, which posts to this
  /// channel right after inserting the pending row.
  Stream<Approval> pendingApprovals(Session session, int householdId) async* {
    await requireOwner(session, householdId);
    final channel = '$_channelPrefix$householdId';
    final updates = session.messages.createStream<Approval>(channel);
    await for (final approval in updates) {
      yield approval;
    }
  }

  /// Channel name helper shared with the MCP guard, so both sides agree on
  /// how a household's channel is named without duplicating the prefix
  /// string.
  static String channelFor(int householdId) => '$_channelPrefix$householdId';
}
