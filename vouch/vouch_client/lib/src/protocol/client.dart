/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:vouch_client/src/protocol/approval/approval.dart' as _irq51xio;
import 'package:vouch_client/src/protocol/audit/audit_event.dart' as _i3akpdsc;
import 'package:vouch_client/src/protocol/demo/demo_start.dart' as _iftolq1m;
import 'package:vouch_client/src/protocol/dev/dev_seed.dart' as _i6j5s1j2;
import 'package:vouch_client/src/protocol/enums/spoof_risk.dart' as _ix93drds;
import 'package:vouch_client/src/protocol/enums/trust_tier.dart' as _ibqfh8k4;
import 'package:vouch_client/src/protocol/greetings/greeting.dart' as _i5wyqq9r;
import 'package:vouch_client/src/protocol/household/household_event.dart'
    as _i9hh6y82;
import 'package:vouch_client/src/protocol/household/household_overview.dart'
    as _itnkoaqw;
import 'package:vouch_client/src/protocol/identity/attestation.dart'
    as _i518k1n9;
import 'package:vouch_client/src/protocol/identity/enrolment.dart' as _ixzes3t5;
import 'package:vouch_client/src/protocol/identity/member.dart' as _iijtn340;
import 'package:vouch_client/src/protocol/policy/policy_rule.dart' as _itvg2dtw;
import 'package:vouch_client/src/protocol/policy/rule_preview_result.dart'
    as _ip13g5m4;
import 'package:vouch_client/src/protocol/policy/rule_proposal.dart'
    as _i6o75vgd;
import 'package:vouch_client/src/protocol/policy/tool_classification.dart'
    as _ir2xlo1r;
import 'protocol.dart' as _il2as5qe;

