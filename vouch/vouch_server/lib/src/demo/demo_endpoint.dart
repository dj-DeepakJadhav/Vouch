import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:serverpod/serverpod.dart';

import '../approval/approval_endpoint.dart';
import '../attestation/attestation_service.dart';
import '../attestation/attestation_signature.dart';
import '../attestation/transcript_matcher.dart';
import '../audit/audit_service.dart';
import '../generated/protocol.dart';
import '../mcp/mcp_guard.dart' show sha256Hex;
import '../policy/policy_engine.dart';

/// Thrown by every [DemoEndpoint] refusal. [code] is short and stable so
/// tests (and logs) can tell the paths apart.
class DemoRefused implements Exception {
  const DemoRefused(this.code);
  final String code;
  @override
  String toString() => 'DemoRefused: $code';
}

/// Hosted-demo switch. OFF unless the `demoMode` password is exactly
/// `true` (config/passwords.yaml, or `SERVERPOD_PASSWORD_demoMode=true`, or
/// a Serverpod Cloud password). Independent of run mode: a production
/// server can host the demo without enabling any DevEndpoint shortcut.
class DemoMode {
  const DemoMode._();

  /// Test hook: forces the flag on/off regardless of passwords. Null =
  /// read the real config.
  static bool? overrideForTesting;

  static bool isEnabled(Session session) =>
      overrideForTesting ?? session.passwords['demoMode']?.trim() == 'true';

  /// New demo households allowed per rolling hour, server-wide.
  static int maxPerHour = 30;

  /// Hard cap on demo households ever created on this server (bounds DB
  /// growth for the whole hosting window).
  static int maxTotal = 2000;
}

/// Public "demo household" for hosted judging. Each signed-in (anonymous)
/// caller gets ONE isolated household (owner Priya linked to the caller,
/// child Ana, a server-side demo hub with its own Ed25519 key) and can only
/// ever act on that household. Unlike DevEndpoint there is no way to reach
/// someone else's household, approve as an owner, rewrite a hub key or
/// seed arbitrary data. Every attestation still goes through
/// [AttestationService.submit] (real signature verification + audit), and
/// the MCP guard is untouched.
class DemoEndpoint extends Endpoint {
  /// Only [available] is public; the rest check sign-in themselves so the
  /// probe works before the app has signed in.
  @override
  bool get requireLogin => false;

  static const demoHubVersion = '0.0.1-dev-seed';
  static final Ed25519 _ed25519 = Ed25519();

  /// Whether this server hosts the demo. No login needed, reveals nothing
  /// else.
  Future<bool> available(Session session) async => DemoMode.isEnabled(session);

  /// Creates (or returns) the caller's own demo household.
  Future<DemoStart> start(Session session) async {
    final authUserId = _requireDemoCaller(session);

    final existing = await DemoHousehold.db.findFirstRow(
      session,
      where: (t) => t.ownerAuthUserId.equals(authUserId),
    );
    if (existing != null) return _describe(session, existing);

    // A caller already linked to a real household must not also own a
    // demo one: owner resolution by authUserId would become ambiguous.
    final linked = await Member.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (linked != null) throw const DemoRefused('caller_already_linked');

    final now = DateTime.now().toUtc();
    final lastHour = await DemoHousehold.db.count(
      session,
      where: (t) => t.createdAt > now.subtract(const Duration(hours: 1)),
    );
    if (lastHour >= DemoMode.maxPerHour) {
      throw const DemoRefused('rate_limited');
    }
    if (await DemoHousehold.db.count(session) >= DemoMode.maxTotal) {
      throw const DemoRefused('demo_capacity_reached');
    }

    final keyPair = await _ed25519.newKeyPair();
    final seed = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    final row = await session.db.transaction((tx) async {
      final household = await Household.db.insertRow(
        session,
        Household(name: 'Priya household (demo)', createdAt: now),
        transaction: tx,
      );
      final hid = household.id!;
      await Member.db.insertRow(
        session,
        Member(
          householdId: hid,
          displayName: 'Priya',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: authUserId,
        ),
        transaction: tx,
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: hid,
          displayName: 'Ana',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
        transaction: tx,
      );
      final hub = await Hub.db.insertRow(
        session,
        Hub(
          householdId: hid,
          publicKey: base64.encode(publicKey.bytes),
          version: demoHubVersion,
          lastSeen: now,
        ),
        transaction: tx,
      );
      // Same rules as the dev seed: household tier defaults plus a
      // role-scoped deny on place_* for children.
      final rules = [
        ...PolicyEngine.buildDefaultHouseholdRules(hid),
        PolicyRule(
          householdId: hid,
          role: MemberRole.child,
          actionPattern: 'place_*',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.deny,
          sourceText: 'Children may not place orders (demo default)',
          enabled: true,
        ),
      ];
      for (final rule in rules) {
        await PolicyRule.db.insertRow(session, rule, transaction: tx);
      }
      return DemoHousehold.db.insertRow(
        session,
        DemoHousehold(
          householdId: hid,
          hubId: hub.id!,
          ownerAuthUserId: authUserId,
          hubPrivateKeySeed: base64.encode(seed),
          createdAt: now,
        ),
        transaction: tx,
      );
    });

    final result = await _describe(session, row);
    await AuditService.append(
      session,
      householdId: row.householdId,
      memberId: result.ownerMemberId,
      eventType: 'demo.start',
      action: 'demo_household_created',
      decision: AuditDecision.permitted,
      reason: 'Demo household created for this session',
    );
    return result;
  }

