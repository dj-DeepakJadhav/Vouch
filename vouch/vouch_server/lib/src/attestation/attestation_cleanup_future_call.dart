import 'package:serverpod/serverpod.dart';

import 'attestation_service.dart';

/// Recurring cleanup: marks expired, unconsumed attestations as revoked
/// (never deletes) so they stop showing up as live candidates and the sweep
/// stays idempotent. Registered as a minute-interval recurring future call
/// in `lib/server.dart` via
/// `pod.futureCalls.callRecurring().every(const Duration(minutes: 1))
/// .attestationCleanup.sweep()`.
class AttestationCleanupFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    final marked = await AttestationService.markExpiredUnconsumed(session);
    if (marked > 0) {
      session.log(
        'AttestationCleanupFutureCall: marked $marked expired '
        'unconsumed attestation(s) as revoked.',
      );
    }
  }
}
