import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/app/router.dart';
import 'package:vouch_flutter/app/shell.dart';
import 'package:vouch_flutter/app/theme.dart';
import 'package:vouch_flutter/data/repos_bundle.dart';

import '../fakes/fake_repositories.dart';

/// Every screen must render sensibly (no
/// overflow / render errors) at both a wide desktop size (1280x860, where
/// the shell shows a sidebar) and a narrow phone size (390x844, where it
/// shows a bottom tab bar).
void main() {
  final overview = HouseholdOverview(
    household: Household(
      id: 1,
      name: 'The Testers',
      createdAt: DateTime.now().toUtc(),
    ),
    members: [
      Member(
        id: 1,
        householdId: 1,
        displayName: 'Owner',
        role: MemberRole.owner,
        status: MemberStatus.active,
        authUserId: 'owner-auth-id',
      ),
      Member(
        id: 2,
        householdId: 1,
        displayName: 'Kid',
        role: MemberRole.child,
        status: MemberStatus.active,
      ),
    ],
    hubs: [
      Hub(
        id: 1,
        householdId: 1,
        publicKey: 'fake-pubkey',
        version: '0.0.1-test',
        lastSeen: DateTime.now().toUtc(),
      ),
    ],
  );

  final pendingApproval = Approval(
    id: 1,
    householdId: 1,
    memberId: 1,
    action: 'place_order',
    argsJson: '{"item":"playstation","amount":500}',
    utterance: 'order the new playstation for 500 euros',
    status: ApprovalStatus.pending,
    used: false,
    createdAt: DateTime.now().toUtc(),
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
  );

  final auditEvent = AuditEvent(
    householdId: 1,
    memberId: 1,
    eventType: 'attestation.issued',
    action: 'unlock_door',
    decision: AuditDecision.permitted,
    reason: 'owner recognised at T1',
    createdAt: DateTime.now().toUtc(),
  );

  ReposBundle buildBundle() => ReposBundle(
    householdId: 1,
    householdRepository: FakeHouseholdRepository(overview: overview),
    approvalRepository: FakeApprovalRepository(pending: [pendingApproval]),
    rulesRepository: FakeRulesRepository(),
    auditRepository: FakeAuditRepository(events: [auditEvent]),
    demoRepository: FakeDemoRepository(),
    mcpUrl: 'http://localhost:8082/mcp',
  );

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      VouchShellApp(
        bundle: buildBundle(),
        onSignOut: () {},
        theme: buildVouchTheme(Brightness.light),
        darkTheme: buildVouchTheme(Brightness.dark),
      ),
    );
    await tester.pumpAndSettle();
  }

  const desktop = Size(1280, 860);
  const phone = Size(390, 844);

  for (final size in [desktop, phone]) {
    final label = size == desktop ? '1280x860 (desktop)' : '390x844 (phone)';

    testWidgets('every tab renders without overflow at $label', (tester) async {
      await pumpShell(tester, size);
      expect(tester.takeException(), isNull);

      for (final destination in vouchDestinations) {
        if (destination.path == '/home') continue; // already showing
        final finder = find.descendant(
          of: find.byKey(vouchNavKey),
          matching: find.text(destination.label),
        );
        expect(
          finder,
          findsWidgets,
          reason: '${destination.label} nav destination missing',
        );
        await tester.tap(finder.first);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'exception rendering ${destination.path} at $label',
        );
      }
    });
  }
}
