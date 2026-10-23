import 'package:vouch_client/vouch_client.dart';

import 'repositories/approval_repository.dart';
import 'repositories/audit_repository.dart';
import 'repositories/demo_repository.dart';
import 'repositories/household_repository.dart';
import 'repositories/rules_repository.dart';

/// The MCP endpoint URL. Overridable the same way the server URL is (see
/// client.dart's `getServerUrl`): `--dart-define=MCP_URL=...`. Defaults to
/// the dev server's MCP port (http://localhost:8082/mcp).
String getMcpUrl() => const String.fromEnvironment(
  'MCP_URL',
  defaultValue: 'http://localhost:8082/mcp',
);

/// Everything a signed-in, household-resolved app needs, bundled once so
/// screens don't each have to know how to construct a repository. Built
/// from the real [Client] in production; widget tests build one from fake
/// repositories instead (see test/fakes/).
class ReposBundle {
  ReposBundle({
    required this.householdId,
    required this.householdRepository,
    required this.approvalRepository,
    required this.rulesRepository,
    required this.auditRepository,
    required this.demoRepository,
    required this.mcpUrl,
  });

  factory ReposBundle.fromClient(
    Client client, {
    required int householdId,
    DemoBackend demoBackend = DemoBackend.dev,
  }) {
    return ReposBundle(
      householdId: householdId,
      householdRepository: ServerpodHouseholdRepository(client),
      approvalRepository: ServerpodApprovalRepository(client),
      rulesRepository: ServerpodRulesRepository(client),
      auditRepository: ServerpodAuditRepository(client),
      demoRepository: demoRepositoryFor(client, demoBackend),
      mcpUrl: getMcpUrl(),
    );
  }

  final int householdId;
  final HouseholdRepository householdRepository;
  final ApprovalRepository approvalRepository;
  final RulesRepository rulesRepository;
  final AuditRepository auditRepository;

  /// Hosted DemoEndpoint or local DevEndpoint, picked at startup.
  final DemoRepository demoRepository;
  final String mcpUrl;
}
