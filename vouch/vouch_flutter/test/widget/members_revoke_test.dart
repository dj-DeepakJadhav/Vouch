import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/logic/members_controller.dart';
import 'package:vouch_flutter/screens/members_screen.dart';

import '../fakes/fake_repositories.dart';

HouseholdOverview _overview({required MemberStatus childStatus}) => HouseholdOverview(
  household: Household(id: 1, name: 'Test household', createdAt: DateTime.now().toUtc()),
  members: [
    Member(
      id: 7,
      householdId: 1,
      displayName: 'Ana',
      role: MemberRole.child,
      status: childStatus,
    ),
    Member(
      id: 1,
      householdId: 1,
      displayName: 'Owner',
      role: MemberRole.owner,
      status: MemberStatus.active,
    ),
  ],
  hubs: const [],
);

Widget _wrap(MembersController controller) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<MembersController>.value(value: controller),
      ],
      child: const Scaffold(body: MembersScreen()),
    ),
  );
}

void main() {
  testWidgets(
    'revoking a member shows a confirm dialog, and confirming calls the '
    'repository and updates the card to show Restore',
    (tester) async {
      final repo = FakeHouseholdRepository(
        overview: _overview(childStatus: MemberStatus.active),
      );
      final controller = MembersController(repository: repo, householdId: 1);

      await tester.pumpWidget(_wrap(controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('revoke-member-button-7')), findsOneWidget);
      expect(find.byKey(const Key('restore-member-button-7')), findsNothing);

      await tester.tap(find.byKey(const Key('revoke-member-button-7')));
      await tester.pumpAndSettle();

      // Confirm dialog is shown before anything happens.
      expect(find.text('Revoke voice trust?'), findsOneWidget);
      expect(repo.revokedMemberIds, isEmpty);

      await tester.tap(find.byKey(const Key('revoke-confirm-button')));
      await tester.pumpAndSettle();

      expect(repo.revokedMemberIds, [7]);
      expect(find.byKey(const Key('restore-member-button-7')), findsOneWidget);
      expect(find.byKey(const Key('revoke-member-button-7')), findsNothing);
      expect(
        find.textContaining('Voice trust revoked'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'cancelling the confirm dialog does not call the repository',
    (tester) async {
      final repo = FakeHouseholdRepository(
        overview: _overview(childStatus: MemberStatus.active),
      );
      final controller = MembersController(repository: repo, householdId: 1);

      await tester.pumpWidget(_wrap(controller));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('revoke-member-button-7')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('revoke-cancel-button')));
      await tester.pumpAndSettle();

      expect(repo.revokedMemberIds, isEmpty);
      expect(find.byKey(const Key('revoke-member-button-7')), findsOneWidget);
    },
  );

  testWidgets(
    'restoring a previously revoked member calls the repository directly, '
    'no confirm dialog',
    (tester) async {
      final repo = FakeHouseholdRepository(
        overview: _overview(childStatus: MemberStatus.revoked),
      );
      final controller = MembersController(repository: repo, householdId: 1);

      await tester.pumpWidget(_wrap(controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('restore-member-button-7')), findsOneWidget);

      await tester.tap(find.byKey(const Key('restore-member-button-7')));
      await tester.pumpAndSettle();

      expect(repo.restoredMemberIds, [7]);
      expect(find.byKey(const Key('revoke-member-button-7')), findsOneWidget);
    },
  );

  testWidgets(
    'the household owner is never shown a revoke or restore action',
    (tester) async {
      final repo = FakeHouseholdRepository(
        overview: _overview(childStatus: MemberStatus.active),
      );
      final controller = MembersController(repository: repo, householdId: 1);

      await tester.pumpWidget(_wrap(controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('revoke-member-button-1')), findsNothing);
      expect(find.byKey(const Key('restore-member-button-1')), findsNothing);
    },
  );
}
