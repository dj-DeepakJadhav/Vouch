import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/dev/dev_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with an owner, a child and a hub', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member owner;
    const ownerAuthUserId = '11111111-2222-3333-4444-555555555555';

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Overview Test', createdAt: DateTime.now().toUtc()),
      );
      owner = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
        ),
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Child',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      );
      await Hub.db.insertRow(
        session,
        Hub(
          householdId: household.id!,
          publicKey: 'unique-test-pubkey-${household.id}',
          version: '0.0.1-test',
          lastSeen: DateTime.now().toUtc(),
        ),
      );
    });

    test(
      'when a dev-claimed owner calls myHousehold then it returns the '
      'household, its members and its hubs',
      () async {
        // Link via the dev-mode claimOwner call, using an authenticated
        // session so myHousehold can later resolve it.
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            ownerAuthUserId,
            {},
          ),
        );
        await DevEndpoint().claimOwner(authSession.build(), household.id!);

        final overview = await endpoints.household.myHousehold(authSession);
        expect(overview.household.id, household.id);
        expect(overview.members, hasLength(2));
        expect(overview.hubs, hasLength(1));

        final members = await endpoints.household.members(
          authSession,
          household.id!,
        );
        expect(members, hasLength(2));
      },
    );

    test(
      'when an unlinked signed-in user calls myHousehold then it is rejected',
      () async {
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-such-member-user',
            {},
          ),
        );
        await expectLater(
          endpoints.household.myHousehold(authSession),
          throwsA(isA<NotHouseholdOwnerException>()),
        );
      },
    );

    test(
      'when claimOwner is called under the default test run mode then it succeeds',
      () async {
        // DevModeGuard treats `test` run mode the same as `development` (see
        // dev_mode_guard.dart) — this just documents that claimOwner is
        // reachable under withServerpod's default test run mode, given a
        // signed-in caller.
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'some-other-auth-user-id',
            {},
          ),
        );
        final result = await DevEndpoint().claimOwner(
          authSession.build(),
          household.id!,
        );
        expect(result.id, owner.id);
      },
    );
  });
}
