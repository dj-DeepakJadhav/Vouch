import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_flutter/design/design.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/data/mcp/mcp_gateway.dart';
import 'package:vouch_flutter/logic/alexa_controller.dart';
import 'package:vouch_flutter/screens/alexa_screen.dart';

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

const _mild = <String, dynamic>{
  'speaker': {
    'memberId': 1,
    'displayName': 'Alice',
    'role': 'owner',
  },
  'confidence': 0.86,
  'attestationMatched': true,
  'matchedTranscript': "what's the weather?",
  'requiredTier': 't0',
  'presentTier': 't0',
  'decision': 'allow',
  'reason': "It's mild.",
  'ruleSource': null,
};

const _denied = <String, dynamic>{
  'speaker': null,
  'confidence': null,
  'attestationMatched': false,
  'matchedTranscript': null,
  'requiredTier': 't2',
  'presentTier': 't0',
  'decision': 'deny',
  'reason': 'Not allowed.',
  'ruleSource': "children may never place orders",
};

void main() {
  testWidgets(
    'Alexa screen renders a decision trace panel with tick/cross steps',
    (tester) async {
      final fakeGateway = FakeMcpGateway([
        McpComplete(
          buildVouchTraceSteps(
            utterance: "What's the weather?",
            vouch: _mild,
          ),
          text: "It's mild.",
          isError: false,
          vouch: _mild,
        ),
      ]);

      final controller = AlexaController(
        demoRepository: FakeDemoRepository(),
        householdRepository: FakeHouseholdRepository(overview: _overview()),
        householdId: 1,
        mcpUrl: 'http://localhost:8082/mcp',
        gatewayFactory: ({required mcpUrl, required token}) => fakeGateway,
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

      await tester.enterText(
        find.byKey(const Key('alexa-text-field')),
        "What's the weather?",
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Send to Alexa+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send to Alexa+'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('decision-trace-panel')), findsOneWidget);
      expect(find.text('Who spoke'), findsOneWidget);
      expect(find.text('Matches what Alexa sent'), findsOneWidget);
      await tester.tap(find.byKey(const Key('trace-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Heard'), findsOneWidget);
      expect(find.text('Voice recognised'), findsOneWidget);
      expect(find.text('Transcript matches Alexa'), findsOneWidget);
      expect(find.text('Rule'), findsOneWidget);
      expect(find.text('Owner approval'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);
      expect(find.textContaining('Alice · owner'), findsOneWidget);
      expect(find.textContaining("It's mild."), findsWidgets);
      expect(fakeGateway.calls, contains('get_weather'));
    },
  );

  testWidgets('A denied tool call renders a fail step in the trace', (
    tester,
  ) async {
    final fakeGateway = FakeMcpGateway([
      McpComplete(
        buildVouchTraceSteps(
          utterance: 'Unlock the front door',
          vouch: _denied,
        ),
        text: 'Not allowed.',
        isError: true,
        vouch: _denied,
      ),
    ]);

    final controller = AlexaController(
      demoRepository: FakeDemoRepository(),
      householdRepository: FakeHouseholdRepository(overview: _overview()),
      householdId: 1,
      mcpUrl: 'http://localhost:8082/mcp',
      gatewayFactory: ({required mcpUrl, required token}) => fakeGateway,
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

    await tester.enterText(
      find.byKey(const Key('alexa-text-field')),
      'Unlock the front door',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Send to Alexa+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send to Alexa+'));
    await tester.pumpAndSettle();

    expect(
      find.text('Blocked. Vouch doesn\'t recognise this voice.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('trace-toggle')));
    await tester.tap(find.byKey(const Key('trace-toggle')));
    await tester.pumpAndSettle();
    expect(find.byIcon(VIcons.fail), findsWidgets);
  });
}
