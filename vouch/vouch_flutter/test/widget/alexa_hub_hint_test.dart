import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/logic/alexa_controller.dart';
import 'package:vouch_flutter/screens/alexa_screen.dart';

import '../fakes/fake_hub_client.dart';
import '../fakes/fake_mcp_gateway.dart';
import '../fakes/fake_repositories.dart';

HouseholdOverview _overview() => HouseholdOverview(
      household: Household(
        id: 1,
        name: 'Test household',
        createdAt: DateTime.now().toUtc(),
      ),
      members: const [],
      hubs: const [],
    );

void main() {
  testWidgets(
    'Alexa screen shows a hub-unreachable hint and keeps the text box working '
    'when the hub is down',
    (tester) async {
      final fakeHub = FakeHubClient(healthy: false);
      final controller = AlexaController(
        demoRepository: FakeDemoRepository(),
        householdRepository: FakeHouseholdRepository(overview: _overview()),
        householdId: 1,
        mcpUrl: 'http://localhost:8082/mcp',
        gatewayFactory: ({required mcpUrl, required token}) => FakeMcpGateway([]),
        hubClient: fakeHub,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AlexaController>.value(
            value: controller,
            child: const Scaffold(body: AlexaScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakeHub.healthChecks, 1);
      expect(controller.hubHealthy, false);
      expect(
        find.textContaining('cd hub && .venv/bin/python -m vouch_hub serve'),
        findsOneWidget,
      );

      // The text box keeps working even though the hub is unreachable.
      await tester.enterText(
        find.byKey(const Key('alexa-text-field')),
        "What's the weather?",
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byKey(const Key('alexa-text-field')),
          matching: find.text("What's the weather?"),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Healthy hub shows no hint', (tester) async {
    final fakeHub = FakeHubClient(healthy: true);
    final controller = AlexaController(
      demoRepository: FakeDemoRepository(),
      householdRepository: FakeHouseholdRepository(overview: _overview()),
      householdId: 1,
      mcpUrl: 'http://localhost:8082/mcp',
      gatewayFactory: ({required mcpUrl, required token}) => FakeMcpGateway([]),
      hubClient: fakeHub,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AlexaController>.value(
          value: controller,
          child: const Scaffold(body: AlexaScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.hubHealthy, true);
    expect(
      find.textContaining('vouch_hub serve'),
      findsNothing,
    );
  });
}
