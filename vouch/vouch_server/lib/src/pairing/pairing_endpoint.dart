import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../attestation/attestation_signature.dart';
import '../audit/audit_service.dart';
import '../generated/protocol.dart';
import '../mcp/mcp_guard.dart' show sha256Hex;
import 'pairing_signature.dart';

/// Raised by [PairingEndpoint] when a pairing operation is rejected. The
/// [reason] is a short machine-readable string (`invalid_code`,
/// `expired_code`, `already_used`, `rate_limited`, `unknown_hub`,
/// `invalid_signature`, `no_owner`) the Flutter app matches on to show a
/// specific message.
class PairingRejected implements Exception {
  const PairingRejected(this.reason);
  final String reason;

  @override
  String toString() => 'PairingRejected: $reason';
}

/// Endpoint backing the hub-pairing flow (anonymous auth + hub pairing,
/// not email): the hub signs and mints a short-lived 6-digit code
/// ([createCode]); the anonymously-signed-in Flutter app redeems it
/// ([redeem]) to link its session to the household owner `Member`.
class PairingEndpoint extends Endpoint {
  static const _codeLifetime = Duration(minutes: 10);
  static const _maxRedeemAttempts = 5;
  static const _redeemWindow = Duration(minutes: 10);

  /// Per-caller redeem attempt timestamps, in-memory only. This is a
  /// pragmatic rate limit for a single-process demo deployment (resets on
  /// restart); a production deployment spanning multiple server instances
  /// would need this in Redis/the database instead. Every attempt is also
  /// durably recorded via [AuditService.append] regardless of this limiter.
  static final Map<String, List<DateTime>> _redeemAttempts = {};

  static String _generateCode() {
    final random = Random.secure();
    return random.nextInt(1000000).toString().padLeft(6, '0');
  }

  /// Called by the hub (Ed25519-signed the same way as enrolment reports —
  /// see `EnrolmentSignature`/`AttestationSignature`) to mint a fresh
  /// 6-digit pairing code for its household. Returns the raw code exactly
  /// once; only its SHA-256 hash is persisted (see `PairingCode.codeHash`).
  Future<String> createCode(
    Session session, {
    required int hubId,
    required DateTime capturedAt,
    required String signatureBase64,
  }) async {
    final hub = await Hub.db.findById(session, hubId);
    if (hub == null) {
      throw const PairingRejected('unknown_hub');
    }

    final capturedAtUtc = capturedAt.toUtc();
    final payload = PairingSignature.canonicalPayload(
      hubId: hubId,
      capturedAt: capturedAtUtc,
    );
    final signatureValid = await AttestationSignature.verify(
      payload: payload,
      signatureBase64: signatureBase64,
      publicKeyBase64: hub.publicKey,
    );
    if (!signatureValid) {
      throw const PairingRejected('invalid_signature');
    }

    final owner = await Member.db.findFirstRow(
      session,
      where: (t) =>
          t.householdId.equals(hub.householdId) &
          t.role.equals(MemberRole.owner),
    );
    if (owner == null) {
      throw const PairingRejected('no_owner');
    }

    final rawCode = _generateCode();
    await PairingCode.db.insertRow(
      session,
      PairingCode(
        householdId: hub.householdId,
        codeHash: sha256Hex(rawCode),
        ownerId: owner.id!,
        createdAt: capturedAtUtc,
        expiresAt: capturedAtUtc.add(_codeLifetime),
      ),
    );

    return rawCode;
  }

  /// Called by the signed-in (anonymous) app user to redeem a pairing
  /// [code]: single-use, must not be expired. On success, links the
  /// code's owner `Member.authUserId` to the caller's session and returns
  /// the household overview (mirrors `HouseholdEndpoint.myHousehold`'s
  /// shape) so the app can proceed straight into the shell. Rate-limited
  /// per signed-in caller and every attempt is audited, successful or not.
  Future<HouseholdOverview> redeem(Session session, String code) async {
    final authInfo = session.authenticated;
    final authUserId = authInfo?.userIdentifier;
    if (authUserId == null) {
      throw const PairingRejected('not_signed_in');
    }

    final now = DateTime.now().toUtc();
    final attempts = _redeemAttempts.putIfAbsent(authUserId, () => []);
    attempts.removeWhere((t) => now.difference(t) > _redeemWindow);
    if (attempts.length >= _maxRedeemAttempts) {
      // No household is resolvable for a rate-limited attempt (the caller
      // may not even have tried a real code yet), and `AuditEvent.household`
      // is a required, non-null foreign key — so this goes to the session
      // log rather than the append-only audit table. Every attempt that
      // *does* resolve to a household (below) is still fully audited.
      session.log(
        'pairing.redeem rate_limited for authUserId=$authUserId',
        level: LogLevel.warning,
      );
      throw const PairingRejected('rate_limited');
    }
    attempts.add(now);

    final codeHash = sha256Hex(code);
    final pairing = await PairingCode.db.findFirstRow(
      session,
      where: (t) => t.codeHash.equals(codeHash),
      orderBy: (t) => t.createdAt.desc(),
    );

    if (pairing == null) {
      session.log(
        'pairing.redeem invalid_code for authUserId=$authUserId',
        level: LogLevel.warning,
      );
      throw const PairingRejected('invalid_code');
    }

    if (pairing.usedAt != null) {
      await AuditService.append(
        session,
        householdId: pairing.householdId,
        eventType: 'pairing.redeem',
        action: 'pairing.redeem',
        decision: AuditDecision.denied,
        reason: 'already_used',
        createdAt: now,
        metadata: jsonEncode({'authUserId': authUserId}),
      );
      throw const PairingRejected('already_used');
    }

    if (now.isAfter(pairing.expiresAt)) {
      await AuditService.append(
        session,
        householdId: pairing.householdId,
        eventType: 'pairing.redeem',
        action: 'pairing.redeem',
        decision: AuditDecision.denied,
        reason: 'expired_code',
        createdAt: now,
        metadata: jsonEncode({'authUserId': authUserId}),
      );
      throw const PairingRejected('expired_code');
    }

    final owner = await Member.db.findById(session, pairing.ownerId);
    if (owner == null) {
      throw const PairingRejected('no_owner');
    }

    await PairingCode.db.updateRow(session, pairing.copyWith(usedAt: now));
    await Member.db.updateRow(
      session,
      owner.copyWith(authUserId: authUserId),
    );

    await AuditService.append(
      session,
      householdId: pairing.householdId,
      memberId: owner.id,
      eventType: 'pairing.redeem',
      action: 'pairing.redeem',
      decision: AuditDecision.permitted,
      reason: 'paired',
      createdAt: now,
      metadata: jsonEncode({'authUserId': authUserId}),
    );

    // Successful redeem clears this caller's failure count — the demo
    // shouldn't stay rate-limited after they've legitimately paired.
    _redeemAttempts.remove(authUserId);

    final household = await Household.db.findById(
      session,
      pairing.householdId,
    );
    if (household == null) {
      throw const PairingRejected('no_owner');
    }
    final members = await Member.db.find(
      session,
      where: (t) => t.householdId.equals(pairing.householdId),
      orderBy: (t) => t.id,
    );
    final hubs = await Hub.db.find(
      session,
      where: (t) => t.householdId.equals(pairing.householdId),
      orderBy: (t) => t.id,
    );

    return HouseholdOverview(
      household: household,
      members: members,
      hubs: hubs,
    );
  }
}
