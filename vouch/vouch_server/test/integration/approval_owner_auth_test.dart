import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with an owner, child and pending approval', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member owner;
    late Approval approval;

    const ownerAuthUserId = '11111111-1111-1111-1111-111111111111';
    const childAuthUserId = '22222222-2222-2222-2222-222222222222';
    const strangerAuthUserId = '33333333-3333-3333-3333-333333333333';

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Owner Auth Test', createdAt: DateTime.now().toUtc()),
      );
      owner = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: ownerAuthUserId,
        ),
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Child',
          role: MemberRole.child,
          status: MemberStatus.active,
          authUserId: childAuthUserId,
        ),
      );

      final now = DateTime.now().toUtc();
      approval = await Approval.db.insertRow(
        session,
        Approval(
          householdId: household.id!,
          memberId: owner.id,
          action: 'place_order',
          argsJson: '{}',
          utterance: 'order groceries',
          status: ApprovalStatus.pending,
          used: false,
          createdAt: now,
          expiresAt: now.add(const Duration(seconds: 60)),
        ),
      );
    });

    test('the household owner can decide the approval', () async {
      final authSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerAuthUserId,
          {},
        ),
      );

      final decided = await endpoints.approval.decide(
        authSession,
        approval.id!,
        true,
      );
      expect(decided!.status, ApprovalStatus.approved);
    });

    test('a child cannot decide the approval', () async {
      final authSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          childAuthUserId,
          {},
        ),
      );

      await expectLater(
        endpoints.approval.decide(authSession, approval.id!, true),
        throwsA(isA<NotHouseholdOwnerException>()),
      );

      final unchanged = await Approval.db.findById(session, approval.id!);
      expect(unchanged!.status, ApprovalStatus.pending);
    });

    test(
      'a signed-in user with no linked member cannot decide the approval',
      () async {
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            strangerAuthUserId,
            {},
          ),
        );

        await expectLater(
          endpoints.approval.decide(authSession, approval.id!, true),
          throwsA(isA<NotHouseholdOwnerException>()),
        );
      },
    );

    test(
      'an owner of a different household cannot decide this approval',
      () async {
        final otherHousehold = await Household.db.insertRow(
          session,
          Household(name: 'Other Household', createdAt: DateTime.now().toUtc()),
        );
        const otherOwnerAuthUserId = '44444444-4444-4444-4444-444444444444';
        await Member.db.insertRow(
          session,
          Member(
            householdId: otherHousehold.id!,
            displayName: 'Other Owner',
            role: MemberRole.owner,
            status: MemberStatus.active,
            authUserId: otherOwnerAuthUserId,
          ),
        );

        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            otherOwnerAuthUserId,
            {},
          ),
        );

        await expectLater(
          endpoints.approval.decide(authSession, approval.id!, true),
          throwsA(isA<NotHouseholdOwnerException>()),
        );
      },
    );

    test('an unauthenticated caller cannot list pending approvals', () async {
      await expectLater(
        endpoints.approval.listPending(sessionBuilder, household.id!),
        throwsA(anything),
      );
    });
  });
}
