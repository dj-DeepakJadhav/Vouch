import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/logic/household_controller.dart';
import 'package:vouch_flutter/logic/rules_controller.dart';
import 'package:vouch_flutter/screens/rules_screen.dart';

import '../fakes/fake_repositories.dart';

HouseholdOverview _overview() => HouseholdOverview(
      household: Household(id: 1, name: 'Test household', createdAt: DateTime.now().toUtc()),
      members: [
        Member(
          id: 7,
          householdId: 1,
          displayName: 'Ana',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      ],
      hubs: const [],
    );

Widget _wrap(RulesController controller) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<RulesController>.value(value: controller),
        ChangeNotifierProvider<HouseholdController>(
          create: (_) => HouseholdController(
            repository: FakeHouseholdRepository(overview: _overview()),
            householdId: 1,
          )..load(),
        ),
      ],
      child: const Scaffold(body: RulesScreen()),
    ),
  );
}

void main() {
  testWidgets('Preview renders a proposal with its explanation and tier', (tester) async {
    final repo = FakeRulesRepository(
      previewResult: RulePreviewResult(
        proposals: [
          RuleProposal(
            actionPattern: 'place_order',
            requiredTier: TrustTier.t2,
            effect: PolicyEffect.deny,
            explanation: "Ana can't place orders over 10 EUR.",
            argConditions: '{"maxAmount":10,"currency":"EUR"}',
          ),
        ],
        rejected: [],
        rawModelOutput: 'raw',
      ),
    );
    final controller = RulesController(repository: repo, householdId: 1);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('rule-text-field')),
      "Ana can't buy anything over 10 euros",
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('preview-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rule-preview-panel')), findsOneWidget);
    expect(find.text("Ana can't place orders over 10 EUR."), findsOneWidget);
    expect(find.text('Owner approves'), findsWidgets);
  });

  testWidgets('Preview renders a validation error for a rejected proposal', (tester) async {
    final repo = FakeRulesRepository(
      previewResult: RulePreviewResult(
        proposals: [],
        rejected: ['"guests" is not a known role or member'],
        rawModelOutput: 'raw',
      ),
    );
    final controller = RulesController(repository: repo, householdId: 1);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('rule-text-field')),
      'guests can do anything',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('preview-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rejected-proposal')), findsOneWidget);
    expect(find.textContaining('is not a known role or member'), findsOneWidget);
  });
}
