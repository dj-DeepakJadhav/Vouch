import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../household/household_endpoint.dart';

/// Writes [AuditEvent] rows. This service is INSERT-ONLY: it must never gain
/// an update or delete method. `AuditEvent` is append-only by design (GDPR
/// Art. 30 record-of-processing requirement).
class AuditService {
  const AuditService._();

  /// Derives the live-stream [HouseholdEventKind] for an audited event.
  /// Single place this mapping lives — every audited event becomes exactly
  /// one household stream event, so HouseholdEndpoint.householdStatus and
  /// the AuditEvent table can never drift apart.
  static HouseholdEventKind _deriveKind(
    String eventType,
    AuditDecision decision,
  ) {
    if (eventType.startsWith('attestation.')) {
      return decision == AuditDecision.permitted
          ? HouseholdEventKind.attestationAccepted
          : HouseholdEventKind.attestationRejected;
    }
    if (decision == AuditDecision.challenged) {
      return HouseholdEventKind.approvalPending;
    }
    // memberId on these is the owner who decided, not the requester.
    if (eventType == 'approval.decide') {
      return HouseholdEventKind.approvalDecided;
    }
    return HouseholdEventKind.decision;
  }

  /// Records a single access-decision event. Returns the inserted row
  /// (with its assigned id and any DB-computed fields).
  static Future<AuditEvent> append(
    Session session, {
    required int householdId,
    int? memberId,
    required String eventType,
    required String action,
    required AuditDecision decision,
    TrustTier? tierRequired,
    TrustTier? tierPresent,
    required String reason,
    double? confidence,
    String? metadata,
    DateTime? createdAt,
    String? transcript,
  }) async {
    final event = AuditEvent(
      householdId: householdId,
      memberId: memberId,
      eventType: eventType,
      action: action,
      decision: decision,
      tierRequired: tierRequired,
      tierPresent: tierPresent,
      reason: reason,
      confidence: confidence,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      metadata: metadata,
    );
    final inserted = await AuditEvent.db.insertRow(session, event);

    await session.messages.postMessage(
      HouseholdEndpoint.channelFor(householdId),
      HouseholdEvent(
        householdId: householdId,
        kind: _deriveKind(eventType, decision),
        memberId: memberId,
        action: action,
        decision: decision,
        reason: reason,
        at: inserted.createdAt,
        transcript: transcript,
        tierPresent: tierPresent,
        eventType: eventType,
      ),
    );

    return inserted;
  }
}
