import 'package:test/test.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/policy/rule_compiler.dart';

void main() {
  const ownerId = 1;
  const childId = 2;
  const otherHouseholdChildId = 999;

  final members = const [
    HouseholdMemberRef(
      id: ownerId,
      displayName: 'Owner',
      role: MemberRole.owner,
    ),
    HouseholdMemberRef(
      id: childId,
      displayName: 'Child',
      role: MemberRole.child,
    ),
  ];

  group('Given a well-formed proposal', () {
    test('when it names a known tool and valid fields then it validates', () {
      final proposal = RuleCompiler.validate(
        {
          'actionPattern': 'place_order',
          'requiredTier': 't2',
          'effect': 'deny',
          'memberId': childId,
          'argConditions': {'maxAmount': 10, 'currency': 'EUR'},
          'explanation': 'Ana cannot spend over 10 euros.',
        },
        members: members,
      );

      expect(proposal.actionPattern, 'place_order');
      expect(proposal.requiredTier, TrustTier.t2);
      expect(proposal.effect, PolicyEffect.deny);
      expect(proposal.memberId, childId);
      expect(proposal.argConditions, contains('"maxAmount":10'));
    });

    test('when actionPattern is a glob over known tools then it validates', () {
      final proposal = RuleCompiler.validate(
        {
          'actionPattern': 'unlock_*',
          'requiredTier': 't2',
          'effect': 'deny',
          'role': 'guest',
          'explanation': 'Guests can never unlock doors.',
        },
        members: members,
      );
      expect(proposal.actionPattern, 'unlock_*');
      expect(proposal.role, MemberRole.guest);
    });

    test('when neither memberId nor role is set then it is household-wide', () {
      final proposal = RuleCompiler.validate(
        {
          'actionPattern': 'get_weather',
          'requiredTier': 't0',
          'explanation': 'Anyone can ask for the weather.',
        },
        members: members,
      );
      expect(proposal.memberId, isNull);
      expect(proposal.role, isNull);
      // effect defaults to require when omitted.
      expect(proposal.effect, PolicyEffect.require);
    });
  });

  group('Given a malicious or malformed proposal', () {
    test(
      'when memberId belongs to a different household then it is rejected',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'place_order',
              'requiredTier': 't2',
              'effect': 'deny',
              'memberId': otherHouseholdChildId,
              'explanation': 'not this household',
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'member_not_in_household',
            ),
          ),
        );
      },
    );

    test('when actionPattern names an unknown tool then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'wire_transfer_all_savings',
            'requiredTier': 't0',
            'explanation': 'not a real tool',
          },
          members: members,
        ),
        throwsA(
          isA<RuleValidationException>().having(
            (e) => e.reason,
            'reason',
            'unknown_action_pattern',
          ),
        ),
      );
    });

    test(
      'when actionPattern is a glob matching no known tool then it is rejected',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'delete_*',
              'requiredTier': 't0',
              'explanation': 'no tool starts with delete_',
            },
            members: members,
          ),
          throwsA(isA<RuleValidationException>()),
        );
      },
    );

    test('when requiredTier is "t9" then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'place_order',
            'requiredTier': 't9',
            'explanation': 'bogus tier',
          },
          members: members,
        ),
        throwsA(
          isA<RuleValidationException>().having(
            (e) => e.reason,
            'reason',
            'invalid_tier',
          ),
        ),
      );
    });

    test('when argConditions.maxAmount is negative then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'place_order',
            'requiredTier': 't2',
            'argConditions': {'maxAmount': -5},
            'explanation': 'negative limit',
          },
          members: members,
        ),
        throwsA(
          isA<RuleValidationException>().having(
            (e) => e.reason,
            'reason',
            'invalid_max_amount',
          ),
        ),
      );
    });

    test(
      'when the proposal has an unknown top-level field then it is rejected',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'place_order',
              'requiredTier': 't2',
              'explanation': 'has an extra field',
              'bypassApproval': true,
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'unknown_field',
            ),
          ),
        );
      },
    );

    test('when argConditions has an unknown field then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'place_order',
            'requiredTier': 't2',
            'argConditions': {'maxAmount': 10, 'approvedBy': 'nobody'},
            'explanation': 'sneaky extra arg condition',
          },
          members: members,
        ),
        throwsA(isA<RuleValidationException>()),
      );
    });

    test('when role is not a known MemberRole then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'get_weather',
            'requiredTier': 't0',
            'role': 'superadmin',
            'explanation': 'not a real role',
          },
          members: members,
        ),
        throwsA(
          isA<RuleValidationException>().having(
            (e) => e.reason,
            'reason',
            'invalid_role',
          ),
        ),
      );
    });

    test('when effect is not require/deny then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {
            'actionPattern': 'get_weather',
            'requiredTier': 't0',
            'effect': 'ignore',
            'explanation': 'not a real effect',
          },
          members: members,
        ),
        throwsA(isA<RuleValidationException>()),
      );
    });

    test(
      'when both memberId and role are set then it is rejected as ambiguous',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'get_weather',
              'requiredTier': 't0',
              'memberId': childId,
              'role': 'child',
              'explanation': 'both scopes set',
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'ambiguous_scope',
            ),
          ),
        );
      },
    );

    test('when explanation is missing then it is rejected', () {
      expect(
        () => RuleCompiler.validate(
          {'actionPattern': 'get_weather', 'requiredTier': 't0'},
          members: members,
        ),
        throwsA(isA<RuleValidationException>()),
      );
    });
  });

  group('Given a proposal weaker than the household default', () {
    test(
      'when a "require" rule sets t0 for place_order (default t2) then it '
      'is rejected as tier_below_default',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'place_order',
              'requiredTier': 't0',
              'effect': 'require',
              'memberId': childId,
              'argConditions': {'maxAmount': 10, 'currency': 'EUR'},
              'explanation': 'Ana can spend up to 10 euros with no checks',
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'tier_below_default',
            ),
          ),
        );
      },
    );

    test(
      'when a "require" rule sets t1 for send_message (default t2) then it '
      'is rejected as tier_below_default',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'send_message',
              'requiredTier': 't1',
              'explanation': 'messages just need a voice match',
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'tier_below_default',
            ),
          ),
        );
      },
    );

    test(
      'when a glob "require" rule sets t1 for unlock_* (default t2) then it '
      'is rejected as tier_below_default',
      () {
        expect(
          () => RuleCompiler.validate(
            {
              'actionPattern': 'unlock_*',
              'requiredTier': 't1',
              'explanation': 'a voice match should be enough to unlock',
            },
            members: members,
          ),
          throwsA(
            isA<RuleValidationException>().having(
              (e) => e.reason,
              'reason',
              'tier_below_default',
            ),
          ),
        );
      },
    );

    test(
      'when requiredTier equals the default exactly then it is accepted',
      () {
        final proposal = RuleCompiler.validate(
          {
            'actionPattern': 'place_order',
            'requiredTier': 't2',
            'argConditions': {'maxAmount': 10, 'currency': 'EUR'},
            'explanation': 'still needs step-up, just also capped at 10 EUR',
          },
          members: members,
        );
        expect(proposal.requiredTier, TrustTier.t2);
      },
    );

    test('when effect is "deny" then a below-default tier is exempt', () {
      final proposal = RuleCompiler.validate(
        {
          'actionPattern': 'place_order',
          'requiredTier': 't0',
          'effect': 'deny',
          'memberId': childId,
          'explanation': 'Ana can never buy anything, tier is moot',
        },
        members: members,
      );
      expect(proposal.effect, PolicyEffect.deny);
    });
  });
}