/// Serverpod endpoint for the Flutter admin app: list pending T2 step-up
/// approvals for a household and decide them (approve/deny).
///
/// Authorization: the authenticated Serverpod user must resolve (via
/// `Member.authUserId`) to a `Member` row that is `role == owner` AND
/// belongs to the household the approval/query is scoped to. A child,
/// adult or guest — even if signed in — is rejected. This closes the gap
/// noted in VOUCH-PLAN.md §5 ("a child could approve their own purchase").
/// {@category Endpoint}
class EndpointApproval extends _isc.EndpointRef {
  EndpointApproval(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'approval';

  _ida.Future<List<_irq51xio.Approval>> listPending(int householdId) =>
      caller.callServerEndpoint<List<_irq51xio.Approval>>(
        'approval',
        'listPending',
        {'householdId': householdId},
      );

  _ida.Future<_irq51xio.Approval?> decide(
    int approvalId,
    bool approve,
  ) => caller.callServerEndpoint<_irq51xio.Approval?>(
    'approval',
    'decide',
    {
      'approvalId': approvalId,
      'approve': approve,
    },
  );

  /// Real-time stream of newly-created pending approvals for [householdId],
  /// for the admin app to show a live "approve this?" card without
  /// polling. Uses Serverpod's message/server-events channel, one channel
  /// per household. See mcp_guard.dart's step-up path, which posts to this
  /// channel right after inserting the pending row.
  _ida.Stream<_irq51xio.Approval> pendingApprovals(int householdId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_irq51xio.Approval>,
        _irq51xio.Approval
      >(
        'approval',
        'pendingApprovals',
        {'householdId': householdId},
        {},
      );
}

/// Endpoint the hub calls to submit a freshly signed attestation.
///
/// Intentionally exposes only [submit]. [AttestationService.consumeMatching]
/// is deliberately NOT exposed here — it is called internally by the
/// (future) MCP guard, never directly by a client, since consumption must
/// always be paired with independent verification of the presented
/// attestation, not driven by an untrusted caller supplying arbitrary
/// command text.
/// {@category Endpoint}
class EndpointAttestation extends _isc.EndpointRef {
  EndpointAttestation(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'attestation';

  _ida.Future<_i518k1n9.Attestation> submit({
    required int hubId,
    required int memberId,
    required _ibqfh8k4.TrustTier tier,
    required double confidence,
    required _ix93drds.SpoofRisk spoofRisk,
    required String transcriptNormalised,
    required DateTime capturedAt,
    required String signatureBase64,
  }) => caller.callServerEndpoint<_i518k1n9.Attestation>(
    'attestation',
    'submit',
    {
      'hubId': hubId,
      'memberId': memberId,
      'tier': tier,
      'confidence': confidence,
      'spoofRisk': spoofRisk,
      'transcriptNormalised': transcriptNormalised,
      'capturedAt': capturedAt,
      'signatureBase64': signatureBase64,
    },
  );
}

/// Read-only access to a household's append-only audit log.
/// {@category Endpoint}
class EndpointAudit extends _isc.EndpointRef {
  EndpointAudit(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'audit';

  /// Returns the most recent [AuditEvent]s for [householdId], newest first,
  /// paginated by [page] (0-based) and [pageSize].
  _ida.Future<List<_i3akpdsc.AuditEvent>> listRecent(
    int householdId, {
    required int page,
    required int pageSize,
  }) => caller.callServerEndpoint<List<_i3akpdsc.AuditEvent>>(
    'audit',
    'listRecent',
    {
      'householdId': householdId,
      'page': page,
      'pageSize': pageSize,
    },
  );

  /// Owner-only, read-only export of every [AuditEvent] for [householdId]
  /// at or after [since], oldest first — intended for the nightly review
  /// job (`jobs/nightly_review/`), which pulls the last 24h and hands it to
  /// Nemotron for an unusual-activity summary. Bounded to 5000 rows so a
  /// misconfigured `since` (e.g. epoch) can't return an unbounded dump.
  _ida.Future<List<_i3akpdsc.AuditEvent>> exportSince(
    int householdId,
    DateTime since,
  ) => caller.callServerEndpoint<List<_i3akpdsc.AuditEvent>>(
    'audit',
    'exportSince',
    {
      'householdId': householdId,
      'since': since,
    },
  );
}

/// By extending [AnonymousIdpBaseEndpoint], anonymous sign-in is exposed on
/// the server. The app calls `anonymousIdp.login()` automatically on launch
/// (with no UI), then links the resulting session to a household via
/// `pairing.redeem` (see `../pairing/pairing_endpoint.dart`).
/// {@category Endpoint}
class EndpointAnonymousIdp extends _iaic.EndpointAnonymousIdpBase {
  EndpointAnonymousIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonymousIdp';

  /// Creates a new anonymous account and returns its session.
  ///
  /// Invokes the [AnonymousIdp.beforeAnonymousAccount] callback if configured,
  /// which may prevent account creation if the endpoint is protected.
  @override
  _ida.Future<_iacc.AuthSuccess> login({String? token}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'anonymousIdp',
        'login',
        {'token': token},
      );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Public "demo household" for hosted judging. Each signed-in (anonymous)
/// caller gets ONE isolated household (owner Priya linked to the caller,
/// child Ana, a server-side demo hub with its own Ed25519 key) and can only
/// ever act on that household. Unlike DevEndpoint there is no way to reach
/// someone else's household, approve as an owner, rewrite a hub key or
/// seed arbitrary data. Every attestation still goes through
/// [AttestationService.submit] (real signature verification + audit), and
/// the MCP guard is untouched.
/// {@category Endpoint}
class EndpointDemo extends _isc.EndpointRef {
  EndpointDemo(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'demo';

  /// Whether this server hosts the demo. No login needed, reveals nothing
  /// else.
  _ida.Future<bool> available() => caller.callServerEndpoint<bool>(
    'demo',
    'available',
    {},
  );

  /// Creates (or returns) the caller's own demo household.
  _ida.Future<_iftolq1m.DemoStart> start() =>
      caller.callServerEndpoint<_iftolq1m.DemoStart>(
        'demo',
        'start',
        {},
      );

  /// Signs, with the caller's demo hub key, an attestation that [memberId]
  /// said [utterance], and submits it through the normal verification path.
  _ida.Future<_i518k1n9.Attestation> attest(
    int memberId,
    String utterance,
  ) => caller.callServerEndpoint<_i518k1n9.Attestation>(
    'demo',
    'attest',
    {
      'memberId': memberId,
      'utterance': utterance,
    },
  );

  /// Mints an MCP bearer token for the caller's own demo household. Raw
  /// token returned once; only its hash is stored.
  _ida.Future<String> mintMcpToken() => caller.callServerEndpoint<String>(
    'demo',
    'mintMcpToken',
    {},
  );
}

/// Dev-only convenience endpoint for standing up a demo household without
/// hand-writing SQL or a bespoke script. Used by the hub team to get a
/// `hubId` + public key registration and an MCP bearer token in one call,
/// and by the terminal demo to approve a step-up without a phone.
///
/// Every method throws unless the server is running in development mode —
/// this must never be reachable in staging/production.
/// {@category Endpoint}
class EndpointDev extends _isc.EndpointRef {
  EndpointDev(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'dev';

  /// Capability probe for the app's "Try the demo household" button: true
  /// iff the other DevEndpoint methods would be allowed on this server.
  /// Unauthenticated and returns nothing but that boolean; it does not
  /// relax [DevModeGuard], which every other method still enforces.
  _ida.Future<bool> demoAvailable() => caller.callServerEndpoint<bool>(
    'dev',
    'demoAvailable',
    {},
  );

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
  _ida.Future<_i6j5s1j2.DemoSeed> seedDemoHousehold(
    String ownerName,
    String childName,
    String hubPublicKeyBase64,
  ) => caller.callServerEndpoint<_i6j5s1j2.DemoSeed>(
    'dev',
    'seedDemoHousehold',
    {
      'ownerName': ownerName,
      'childName': childName,
      'hubPublicKeyBase64': hubPublicKeyBase64,
    },
  );

  /// DEV-ONLY convenience for the terminal demo: approves [approvalId] "as
  /// the household owner" without a phone/Flutter admin app round trip.
  ///
  /// Deliberately goes through the exact same code path as a real owner
  /// decision (`ApprovalEndpoint.decide`'s update logic) so that policy
  /// enforcement and audit records are identical to production — the only
  /// thing skipped is the owner-identity check itself, which is the whole
  /// point of a dev shortcut. NEVER expose this outside development mode.
  _ida.Future<_irq51xio.Approval?> approveAsOwner(int approvalId) =>
      caller.callServerEndpoint<_irq51xio.Approval?>(
        'dev',
        'approveAsOwner',
        {'approvalId': approvalId},
      );

  /// DEV-ONLY convenience for scripted conformance tests (see
  /// `tool/mcp_conformance`): returns the id of the most recently created
  /// still-pending [Approval] for [householdId], or null if there is none.
  /// Lets a test client discover the approval id without parsing the
  /// signed `approvalRef`/`requestState` blob itself.
  _ida.Future<int?> latestPendingApprovalId(int householdId) =>
      caller.callServerEndpoint<int?>(
        'dev',
        'latestPendingApprovalId',
        {'householdId': householdId},
      );

  /// DEV-ONLY convenience for scripted conformance tests: mints a fresh
  /// Ed25519 keypair, overwrites [hubId]'s stored public key with it (the
  /// dev-seeded hub's "key" from `seedDemoHousehold` is just caller-
  /// supplied bytes, not a real keypair the caller can sign with), then
  /// signs and submits a real attestation for [memberId] at [tier] bound
  /// to [utterance] via the normal [AttestationService.submit] path — the
  /// same verification code real hub traffic goes through. Lets a
  /// scripted (e.g. Node) test drive the "recognised speaker" precondition
  /// for a T1/T2 step-up without reimplementing Ed25519 signing itself.
  _ida.Future<_i518k1n9.Attestation> issueTestAttestation(
    int hubId,
    int memberId,
    String tier,
    String utterance,
  ) => caller.callServerEndpoint<_i518k1n9.Attestation>(
    'dev',
    'issueTestAttestation',
    {
      'hubId': hubId,
      'memberId': memberId,
      'tier': tier,
      'utterance': utterance,
    },
  );

  /// DEV-ONLY: sets [householdId]'s owner `Member.authUserId` to the
  /// signed-in caller, so a demo household seeded via [seedDemoHousehold]
  /// (which has no linked login for its owner) becomes usable from the
  /// Flutter admin app after the developer signs in. Guarded by the same
  /// dev-mode guard as every other method here — never reachable in
  /// staging/production, where ownership must never be reassignable by a
  /// bare RPC call with no further proof of anything.
  _ida.Future<_iijtn340.Member> claimOwner(int householdId) =>
      caller.callServerEndpoint<_iijtn340.Member>(
        'dev',
        'claimOwner',
        {'householdId': householdId},
      );

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
  _ida.Future<String> mintMcpToken(int householdId) =>
      caller.callServerEndpoint<String>(
        'dev',
        'mintMcpToken',
        {'householdId': householdId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i5wyqq9r.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5wyqq9r.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Serverpod endpoint for the Flutter admin app: a live, owner-only stream
/// of everything happening in a household (attestations, policy decisions,
/// step-up approvals), backing a status view without polling the audit
/// log.
///
/// Authorization mirrors `ApprovalEndpoint`'s owner check exactly (same
/// `Member.authUserId` -> owner-of-this-household resolution) — see
/// `approval_endpoint.dart` for the rationale.
/// {@category Endpoint}
class EndpointHousehold extends _isc.EndpointRef {
  EndpointHousehold(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'household';

  /// Real-time stream of [HouseholdEvent]s for [householdId] — one is
  /// published for every `AuditService.append` call (see audit_service.dart),
  /// so this is a live superset view of the household's audit log.
  _ida.Stream<_i9hh6y82.HouseholdEvent> householdStatus(int householdId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_i9hh6y82.HouseholdEvent>,
        _i9hh6y82.HouseholdEvent
      >(
        'household',
        'householdStatus',
        {'householdId': householdId},
        {},
      );

  /// Cheap pre-check for the app's cold start: true iff the signed-in
  /// caller is linked to an owner member (i.e. [myHousehold] would
  /// resolve). Returns a plain false for an unpaired session instead of
  /// the [NotHouseholdOwnerException] that [myHousehold] still throws.
  /// Reveals only a boolean about the caller themselves.
  _ida.Future<bool> hasHousehold() => caller.callServerEndpoint<bool>(
    'household',
    'hasHousehold',
    {},
  );

  /// The signed-in owner's own household: the household row, all its
  /// members, and all its registered hubs. Resolves the caller to a
  /// household purely via `Member.authUserId` (no caller-supplied
  /// household id to check against), so this is the entry point the
  /// Flutter app uses right after sign-in, before it knows any id at all.
  _ida.Future<_itnkoaqw.HouseholdOverview> myHousehold() =>
      caller.callServerEndpoint<_itnkoaqw.HouseholdOverview>(
        'household',
        'myHousehold',
        {},
      );

  /// All members of [householdId]. Owner-only, same authorization as every
  /// other household-scoped query here.
  _ida.Future<List<_iijtn340.Member>> members(int householdId) =>
      caller.callServerEndpoint<List<_iijtn340.Member>>(
        'household',
        'members',
        {'householdId': householdId},
      );

  /// All [Enrolment]s for [householdId]'s members — the Flutter admin app's
  /// Members screen shows enrolment status (quality, sample count) alongside
  /// each member without exposing any biometric data (see
  /// `identity/enrolment.spy.yaml`: only an opaque `embeddingRef` is ever
  /// stored). Owner-only, same authorization as every other query here.
  _ida.Future<List<_ixzes3t5.Enrolment>> enrolments(int householdId) =>
      caller.callServerEndpoint<List<_ixzes3t5.Enrolment>>(
        'household',
        'enrolments',
        {'householdId': householdId},
      );

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
  _ida.Future<_iijtn340.Member> revokeMember(int memberId) =>
      caller.callServerEndpoint<_iijtn340.Member>(
        'household',
        'revokeMember',
        {'memberId': memberId},
      );

  /// Owner-only: restores a previously-revoked member back to
  /// [MemberStatus.active], so future attestations can be minted for them
  /// again. Writes an [AuditEvent] (`member.restore`) so the Home/Activity
  /// feed updates live. Throws [NotHouseholdOwnerException] if the caller
  /// isn't this household's owner.
  _ida.Future<_iijtn340.Member> restoreMember(int memberId) =>
      caller.callServerEndpoint<_iijtn340.Member>(
        'household',
        'restoreMember',
        {'memberId': memberId},
      );
}

/// Endpoint the hub calls right after it saves a local voiceprint centroid,
/// so the server (and Flutter admin app) can show enrolment status without
/// ever seeing the voiceprint itself — only an opaque `embeddingRef` plus
/// quality metadata is stored. Reuses the pre-existing `Enrolment` model
/// (identity/enrolment.spy.yaml) rather than adding a new table.
///
/// Ed25519-signed by the hub over the canonical payload built from exactly
/// the reported fields (see [EnrolmentSignature.canonicalPayload]), the
/// same signing discipline as attestation submission.
/// {@category Endpoint}
class EndpointEnrolment extends _isc.EndpointRef {
  EndpointEnrolment(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'enrolment';

  _ida.Future<_ixzes3t5.Enrolment> report({
    required int hubId,
    required int memberId,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime capturedAt,
    required String signatureBase64,
  }) => caller.callServerEndpoint<_ixzes3t5.Enrolment>(
    'enrolment',
    'report',
    {
      'hubId': hubId,
      'memberId': memberId,
      'embeddingRef': embeddingRef,
      'qualityScore': qualityScore,
      'sampleCount': sampleCount,
      'capturedAt': capturedAt,
      'signatureBase64': signatureBase64,
    },
  );
}

/// Endpoint backing the hub-pairing flow (anonymous auth + hub pairing,
/// not email): the hub signs and mints a short-lived 6-digit code
/// ([createCode]); the anonymously-signed-in Flutter app redeems it
/// ([redeem]) to link its session to the household owner `Member`.
/// {@category Endpoint}
class EndpointPairing extends _isc.EndpointRef {
  EndpointPairing(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'pairing';

  /// Called by the hub (Ed25519-signed the same way as enrolment reports —
  /// see `EnrolmentSignature`/`AttestationSignature`) to mint a fresh
  /// 6-digit pairing code for its household. Returns the raw code exactly
  /// once; only its SHA-256 hash is persisted (see `PairingCode.codeHash`).
  _ida.Future<String> createCode({
    required int hubId,
    required DateTime capturedAt,
    required String signatureBase64,
  }) => caller.callServerEndpoint<String>(
    'pairing',
    'createCode',
    {
      'hubId': hubId,
      'capturedAt': capturedAt,
      'signatureBase64': signatureBase64,
    },
  );

  /// Called by the signed-in (anonymous) app user to redeem a pairing
  /// [code]: single-use, must not be expired. On success, links the
  /// code's owner `Member.authUserId` to the caller's session and returns
  /// the household overview (mirrors `HouseholdEndpoint.myHousehold`'s
  /// shape) so the app can proceed straight into the shell. Rate-limited
  /// per signed-in caller and every attempt is audited, successful or not.
  _ida.Future<_itnkoaqw.HouseholdOverview> redeem(String code) =>
      caller.callServerEndpoint<_itnkoaqw.HouseholdOverview>(
        'pairing',
        'redeem',
        {'code': code},
      );
}

/// Serverpod endpoint for the Flutter admin app's Rules screen: preview a
/// plain-language rule (Nemotron-compiled, not saved), confirm it (saved),
/// list a household's rules, and disable one. Owner-only throughout — same
/// `Member.authUserId` -> owner-of-this-household check as
/// `ApprovalEndpoint`/`HouseholdEndpoint`.
/// {@category Endpoint}
class EndpointRules extends _isc.EndpointRef {
  EndpointRules(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'rules';

  /// Compiles [text] into proposed [PolicyRule]s for [householdId] via
  /// Nemotron. Nothing is saved — the Flutter app shows [RulePreviewResult
  /// .proposals] for confirmation and calls [confirm] with whichever the
  /// admin accepts (which may be a subset, or edited).
  _ida.Future<_ip13g5m4.RulePreviewResult> preview(
    int householdId,
    String text,
  ) => caller.callServerEndpoint<_ip13g5m4.RulePreviewResult>(
    'rules',
    'preview',
    {
      'householdId': householdId,
      'text': text,
    },
  );

  /// Re-validates and saves [proposals] as [PolicyRule] rows, all sourced
  /// from [sourceText] (the original plain-language input). All-or-nothing:
  /// if any proposal fails re-validation, nothing is saved.
  _ida.Future<List<_itvg2dtw.PolicyRule>> confirm(
    int householdId,
    List<_i6o75vgd.RuleProposal> proposals,
    String sourceText,
  ) => caller.callServerEndpoint<List<_itvg2dtw.PolicyRule>>(
    'rules',
    'confirm',
    {
      'householdId': householdId,
      'proposals': proposals,
      'sourceText': sourceText,
    },
  );

  /// Lists every [PolicyRule] (enabled or not) for [householdId].
  _ida.Future<List<_itvg2dtw.PolicyRule>> list(int householdId) =>
      caller.callServerEndpoint<List<_itvg2dtw.PolicyRule>>(
        'rules',
        'list',
        {'householdId': householdId},
      );

  /// Disables [ruleId] (`enabled = false`) — rules are never deleted, only
  /// disabled, so the audit trail of "what was ever configured" survives.
  _ida.Future<_itvg2dtw.PolicyRule?> disable(int ruleId) =>
      caller.callServerEndpoint<_itvg2dtw.PolicyRule?>(
        'rules',
        'disable',
        {'ruleId': ruleId},
      );

  /// Owner-only: classifies an unknown tool's risk via
  /// [ToolRiskClassifier] and caches the result in [ToolClassification]
  /// (keyed by tool name, upserted) so the guard path can reuse it instead
  /// of calling Nemotron on every evaluation. [householdId] is only used
  /// to authorize the caller as an owner — the cached result itself is
  /// shared across households, matching the shared MCP tool catalogue.
  _ida.Future<_ir2xlo1r.ToolClassification> classifyTool(
    int householdId,
    String name,
    String description,
    String inputSchemaJson,
  ) => caller.callServerEndpoint<_ir2xlo1r.ToolClassification>(
    'rules',
    'classifyTool',
    {
      'householdId': householdId,
      'name': name,
      'description': description,
      'inputSchemaJson': inputSchemaJson,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    approval = EndpointApproval(this);
    attestation = EndpointAttestation(this);
    audit = EndpointAudit(this);
    anonymousIdp = EndpointAnonymousIdp(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    demo = EndpointDemo(this);
    dev = EndpointDev(this);
    greeting = EndpointGreeting(this);
    household = EndpointHousehold(this);
    enrolment = EndpointEnrolment(this);
    pairing = EndpointPairing(this);
    rules = EndpointRules(this);
    modules = Modules(this);
  }

  late final EndpointApproval approval;

  late final EndpointAttestation attestation;

  late final EndpointAudit audit;

  late final EndpointAnonymousIdp anonymousIdp;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointDemo demo;

  late final EndpointDev dev;

  late final EndpointGreeting greeting;

  late final EndpointHousehold household;

  late final EndpointEnrolment enrolment;

  late final EndpointPairing pairing;

  late final EndpointRules rules;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'approval': approval,
    'attestation': attestation,
    'audit': audit,
    'anonymousIdp': anonymousIdp,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'demo': demo,
    'dev': dev,
    'greeting': greeting,
    'household': household,
    'enrolment': enrolment,
    'pairing': pairing,
    'rules': rules,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
