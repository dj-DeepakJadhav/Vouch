import 'package:serverpod/serverpod.dart';

import '../audit/audit_service.dart';
import '../generated/protocol.dart';
import 'attestation_signature.dart';
import 'transcript_matcher.dart';

/// Raised by [AttestationService.submit] when a hub-signed attestation is
/// rejected. [reason] is a short machine-readable code; it is always also
/// written to the audit log by [submit] before this is thrown.
class AttestationRejected implements Exception {
  const AttestationRejected(this.reason);
  final String reason;

  @override
  String toString() => 'AttestationRejected: $reason';
}

/// Business logic for issuing, consuming and revoking [Attestation]s.
///
/// This is a server-side service, not an endpoint: only [submit] is ever
/// exposed to the hub over RPC (see [AttestationEndpoint]). [consumeMatching]
/// is called internally by the (future) MCP guard and must never be exposed
/// directly — a public "consume any attestation matching this text" RPC
/// would let a caller probe for matches without presenting a signed
/// attestation of their own.
class AttestationService {
  const AttestationService._();

  /// The attestation's validity window: how long after [Attestation
  /// .capturedAt] it remains usable. Attestations cover exactly one spoken
  /// utterance, so this is intentionally short (~3s).
  static const Duration validityWindow = Duration(seconds: 3);

  /// Maximum age of [capturedAt] at submission time before it is rejected
  /// as stale (the hub should be submitting near-instantly after capture).
  static const Duration maxSubmissionAge = Duration(seconds: 5);

  /// Maximum allowed clock skew for a [capturedAt] that appears to be in
  /// the future.
  static const Duration maxFutureSkew = Duration(seconds: 1);

  /// Verifies and stores a hub-signed attestation.
  ///
  /// [signatureBase64] must be a valid Ed25519 signature, by the hub
  /// identified by [hubId], over the canonical payload built from the other
  /// parameters (see [AttestationSignature.canonicalPayload]).
  ///
  /// Throws [AttestationRejected] (after auditing the rejection) if the hub
  /// is unknown, the signature does not verify, [capturedAt] is stale or in
  /// the future, or [transcriptHash] does not match
  /// sha256([transcriptNormalised]).
  static Future<Attestation> submit(
    Session session, {
    required int hubId,
    required int memberId,
    required TrustTier tier,
    required double confidence,
    required SpoofRisk spoofRisk,
    required String transcriptNormalised,
    required DateTime capturedAt,
    required String signatureBase64,
  }) async {
    final capturedAtUtc = capturedAt.toUtc();
    final transcriptHash = TranscriptMatcher.hash(transcriptNormalised);

    final hub = await Hub.db.findById(session, hubId);
    if (hub == null) {
      await _rejectAudit(
        session,
        householdId: null,
        memberId: memberId,
        reason: 'unknown hub id $hubId',
      );
      throw const AttestationRejected('unknown_hub');
    }

    final now = DateTime.now().toUtc();
    final age = now.difference(capturedAtUtc);
    if (age > maxSubmissionAge || age < -maxFutureSkew) {
      await _rejectAudit(
        session,
        householdId: hub.householdId,
        memberId: memberId,
        reason: 'capturedAt out of window (age=${age.inMilliseconds}ms)',
      );
      throw const AttestationRejected('stale_or_future_captured_at');
    }

    final payload = AttestationSignature.canonicalPayload(
      hubId: hubId,
      memberId: memberId,
      tier: tier.name,
      confidence: confidence,
      spoofRisk: spoofRisk.name,
      transcriptHash: transcriptHash,
      capturedAt: capturedAtUtc,
    );

    final signatureValid = await AttestationSignature.verify(
      payload: payload,
      signatureBase64: signatureBase64,
      publicKeyBase64: hub.publicKey,
    );

    if (!signatureValid) {
      await _rejectAudit(
        session,
        householdId: hub.householdId,
        memberId: memberId,
        reason: 'signature verification failed',
      );
      throw const AttestationRejected('invalid_signature');
    }

    // A hub may only vouch for active members of its own household. Without this,
    // a buggy or compromised hub could mint attestations for another household's
    // members (consumeMatching scopes by the member's household, so they would
    // be accepted there), or keep vouching for a revoked member.
    final member = await Member.db.findById(session, memberId);
    if (member == null ||
        member.householdId != hub.householdId ||
        member.status != MemberStatus.active) {
      await _rejectAudit(
        session,
        householdId: hub.householdId,
        memberId: member == null ? null : memberId,
        reason: member == null
            ? 'unknown member $memberId'
            : member.householdId != hub.householdId
            ? 'member $memberId is not in hub ${hub.id}\'s household'
            : 'member $memberId is ${member.status.name}',
      );
      throw const AttestationRejected('member_not_eligible');
    }

    final attestation = await Attestation.db.insertRow(
      session,
      Attestation(
        memberId: memberId,
        tier: tier,
        issuedAt: now,
        expiresAt: capturedAtUtc.add(validityWindow),
        confidence: confidence,
        spoofRisk: spoofRisk,
        hubSig: signatureBase64,
        singleUse: true,
        consumedAt: null,
        revoked: false,
        transcriptHash: transcriptHash,
        transcriptNormalised: transcriptNormalised,
        capturedAt: capturedAtUtc,
      ),
    );

    await AuditService.append(
      session,
      householdId: hub.householdId,
      memberId: memberId,
      eventType: 'attestation.submit',
      action: 'issue_attestation',
      decision: AuditDecision.permitted,
      tierPresent: tier,
      reason: 'attestation accepted from hub $hubId',
      confidence: confidence,
      transcript: transcriptNormalised,
    );

    return attestation;
  }

