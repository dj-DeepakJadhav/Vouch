import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/logic/audit_controller.dart';
import 'package:vouch_flutter/screens/activity_screen.dart';

import '../fakes/fake_repositories.dart';

void main() {
  testWidgets('Activity row expands to show why, tier and confidence', (
    tester,
  ) async {
    final event = AuditEvent(
      id: 7,
      householdId: 1,
      memberId: 2,
      eventType: 'mcp.tool_call',
      action: 'unlock_front_door',
      decision: AuditDecision.denied,
      tierRequired: TrustTier.t2,
      tierPresent: TrustTier.t1,
      reason: 'the voice that said this isn\'t allowed to unlock doors',
      confidence: 0.82,
      createdAt: DateTime.now().toUtc(),
    );
    final repo = FakeAuditRepository(events: [event]);
    final controller = AuditController(repository: repo, householdId: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuditController>.value(
          value: controller,
          child: const Scaffold(body: ActivityScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit-why-7')), findsNothing);

    await tester.tap(find.byKey(const Key('audit-row-7')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit-why-7')), findsOneWidget);
    expect(
      find.textContaining("isn't allowed to unlock doors"),
      findsOneWidget,
    );
    expect(find.textContaining('Needed: Owner approves'), findsOneWidget);
    expect(find.textContaining('Had: Known voice'), findsOneWidget);
    expect(find.textContaining('Confidence: 82%'), findsOneWidget);
  });

  testWidgets('Blocked-first toggle reorders denied events to the top', (
    tester,
  ) async {
    final now = DateTime.now().toUtc();
    final allowed = AuditEvent(
      id: 1,
      householdId: 1,
      eventType: 'mcp.tool_call',
      action: 'get_weather',
      decision: AuditDecision.permitted,
      reason: 'ok',
      createdAt: now,
    );
    final denied = AuditEvent(
      id: 2,
      householdId: 1,
      eventType: 'mcp.tool_call',
      action: 'unlock_front_door',
      decision: AuditDecision.denied,
      reason: 'blocked',
      createdAt: now.subtract(const Duration(minutes: 1)),
    );
    final repo = FakeAuditRepository(events: [allowed, denied]);
    final controller = AuditController(repository: repo, householdId: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuditController>.value(
          value: controller,
          child: const Scaffold(body: ActivityScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('blocked-first-switch')));
    await tester.pumpAndSettle();

    final rows = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('audit-row-'),
    );
    final firstTitle = tester
        .widgetList<Text>(
          find.descendant(of: rows.first, matching: find.byType(Text)),
        )
        .first;
    expect(firstTitle.data, contains('unlock the front door'));
  });
}
