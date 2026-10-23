import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Recurring cleanup: marks pending [Approval] rows whose [Approval
/// .expiresAt] has passed as [ApprovalStatus.expired]. Mirrors the pattern
/// in attestation_cleanup_future_call.dart. Registered in lib/server.dart
/// as a minute-interval recurring future call.
class ApprovalExpiryFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    final now = DateTime.now().toUtc();
    final expired = await Approval.db.find(
      session,
      where: (t) =>
          t.status.equals(ApprovalStatus.pending) & (t.expiresAt <= now),
    );
    if (expired.isEmpty) return;

    final updated = expired
        .map((a) => a.copyWith(status: ApprovalStatus.expired, decidedAt: now))
        .toList();
    await Approval.db.update(session, updated);

    session.log(
      'ApprovalExpiryFutureCall: marked ${updated.length} pending '
      'approval(s) as expired.',
    );
  }
}