  static Future<void> _rejectAudit(
    Session session, {
    required int? householdId,
    required int? memberId,
    required String reason,
  }) async {
    if (householdId == null) return;
    await AuditService.append(
      session,
      householdId: householdId,
      memberId: memberId,
      eventType: 'attestation.submit',
      action: 'issue_attestation',
      decision: AuditDecision.denied,
      reason: reason,
    );
  }

  /// Finds an unconsumed, unrevoked, unexpired attestation for
  /// [householdId] whose normalised transcript fuzzy-matches
  /// [alexaCommandText], atomically marks it consumed, and returns it (with
  /// [Attestation.member] populated). Returns `null` if no attestation
  /// matches.
  ///
  /// If more than one live attestation matches, the most recently issued
  /// one is chosen and the ambiguity is recorded in the audit log — this
  /// should be rare (it means two verified utterances in the same household
  /// produced near-identical transcripts within the same few seconds).
  static Future<Attestation?> consumeMatching(
    Session session, {
    required int householdId,
    required String alexaCommandText,
    DateTime? now,
  }) => _consumeWhere(
    session,
    householdId: householdId,
    alexaCommandText: alexaCommandText,
    now: now,
    predicate: TranscriptMatcher.match,
    label: 'matching',
  );

  /// Like [consumeMatching] but for [TranscriptMatcher.isNearMiss]: a live
  /// attestation Alexa probably paraphrased. Consumed so it cannot be
  /// replayed; the guard must require owner approval for anything above T0.
  static Future<Attestation?> consumeNearMiss(
    Session session, {
    required int householdId,
    required String alexaCommandText,
    DateTime? now,
  }) => _consumeWhere(
    session,
    householdId: householdId,
    alexaCommandText: alexaCommandText,
    now: now,
    predicate: TranscriptMatcher.isNearMiss,
    label: 'near-miss (paraphrased)',
  );