  /// Signs, with the caller's demo hub key, an attestation that [memberId]
  /// said [utterance], and submits it through the normal verification path.
  Future<Attestation> attest(
    Session session,
    int memberId,
    String utterance,
  ) async {
    final demo = await _requireOwnDemo(session);
    final member = await Member.db.findById(session, memberId);
    if (member == null || member.householdId != demo.householdId) {
      throw const DemoRefused('member_not_in_household');
    }

    final keyPair = await _ed25519.newKeyPairFromSeed(
      Uint8List.fromList(base64.decode(demo.hubPrivateKeySeed)),
    );
    final now = DateTime.now().toUtc();
    final payload = AttestationSignature.canonicalPayload(
      hubId: demo.hubId,
      memberId: memberId,
      tier: TrustTier.t1.name,
      confidence: 0.95,
      spoofRisk: SpoofRisk.low.name,
      transcriptHash: TranscriptMatcher.hash(utterance),
      capturedAt: now,
    );
    final signature = await _ed25519.sign(
      utf8.encode(payload),
      keyPair: keyPair,
    );

    // Real path: hub lookup, signature check against the STORED public
    // key, freshness, member status, audit. Nothing here touches the hub.
    return AttestationService.submit(
      session,
      hubId: demo.hubId,
      memberId: memberId,
      tier: TrustTier.t1,
      confidence: 0.95,
      spoofRisk: SpoofRisk.low,
      transcriptNormalised: utterance,
      capturedAt: now,
      signatureBase64: base64.encode(signature.bytes),
    );
  }

  /// Mints an MCP bearer token for the caller's own demo household. Raw
  /// token returned once; only its hash is stored.
  Future<String> mintMcpToken(Session session) async {
    final demo = await _requireOwnDemo(session);
    final owner = await ApprovalEndpoint.requireOwner(
      session,
      demo.householdId,
    );
    final random = Random.secure();
    final rawToken = base64Url.encode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    await McpClient.db.insertRow(
      session,
      McpClient(
        householdId: demo.householdId,
        tokenHash: sha256Hex(rawToken),
        label: 'demo: minted from the hosted app',
        createdAt: DateTime.now().toUtc(),
        revoked: false,
      ),
    );
    await AuditService.append(
      session,
      householdId: demo.householdId,
      memberId: owner.id,
      eventType: 'demo.mcp_token',
      action: 'mcp_token_minted',
      decision: AuditDecision.permitted,
      reason: 'Demo MCP token minted for the simulated Alexa tab',
    );
    return rawToken;
  }

  String _requireDemoCaller(Session session) {
    if (!DemoMode.isEnabled(session)) throw const DemoRefused('demo_off');
    final authUserId = session.authenticated?.userIdentifier;
    if (authUserId == null) throw const DemoRefused('not_signed_in');
    return authUserId;
  }

  /// The caller must be the owner of a household that is marked demo.
  Future<DemoHousehold> _requireOwnDemo(Session session) async {
    _requireDemoCaller(session);
    final owner = await ApprovalEndpoint.requireOwnerBySignedInUser(session);
    final demo = await DemoHousehold.db.findFirstRow(
      session,
      where: (t) => t.householdId.equals(owner.householdId),
    );
    if (demo == null) throw const DemoRefused('not_a_demo_household');
    return demo;
  }

  Future<DemoStart> _describe(Session session, DemoHousehold demo) async {
    final members = await Member.db.find(
      session,
      where: (t) => t.householdId.equals(demo.householdId),
      orderBy: (t) => t.id,
    );
    return DemoStart(
      householdId: demo.householdId,
      hubId: demo.hubId,
      ownerMemberId: members.firstWhere((m) => m.role == MemberRole.owner).id!,
      childMemberId: members.firstWhere((m) => m.role == MemberRole.child).id!,
    );
  }
}
