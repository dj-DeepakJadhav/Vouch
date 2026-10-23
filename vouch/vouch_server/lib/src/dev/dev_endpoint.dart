import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../approval/approval_endpoint.dart';
import '../attestation/attestation_service.dart';
import '../attestation/attestation_signature.dart';
import '../attestation/transcript_matcher.dart';
import '../generated/protocol.dart';
import '../mcp/mcp_guard.dart' show sha256Hex;
import '../policy/policy_engine.dart';
import 'dev_mode_guard.dart';

/// Dev-only convenience endpoint for standing up a demo household without
/// hand-writing SQL or a bespoke script. Used by the hub team to get a
/// `hubId` + public key registration and an MCP bearer token in one call,
/// and by the terminal demo to approve a step-up without a phone.
///
/// Every method throws unless the server is running in development mode —
/// this must never be reachable in staging/production.
class DevEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  void _requireDevMode(Session session) {
    DevModeGuard.check(session.serverpod.runMode);
  }

  /// Capability probe for the app's "Try the demo household" button: true
  /// iff the other DevEndpoint methods would be allowed on this server.
  /// Unauthenticated and returns nothing but that boolean; it does not
  /// relax [DevModeGuard], which every other method still enforces.
  Future<bool> demoAvailable(Session session) async {
    try {
      DevModeGuard.check(session.serverpod.runMode);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Creates a brand-new demo household with an owner, a child, a hub
  /// registered with [hubPublicKeyBase64], the default household policy
  /// rules (via [PolicyEngine.buildDefaultHouseholdRules]) plus a
  /// child-role deny rule for `place_*` actions, and a fresh MCP
  /// bearer token.
  ///
  /// Always creates a new household (idempotent-friendly: safe to call
  /// repeatedly, each call yields an independent, fully-formed demo
  /// household rather than upserting into a shared one).
  ///
  /// The raw MCP token is returned exactly once here; only its SHA-256
  /// hash is persisted (see `McpClient.tokenHash`).
  Future<DemoSeed> seedDemoHousehold(
    Session session,
    String ownerName,
    String childName,
    String hubPublicKeyBase64,
  ) async {
    _requireDevMode(session);

    final now = DateTime.now().toUtc();

    final household = await Household.db.insertRow(
      session,
      Household(name: '$ownerName household (dev seed)', createdAt: now),
    );

    final owner = await Member.db.insertRow(
      session,
      Member(
        householdId: household.id!,
        displayName: ownerName,
        role: MemberRole.owner,
        status: MemberStatus.active,
      ),
    );

    final child = await Member.db.insertRow(
      session,
      Member(
        householdId: household.id!,
        displayName: childName,
        role: MemberRole.child,
        status: MemberStatus.active,
      ),
    );

    final hub = await Hub.db.insertRow(
      session,
      Hub(
        householdId: household.id!,
        publicKey: hubPublicKeyBase64,
        version: '0.0.1-dev-seed',
        lastSeen: now,
      ),
    );

    // Default household-wide tier rules...
    final defaultRules = PolicyEngine.buildDefaultHouseholdRules(
      household.id!,
    );
    // ...plus a ROLE-scoped deny for place_* actions (children may not
    // place orders). Role scope, not member scope, on purpose: a rule the
    // owner later writes for this child by name (e.g. "Ana can't buy
    // anything over 10 euros" -> member rule, place_order, t2, maxAmount
    // 10) is more specific and so refines this default instead of being
    // silently overridden by it (PolicyEngine: member > role > household).
    final childDenyRule = PolicyRule(
      householdId: household.id!,
      role: MemberRole.child,
      actionPattern: 'place_*',
      requiredTier: TrustTier.t2,
      effect: PolicyEffect.deny,
      sourceText: 'Children may not place orders (demo default)',
      enabled: true,
    );

    for (final rule in [...defaultRules, childDenyRule]) {
      await PolicyRule.db.insertRow(session, rule);
    }

    final rawToken = _generateToken();
    await McpClient.db.insertRow(
      session,
      McpClient(
        householdId: household.id!,
        tokenHash: sha256Hex(rawToken),
        label: 'dev seed — $ownerName household',
        createdAt: now,
        revoked: false,
      ),
    );

    return DemoSeed(
      householdId: household.id!,
      hubId: hub.id!,
      ownerMemberId: owner.id!,
      childMemberId: child.id!,
      mcpToken: rawToken,
    );
  }

  /// DEV-ONLY convenience for the terminal demo: approves [approvalId] "as
  /// the household owner" without a phone/Flutter admin app round trip.
  ///
  /// Deliberately goes through the exact same code path as a real owner
  /// decision (`ApprovalEndpoint.decide`'s update logic) so that policy
  /// enforcement and audit records are identical to production — the only
  /// thing skipped is the owner-identity check itself, which is the whole
  /// point of a dev shortcut. NEVER expose this outside development mode.
  Future<Approval?> approveAsOwner(Session session, int approvalId) async {
    _requireDevMode(session);
    return ApprovalEndpoint.decideInternal(
      session,
      approvalId: approvalId,
      approve: true,
    );
  }

  /// DEV-ONLY convenience for scripted conformance tests (see
  /// `tool/mcp_conformance`): returns the id of the most recently created
  /// still-pending [Approval] for [householdId], or null if there is none.
  /// Lets a test client discover the approval id without parsing the
  /// signed `approvalRef`/`requestState` blob itself.
  Future<int?> latestPendingApprovalId(
    Session session,
    int householdId,
  ) async {
    _requireDevMode(session);
    final approval = await Approval.db.findFirstRow(
      session,
      where: (t) =>
          t.householdId.equals(householdId) &
          t.status.equals(ApprovalStatus.pending),
      orderBy: (t) => t.createdAt.desc(),
    );
    return approval?.id;
  }

  /// DEV-ONLY convenience for scripted conformance tests: mints a fresh
  /// Ed25519 keypair, overwrites [hubId]'s stored public key with it (the
  /// dev-seeded hub's "key" from `seedDemoHousehold` is just caller-
  /// supplied bytes, not a real keypair the caller can sign with), then
  /// signs and submits a real attestation for [memberId] at [tier] bound
  /// to [utterance] via the normal [AttestationService.submit] path — the
  /// same verification code real hub traffic goes through. Lets a
  /// scripted (e.g. Node) test drive the "recognised speaker" precondition
  /// for a T1/T2 step-up without reimplementing Ed25519 signing itself.
  Future<Attestation> issueTestAttestation(
    Session session,
    int hubId,
    int memberId,
    String tier,
    String utterance,
  ) async {
    _requireDevMode(session);

    final trustTier = TrustTier.values.byName(tier);
    final hub = await Hub.db.findById(session, hubId);
    if (hub == null) {
      throw Exception('unknown hub id $hubId');
    }

    final signed = await AttestationSignature.signForTest('probe');
    await Hub.db.updateRow(
      session,
      hub.copyWith(publicKey: signed.publicKeyBase64),
    );

    final now = DateTime.now().toUtc();
    final transcriptHash = TranscriptMatcher.hash(utterance);
    final payload = AttestationSignature.canonicalPayload(
      hubId: hubId,
      memberId: memberId,
      tier: trustTier.name,
      confidence: 0.95,
      spoofRisk: SpoofRisk.low.name,
      transcriptHash: transcriptHash,
      capturedAt: now,
    );
    final reSigned = await AttestationSignature.signForTest(
      payload,
      keyPair: signed.keyPair,
    );

    return AttestationService.submit(
      session,
      hubId: hubId,
      memberId: memberId,
      tier: trustTier,
      confidence: 0.95,
      spoofRisk: SpoofRisk.low,
      transcriptNormalised: utterance,
      capturedAt: now,
      signatureBase64: reSigned.signatureBase64,
    );
  }

  /// DEV-ONLY: sets [householdId]'s owner `Member.authUserId` to the
  /// signed-in caller, so a demo household seeded via [seedDemoHousehold]
  /// (which has no linked login for its owner) becomes usable from the
  /// Flutter admin app after the developer signs in. Guarded by the same
  /// dev-mode guard as every other method here — never reachable in
  /// staging/production, where ownership must never be reassignable by a
  /// bare RPC call with no further proof of anything.
  Future<Member> claimOwner(Session session, int householdId) async {
    _requireDevMode(session);

    final authInfo = session.authenticated;
    final authUserId = authInfo?.userIdentifier;
    if (authUserId == null) {
      throw Exception('claimOwner requires a signed-in caller');
    }

    final owner = await Member.db.findFirstRow(
      session,
      where: (t) =>
          t.householdId.equals(householdId) & t.role.equals(MemberRole.owner),
    );
    if (owner == null) {
      throw Exception('household $householdId has no owner member');
    }

    final updated = owner.copyWith(authUserId: authUserId);
    return Member.db.updateRow(session, updated);
  }

  /// DEV-ONLY, owner-only: mints a fresh MCP bearer token for [householdId]
  /// by inserting a brand-new [McpClient] row, and returns the raw token
  /// exactly once (only its SHA-256 hash is persisted — see
  /// `McpClient.tokenHash`). Used by the Flutter admin app's simulated
  /// Alexa+ screen so a demo can drive the *real* MCP endpoint (POST
  /// /mcp) with a bearer token the household owner obtained from inside
  /// the app itself, rather than the hub's `config.json` token. The app
  /// keeps the raw token in memory only; it is never persisted client-side.
  /// Never reachable outside development mode (see [_requireDevMode]), and
  /// requires the caller to be the signed-in household owner (same
  /// authorization as every other owner-scoped endpoint —
  /// `ApprovalEndpoint.requireOwner`), unlike the other methods on this
  /// endpoint which are unauthenticated dev shortcuts: this one hands back
  /// a live credential, so it gets the extra check.
  Future<String> mintMcpToken(Session session, int householdId) async {
    _requireDevMode(session);
    await ApprovalEndpoint.requireOwner(session, householdId);

    final rawToken = _generateToken();
    await McpClient.db.insertRow(
      session,
      McpClient(
        householdId: householdId,
        tokenHash: sha256Hex(rawToken),
        label: 'dev — minted from Flutter admin app',
        createdAt: DateTime.now().toUtc(),
        revoked: false,
      ),
    );
    return rawToken;
  }

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
