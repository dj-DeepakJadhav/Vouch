import 'package:serverpod/serverpod.dart';

import '../approval/approval_endpoint.dart';
import '../generated/protocol.dart';

// APPEND-ONLY BY DESIGN (GDPR Art. 30): this endpoint exposes read access
// only. Do NOT add update, delete, or remove methods for AuditEvent here or
// anywhere else. A source scan test (test/unit/audit_endpoint_surface_test.dart)
// guards this file against regressions.

/// Read-only access to a household's append-only audit log.
class AuditEndpoint extends Endpoint {
  /// Returns the most recent [AuditEvent]s for [householdId], newest first,
  /// paginated by [page] (0-based) and [pageSize].
  Future<List<AuditEvent>> listRecent(
    Session session,
    int householdId, {
    int page = 0,
    int pageSize = 25,
  }) async {
    final safePageSize = pageSize.clamp(1, 200);
    final safePage = page < 0 ? 0 : page;
    return AuditEvent.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
      orderBy: (t) => t.createdAt.desc(),
      limit: safePageSize,
      offset: safePage * safePageSize,
    );
  }

  /// Owner-only, read-only export of every [AuditEvent] for [householdId]
  /// at or after [since], oldest first — intended for the nightly review
  /// job (`jobs/nightly_review/`), which pulls the last 24h and hands it to
  /// Nemotron for an unusual-activity summary. Bounded to 5000 rows so a
  /// misconfigured `since` (e.g. epoch) can't return an unbounded dump.
  Future<List<AuditEvent>> exportSince(
    Session session,
    int householdId,
    DateTime since,
  ) async {
    await ApprovalEndpoint.requireOwner(session, householdId);
    return AuditEvent.db.find(
      session,
      where: (t) => t.householdId.equals(householdId) & (t.createdAt >= since),
      orderBy: (t) => t.createdAt,
      limit: 5000,
    );
  }
}
