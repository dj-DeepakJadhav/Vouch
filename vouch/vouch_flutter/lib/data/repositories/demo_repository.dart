import 'package:vouch_client/vouch_client.dart';

/// Which server API backs "Try the demo household".
enum DemoBackend {
  /// `DemoEndpoint` (server started with `demoMode: true`, any run mode).
  /// Scoped to the caller's own demo household; safe to host publicly.
  hosted,

  /// `DevEndpoint` fallback for a local `serverpod start` without demoMode.
  dev,

  /// Neither: hide the demo button.
  none,
}

/// Prefers the hosted demo; falls back to the dev shortcuts only when the
/// hosted demo is off. Errors (older server, unreachable) count as "no".
Future<DemoBackend> chooseDemoBackend({
  required Future<bool> Function() hostedAvailable,
  required Future<bool> Function() devAvailable,
}) async {
  Future<bool> safe(Future<bool> Function() probe) async {
    try {
      return await probe();
    } catch (_) {
      return false;
    }
  }

  if (await safe(hostedAvailable)) return DemoBackend.hosted;
  if (await safe(devAvailable)) return DemoBackend.dev;
  return DemoBackend.none;
}

/// The calls the demo flow and the simulated Alexa tab need.
abstract class DemoRepository {
  /// Creates (hosted: or returns) the caller's demo household and links
  /// the signed-in session to its owner.
  Future<DemoStart> start();

  /// A fresh MCP bearer token for [householdId] (owner-only server-side).
  Future<String> mintMcpToken(int householdId);

  /// Has the (simulated) hub vouch that [memberId] said [utterance].
  Future<void> attest({
    required int hubId,
    required int memberId,
    required String utterance,
  });
}

DemoRepository demoRepositoryFor(Client client, DemoBackend backend) =>
    backend == DemoBackend.hosted
    ? HostedDemoRepository(client)
    : DevDemoRepository(client);

/// `DemoEndpoint`: the server holds the demo hub key and only ever acts on
/// the caller's own demo household, so no ids beyond the member are sent.
class HostedDemoRepository implements DemoRepository {
  HostedDemoRepository(this._client);
  final Client _client;

  @override
  Future<DemoStart> start() => _client.demo.start();

  @override
  Future<String> mintMcpToken(int householdId) => _client.demo.mintMcpToken();

  @override
  Future<void> attest({
    required int hubId,
    required int memberId,
    required String utterance,
  }) => _client.demo.attest(memberId, utterance);
}

/// `DevEndpoint`: local development only (the server refuses it in any
/// other run mode). Also mints tokens for hub-paired households in dev.
class DevDemoRepository implements DemoRepository {
  DevDemoRepository(this._client);
  final Client _client;

  @override
  Future<DemoStart> start() async {
    final seed = await _client.dev.seedDemoHousehold(
      'Priya',
      'Ana',
      // Hub public keys are unique; the first dev attestation replaces
      // this placeholder, but until then it must not collide.
      'demo-key-${DateTime.now().microsecondsSinceEpoch}',
    );
    await _client.dev.claimOwner(seed.householdId);
    return DemoStart(
      householdId: seed.householdId,
      hubId: seed.hubId,
      ownerMemberId: seed.ownerMemberId,
      childMemberId: seed.childMemberId,
    );
  }

  @override
  Future<String> mintMcpToken(int householdId) =>
      _client.dev.mintMcpToken(householdId);

  @override
  Future<void> attest({
    required int hubId,
    required int memberId,
    required String utterance,
  }) => _client.dev.issueTestAttestation(hubId, memberId, 't1', utterance);
}
