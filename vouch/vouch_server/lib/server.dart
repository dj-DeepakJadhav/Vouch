import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/generated/serverpod.dart';
import 'src/mcp/mcp_route.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Hand-rolled MCP server (spec 2026-07-28, Streamable HTTP, MRTR) mounted
  // as a Relic route — see mcp/mcp_route.dart and Docs/spikes/S8-dart-mcp.md.
  pod.webServer.addRoute(McpRoute(), '/mcp');

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // The app's own sign-in flow is anonymous + hub pairing (see
      // pairing/pairing_endpoint.dart): on launch the app signs in
      // anonymously with no UI, then redeems a 6-digit code the hub prints
      // to link that anonymous session to the household owner `Member`.
      // This is the identity provider the app actually uses.
      const AnonymousIdpConfig(),
      // Kept configured server-side (NOT surfaced in the app's UI/flow) for
      // developer/support purposes only. The default setup works
      // with Serverpod Cloud without configuration. In development the
      // verification codes are logged to the console, and in staging and
      // production they are sent through the Serverpod Cloud email service.
      // If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'vouch',
      ),
    ],
  );

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Start the server.
  await pod.start();

  // Recurring sweeps. Must run AFTER pod.start(): FutureCalls is not
  // initialised before that, and registering earlier crashes startup.
  //
  // Registration must be idempotent: `run()` re-executes on every server
  // restart (and this whole file is re-run under `serverpod start`'s watch
  // mode), so calling `callRecurring` with the same identifier again would
  // register a *second* recurring schedule alongside the still-live one
  // from the previous run, doubling the firing rate (observed: two sweeps
  // per minute instead of one). Cancel any existing registration for the
  // identifier first — `cancel` is a no-op if none exists — so each restart
  // ends up with exactly one live recurring call per identifier.
  //
  // Recurring sweep that marks expired, unconsumed attestations as revoked
  // (see AttestationCleanupFutureCall / attestation_service.dart).
  await pod.futureCalls.cancel('attestation-cleanup-sweep');
  await pod.futureCalls
      .callRecurring(identifier: 'attestation-cleanup-sweep')
      .every(const Duration(minutes: 1), start: DateTime.now())
      .attestationCleanup
      .sweep();

  // Recurring sweep that expires pending step-up Approvals past their
  // window (see ApprovalExpiryFutureCall / approval_expiry_future_call.dart).
  await pod.futureCalls.cancel('approval-expiry-sweep');
  await pod.futureCalls
      .callRecurring(identifier: 'approval-expiry-sweep')
      .every(const Duration(minutes: 1), start: DateTime.now())
      .approvalExpiry
      .sweep();
}