  static Future<Attestation?> _consumeWhere(
    Session session, {
    required int householdId,
    required String alexaCommandText,
    required bool Function(String hubTranscript, String alexaText) predicate,
    required String label,
    DateTime? now,
  }) async {
    final effectiveNow = (now ?? DateTime.now()).toUtc();

    return session.db.transaction((tx) async {
      final candidates = await Attestation.db.find(
        session,
        where: (t) =>
            t.member.householdId.equals(householdId) &
            t.consumedAt.equals(null) &
            t.revoked.equals(false) &
            (t.expiresAt > effectiveNow),
        orderBy: (t) => t.capturedAt.desc(),
        include: Attestation.include(member: Member.include()),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );

      final matches = candidates.where((a) {
        if (TranscriptMatcher.hash(a.transcriptNormalised) !=
            a.transcriptHash) {
          // Defensive: stored hash/text integrity check. Should never
          // happen for rows written by submit().
          return false;
        }
        return predicate(a.transcriptNormalised, alexaCommandText);
      }).toList();

      if (matches.isEmpty) return null;

      final chosen = matches.first;

      if (matches.length > 1) {
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: chosen.memberId,
          eventType: 'attestation.consume',
          action: 'consume_attestation',
          decision: AuditDecision.permitted,
          reason:
              'ambiguous match: ${matches.length} live attestations '
              'matched "$alexaCommandText"; chose most recent '
              '(id=${chosen.id})',
          tierPresent: chosen.tier,
        );
      }

      final updated = chosen.copyWith(consumedAt: effectiveNow);
      await Attestation.db.updateRow(session, updated, transaction: tx);

      await AuditService.append(
        session,
        householdId: householdId,
        memberId: chosen.memberId,
        eventType: 'attestation.consume',
        action: 'consume_attestation',
        decision: AuditDecision.permitted,
        reason: 'attestation ${chosen.id} consumed for $label command',
        tierPresent: chosen.tier,
        confidence: chosen.confidence,
      );

      return updated;
    });
  }

  /// Marks every live (unexpired, unrevoked) attestation for [memberId] as
  /// revoked. Used when a member's trust must be immediately withdrawn
  /// (e.g. suspected compromise).
  static Future<int> revokeForMember(Session session, int memberId) async {
    final now = DateTime.now().toUtc();
    final rows = await Attestation.db.find(
      session,
      where: (t) =>
          t.memberId.equals(memberId) &
          t.revoked.equals(false) &
          (t.expiresAt > now),
    );

    if (rows.isEmpty) return 0;

    final revoked = rows.map((a) => a.copyWith(revoked: true)).toList();
    await Attestation.db.update(session, revoked);
    return revoked.length;
  }

  /// Marks expired, unconsumed, live attestations as [Attestation.revoked]
  /// (never deleted — the audit trail and the row itself are append-only /
  /// retained) so they stop being candidates for [consumeMatching] and are
  /// not re-processed on the next sweep. Audits exactly one
  /// `attestation.expire` event per attestation transitioned this way, so
  /// running this repeatedly (e.g. every minute) never double-audits the
  /// same row. Used by [AttestationCleanupFutureCall]. Returns the number
  /// of attestations marked.
  static Future<int> markExpiredUnconsumed(Session session) async {
    final now = DateTime.now().toUtc();
    final expired = await Attestation.db.find(
      session,
      where: (t) =>
          t.consumedAt.equals(null) &
          t.revoked.equals(false) &
          (t.expiresAt <= now),
      include: Attestation.include(member: Member.include()),
    );

    if (expired.isEmpty) return 0;

    for (final attestation in expired) {
      final householdId = attestation.member?.householdId;
      if (householdId != null) {
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: attestation.memberId,
          eventType: 'attestation.expire',
          action: 'expire_attestation',
          decision: AuditDecision.denied,
          reason: 'attestation ${attestation.id} expired unconsumed',
          tierPresent: attestation.tier,
        );
      }
    }

    final revokedRows = expired.map((a) => a.copyWith(revoked: true)).toList();
    await Attestation.db.update(session, revokedRows);

    return expired.length;
  }
}
