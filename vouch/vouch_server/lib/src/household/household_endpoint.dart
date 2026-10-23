import 'package:serverpod/serverpod.dart';

import '../approval/approval_endpoint.dart';
import '../attestation/attestation_service.dart';
import '../audit/audit_service.dart';
import '../generated/protocol.dart';

/// Thrown by [HouseholdEndpoint.revokeMember] when the caller tries to
/// revoke the household owner. Revoking the only owner would lock the
/// household out of its own admin app, so this is refused outright rather
/// than left as a footgun.
class CannotRevokeOwnerException implements Exception {
  const CannotRevokeOwnerException();
  @override
  String toString() =>
      'CannotRevokeOwnerException: the household owner cannot be revoked';
}

/// Serverpod endpoint for the Flutter admin app: a live, owner-only stream
/// of everything happening in a household (attestations, policy decisions,
/// step-up approvals), backing a status view without polling the audit
/// log.
///
/// Authorization mirrors `ApprovalEndpoint`'s owner check exactly (same
/// `Member.authUserId` -> owner-of-this-household resolution) — see
/// `approval_endpoint.dart` for the rationale.
class HouseholdEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _channelPrefix = 'household-status-household-';

  /// Channel name helper shared with `AuditService`, so both sides agree on
  /// how a household's channel is named without duplicating the prefix
  /// string.
  static String channelFor(int householdId) => '$_channelPrefix$householdId';

  /// Real-time stream of [HouseholdEvent]s for [householdId] — one is
  /// published for every `AuditService.append` call (see audit_service.dart),
  /// so this is a live superset view of the household's audit log.
  Stream<HouseholdEvent> householdStatus(
    Session session,
    int householdId,
  ) async* {
    // Reuses ApprovalEndpoint's owner-resolution logic rather than
    // duplicating it — same authorization rule, single source of truth.
    await ApprovalEndpoint.requireOwner(session, householdId);
    final updates = session.messages.createStream<HouseholdEvent>(
      channelFor(householdId),
    );
    await for (final event in updates) {
      yield event;
    }
  }

  /// Cheap pre-check for the app's cold start: true iff the signed-in
  /// caller is linked to an owner member (i.e. [myHousehold] would
  /// resolve). Returns a plain false for an unpaired session instead of
  /// the [NotHouseholdOwnerException] that [myHousehold] still throws.
  /// Reveals only a boolean about the caller themselves.
  Future<bool> hasHousehold(Session session) async {
    try {
      await ApprovalEndpoint.requireOwnerBySignedInUser(session);
      return true;
    } on NotHouseholdOwnerException {
      return false;
    }
  }

  /// The signed-in owner's own household: the household row, all its
  /// members, and all its registered hubs. Resolves the caller to a
  /// household purely via `Member.authUserId` (no caller-supplied
  /// household id to check against), so this is the entry point the
  /// Flutter app uses right after sign-in, before it knows any id at all.
  Future<HouseholdOverview> myHousehold(Session session) async {
    final owner = await ApprovalEndpoint.requireOwnerBySignedInUser(session);

    final household = await Household.db.findById(
      session,
      owner.householdId,
    );
    if (household == null) {
      throw NotHouseholdOwnerException(
        'owner\'s household ${owner.householdId} no longer exists',
      );
    }
    final members = await Member.db.find(
      session,
      where: (t) => t.householdId.equals(owner.householdId),
      orderBy: (t) => t.id,
    );
    final hubs = await Hub.db.find(
      session,
      where: (t) => t.householdId.equals(owner.householdId),
      orderBy: (t) => t.id,
    );

    return HouseholdOverview(
      household: household,
      members: members,
      hubs: hubs,
    );
  }

  /// All members of [householdId]. Owner-only, same authorization as every
  /// other household-scoped query here.
  Future<List<Member>> members(Session session, int householdId) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return Member.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
      orderBy: (t) => t.id,
    );
  }

  /// All [Enrolment]s for [householdId]'s members — the Flutter admin app's
  /// Members screen shows enrolment status (quality, sample count) alongside
  /// each member without exposing any biometric data (see
  /// `identity/enrolment.spy.yaml`: only an opaque `embeddingRef` is ever
  /// stored). Owner-only, same authorization as every other query here.
  Future<List<Enrolment>> enrolments(Session session, int householdId) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return Enrolment.db.find(
      session,
      where: (t) => t.member.householdId.equals(householdId),
      orderBy: (t) => t.id,
    );
  }

  /// Owner-only: immediately withdraws [memberId]'s voice trust — the "live
  /// revoke" demo beat. Two things happen atomically from the caller's
  /// perspective:
  ///
  /// 1. [Member.status] is set to [MemberStatus.revoked], which blocks any
  ///    FUTURE attestation from being minted for this member
  ///    ([AttestationService.submit] already rejects non-active members —
  ///    see `member_not_eligible`).
  /// 2. Every currently-live attestation for the member is also revoked
  ///    ([AttestationService.revokeForMember]), so an attestation minted a
  ///    moment ago (before this call) cannot be replayed either.
  ///
  /// Without both steps the demo would be hollow: revoking only live
  /// attestations leaves the very next utterance free to mint a fresh one.
  ///
  /// Writes an [AuditEvent] (`member.revoke`) so the Home/Activity feed
  /// updates live via `HouseholdEndpoint.householdStatus`. Throws
  /// [CannotRevokeOwnerException] for the owner's own member row, and
  /// [NotHouseholdOwnerException] if the caller isn't this household's
  /// owner.
  Future<Member> revokeMember(Session session, int memberId) async {
    final member = await Member.db.findById(session, memberId);
    if (member == null) {
      // Same error as "not owner" so member ids can't be probed.
      throw NotHouseholdOwnerException('not authorised for this member');
    }
    final owner = await ApprovalEndpoint.requireOwner(
      session,
      member.householdId,
    );
    if (member.role == MemberRole.owner) {
      throw const CannotRevokeOwnerException();
    }

    if (member.status != MemberStatus.revoked) {
      final updated = member.copyWith(status: MemberStatus.revoked);
      await Member.db.updateRow(session, updated);
    }
    await AttestationService.revokeForMember(session, memberId);

    await AuditService.append(
      session,
      householdId: member.householdId,
      memberId: memberId,
      eventType: 'member.revoke',
      action: 'revoke_member',
      decision: AuditDecision.permitted,
      reason:
          '${member.displayName}\'s voice trust revoked by owner '
          '${owner.displayName}',
    );

    return (await Member.db.findById(session, memberId))!;
  }

  /// Owner-only: restores a previously-revoked member back to
  /// [MemberStatus.active], so future attestations can be minted for them
  /// again. Writes an [AuditEvent] (`member.restore`) so the Home/Activity
  /// feed updates live. Throws [NotHouseholdOwnerException] if the caller
  /// isn't this household's owner.
  Future<Member> restoreMember(Session session, int memberId) async {
    final member = await Member.db.findById(session, memberId);
    if (member == null) {
      // Same error as "not owner" so member ids can't be probed.
      throw NotHouseholdOwnerException('not authorised for this member');
    }
    final owner = await ApprovalEndpoint.requireOwner(
      session,
      member.householdId,
    );

    // Only undo a revoke; never promote a member who hasn't finished enrolment.
    if (member.status != MemberStatus.revoked) return member;
    await Member.db.updateRow(
      session,
      member.copyWith(status: MemberStatus.active),
    );

    await AuditService.append(
      session,
      householdId: member.householdId,
      memberId: memberId,
      eventType: 'member.restore',
      action: 'restore_member',
      decision: AuditDecision.permitted,
      reason:
          '${member.displayName}\'s voice trust restored by owner '
          '${owner.displayName}',
    );

    return (await Member.db.findById(session, memberId))!;
  }
}
