import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/data/demo_session.dart';
import 'package:vouch_flutter/data/mcp/mcp_gateway.dart';
import 'package:vouch_flutter/logic/alexa_controller.dart';

import '../fakes/fake_mcp_gateway.dart';
import '../fakes/fake_repositories.dart';

class _AttestingDemoRepository extends FakeDemoRepository {
  @override
  Future<void> attest({
    required int hubId,
    required int memberId,
    required String utterance,
  }) async {
    issuedAttestations.add((memberId, utterance));
  }
}

void main() {
  tearDown(() => DemoSession.current = null);

  testWidgets('replay reuses the completed state without new attestation', (
    tester,
  ) async {
    DemoSession.current = const DemoSession(
      hubId: 2,
      ownerMemberId: 3,
      childMemberId: 4,
    );
    final demo = _AttestingDemoRepository();
    final gateway = FakeMcpGateway([
      const McpInputRequired(
        [],
        requestState: 'single-use-state',
        message: 'Waiting for owner',
      ),
      const McpComplete([], text: 'Approved', isError: false),
      const McpComplete(
        [],
        text: 'Denied: approval already used',
        isError: true,
      ),
    ]);
    final controller = AlexaController(
      demoRepository: demo,
      householdRepository: FakeHouseholdRepository(
        overview: HouseholdOverview(
          household: Household(
            id: 1,
            name: 'Demo',
            createdAt: DateTime.utc(2026),
          ),
          members: const [],
          hubs: const [],
        ),
      ),
      householdId: 1,
      mcpUrl: 'http://localhost/mcp',
      gatewayFactory: ({required mcpUrl, required token}) => gateway,
    );
    addTearDown(controller.dispose);

    await controller.sendUtterance('Unlock the front door');
    expect(controller.canReplayApprovedRequest, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(controller.canReplayApprovedRequest, isTrue);

    await controller.replayApprovedRequest();
    expect(gateway.requestStates, [
      null,
      'single-use-state',
      'single-use-state',
    ]);
    expect(demo.issuedAttestations, hasLength(1));
    expect(controller.statusMessage, contains('already used'));
    expect(controller.inFlight, isFalse);
    expect(controller.canReplayApprovedRequest, isFalse);

    await controller.replayApprovedRequest();
    expect(gateway.calls, hasLength(3));
  });
}
