import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with an owner and a child', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member child;
    const ownerAuthUserId = '77777777-7777-7777-7777-777777777777';
    const childAuthUserId = '88888888-8888-8888-8888-888888888888';

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(
          name: 'Rules Endpoint Test',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: ownerAuthUserId,
        ),
      );
      child = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Child',
          role: MemberRole.child,
          status: MemberStatus.active,
          authUserId: childAuthUserId,
        ),
      );
    });

    ownerSession() => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        ownerAuthUserId,
        {},
      ),
    );

    test(
      'when the owner confirms a well-formed proposal then it is saved and listed',
      () async {
        final proposal = RuleProposal(
          actionPattern: 'place_order',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.deny,
          memberId: child.id,
          explanation: 'the child may never place an order',
        );

        final saved = await endpoints.rules.confirm(
          ownerSession(),
          household.id!,
          [proposal],
          "the kid can't buy anything",
        );

        expect(saved, hasLength(1));
        expect(saved.single.sourceText, "the kid can't buy anything");

        final listed = await endpoints.rules.list(
          ownerSession(),
          household.id!,
        );
        expect(listed.any((r) => r.id == saved.single.id), isTrue);
      },
    );

    test(
      'when confirm is called with an invalid proposal then nothing is saved',
      () async {
        final invalid = RuleProposal(
          actionPattern: 'wire_all_the_money',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.deny,
          explanation: 'not a real tool',
        );

        await expectLater(
          endpoints.rules.confirm(
            ownerSession(),
            household.id!,
            [invalid],
            'nonsense rule',
          ),
          throwsA(anything),
        );

        final listed = await endpoints.rules.list(
          ownerSession(),
          household.id!,
        );
        expect(listed.where((r) => r.sourceText == 'nonsense rule'), isEmpty);
      },
    );

    test('when a non-owner calls list then it is rejected', () async {
      final childSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          childAuthUserId,
          {},
        ),
      );
      await expectLater(
        endpoints.rules.list(childSession, household.id!),
        throwsA(isA<NotHouseholdOwnerException>()),
      );
    });

    test(
      'when the owner disables a rule then it is enabled=false, not deleted',
      () async {
        final proposal = RuleProposal(
          actionPattern: 'get_weather',
          requiredTier: TrustTier.t0,
          explanation: 'household-wide default',
        );
        final saved = await endpoints.rules.confirm(
          ownerSession(),
          household.id!,
          [proposal],
          'weather is fine for anyone',
        );

        final disabled = await endpoints.rules.disable(
          ownerSession(),
          saved.single.id!,
        );

        expect(disabled, isNotNull);
        expect(disabled!.enabled, isFalse);

        final stillListed = await endpoints.rules.list(
          ownerSession(),
          household.id!,
        );
        expect(stillListed.any((r) => r.id == saved.single.id), isTrue);
      },
    );

    test('when a non-owner calls classifyTool then it is rejected', () async {
      final childSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          childAuthUserId,
          {},
        ),
      );
      await expectLater(
        endpoints.rules.classifyTool(
          childSession,
          household.id!,
          'some_new_tool',
          'does something',
          '{"type":"object"}',
        ),
        throwsA(isA<NotHouseholdOwnerException>()),
      );
    });

    test(
      'when the owner calls classifyTool with no nebiusApiKey configured '
      'then it throws (test run mode has no key by design)',
      () async {
        await expectLater(
          endpoints.rules.classifyTool(
            ownerSession(),
            household.id!,
            'some_new_tool',
            'does something',
            '{"type":"object"}',
          ),
          throwsA(anything),
        );
      },
    );
  });
}
