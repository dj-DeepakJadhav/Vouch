import 'package:test/test.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/policy/policy_engine.dart';

PolicyRule _rule({
  int id = 1,
  int? memberId,
  MemberRole? role,
  String actionPattern = 'place_order',
  TrustTier requiredTier = TrustTier.t2,
  PolicyEffect effect = PolicyEffect.require,
  String? argConditions,
  String? sourceText,
  bool enabled = true,
}) {
  return PolicyRule(
    id: id,
    householdId: 1,
    memberId: memberId,
    role: role,
    actionPattern: actionPattern,
    requiredTier: requiredTier,
    effect: effect,
    sourceText: sourceText,
    argConditions: argConditions,
    enabled: enabled,
  );
}

Member _member({int id = 1, MemberRole role = MemberRole.adult}) {
  return Member(
    id: id,
    householdId: 1,
    displayName: 'Test Member',
    role: role,
    status: MemberStatus.active,
  );
}

void main() {
  group('Given no matching policy rule', () {
    test('when a T0 default action is requested by an unrecognised speaker '
        'then it is allowed', () {
      final decision = PolicyEngine.decide(
        rules: const [],
        speaker: null,
        speakerRole: null,
        action: 'get_weather',
        args: const {},
        attestedTier: TrustTier.t0,
      );

      expect(decision.effect, PolicyDecisionEffect.allow);
      expect(decision.requiredTier, TrustTier.t0);
    });

    test('when an unrecognised action is requested then it defaults to T2 '
        'and requires step-up', () {
      final decision = PolicyEngine.decide(
        rules: const [],
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'do_something_never_configured',
        args: const {},
        attestedTier: TrustTier.t2,
      );

      expect(decision.requiredTier, TrustTier.t2);
      expect(decision.effect, PolicyDecisionEffect.stepUp);
    });

    test('when an unrecognised speaker requests a T1 default action then it '
        'is denied with "speaker not recognised"', () {
      final decision = PolicyEngine.decide(
        rules: const [],
        speaker: null,
        speakerRole: null,
        action: 'add_to_list',
        args: const {},
        attestedTier: TrustTier.t0,
      );

      expect(decision.effect, PolicyDecisionEffect.deny);
      expect(decision.reason, 'speaker not recognised');
    });
  });

  group('Given a role-level rule', () {
    test('when a child requests a purchase action then it is denied', () {
      final rules = [
        _rule(
          id: 10,
          role: MemberRole.child,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.deny,
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(id: 2, role: MemberRole.child),
        speakerRole: MemberRole.child,
        action: 'place_order',
        args: const {},
        attestedTier: TrustTier.t2,
      );

      expect(decision.effect, PolicyDecisionEffect.deny);
      expect(decision.matchedRuleId, 10);
    });
  });

  group('Given both a member-specific and a role-level rule match', () {
    test('when deciding then the member-specific rule wins', () {
      final rules = [
        _rule(
          id: 20,
          role: MemberRole.adult,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.require,
        ),
        _rule(
          id: 21,
          memberId: 5,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(id: 5, role: MemberRole.adult),
        speakerRole: MemberRole.adult,
        action: 'place_order',
        args: const {},
        attestedTier: TrustTier.t1,
      );

      expect(decision.matchedRuleId, 21);
      expect(decision.requiredTier, TrustTier.t1);
      expect(decision.effect, PolicyDecisionEffect.allow);
    });
  });

  group('Given two rules at the same specificity with different effects', () {
    test('when one denies and one requires then deny wins', () {
      final rules = [
        _rule(
          id: 30,
          role: MemberRole.adult,
          actionPattern: 'place_*',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
        ),
        _rule(
          id: 31,
          role: MemberRole.adult,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.deny,
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(role: MemberRole.adult),
        speakerRole: MemberRole.adult,
        action: 'place_order',
        args: const {},
        attestedTier: TrustTier.t2,
      );

      expect(decision.effect, PolicyDecisionEffect.deny);
      expect(decision.matchedRuleId, 31);
    });
  });

  group('Given a rule with an argConditions maxAmount', () {
    test('when the requested amount exceeds it then it is denied with a '
        'limit reason', () {
      final rules = [
        _rule(
          id: 40,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
          argConditions: '{"maxAmount":10,"currency":"EUR"}',
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'place_order',
        args: const {'amount': 25},
        attestedTier: TrustTier.t2,
      );

      expect(decision.effect, PolicyDecisionEffect.deny);
      expect(decision.reason, contains('exceeds household limit of'));
      expect(decision.reason, contains('EUR 10'));
    });

    test('when the requested amount is within it then it is allowed', () {
      final rules = [
        _rule(
          id: 41,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t0,
          effect: PolicyEffect.require,
          argConditions: '{"maxAmount":10,"currency":"EUR"}',
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'place_order',
        args: const {'amount': 5},
        attestedTier: TrustTier.t0,
      );

      expect(decision.effect, PolicyDecisionEffect.allow);
    });
  });

  group('Given a glob action pattern', () {
    test('when the requested action matches the prefix then the rule '
        'applies', () {
      final rules = [
        _rule(
          id: 50,
          actionPattern: 'place_*',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'place_order',
        args: const {},
        attestedTier: TrustTier.t1,
      );

      expect(decision.matchedRuleId, 50);
      expect(decision.effect, PolicyDecisionEffect.allow);
    });

    test('when the requested action does not match the prefix then it '
        'falls through to defaults', () {
      final rules = [
        _rule(
          id: 51,
          actionPattern: 'place_*',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
        ),
      ];

      final decision = PolicyEngine.decide(
        rules: rules,
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'get_weather',
        args: const {},
        attestedTier: TrustTier.t0,
      );

      expect(decision.matchedRuleId, isNull);
      expect(decision.requiredTier, TrustTier.t0);
      expect(decision.effect, PolicyDecisionEffect.allow);
    });
  });

  group('Given a T2 action with a satisfying attested tier', () {
    test('when deciding then step-up is still required', () {
      final decision = PolicyEngine.decide(
        rules: const [],
        speaker: _member(),
        speakerRole: MemberRole.adult,
        action: 'send_message',
        args: const {},
        attestedTier: TrustTier.t2,
      );

      expect(decision.effect, PolicyDecisionEffect.stepUp);
    });
  });

  group('Given the demo seed (child-role deny on place_*)', () {
    final ana = _member(id: 7, role: MemberRole.child);
    final seedDeny = _rule(
      id: 1,
      role: MemberRole.child,
      actionPattern: 'place_*',
      effect: PolicyEffect.deny,
    );
    final anaLimit = _rule(
      id: 2,
      memberId: 7,
      actionPattern: 'place_order',
      argConditions: '{"maxAmount":10,"currency":"EUR"}',
    );

    PolicyDecision order(List<PolicyRule> rules, num amount) =>
        PolicyEngine.decide(
          rules: rules,
          speaker: ana,
          speakerRole: MemberRole.child,
          action: 'place_order',
          args: {'amount': amount, 'currency': 'EUR'},
          attestedTier: TrustTier.t1,
        );

    test('without a named rule every order by the child is denied', () {
      expect(order([seedDeny], 5).effect, PolicyDecisionEffect.deny);
    });

    test('"Ana can\'t buy anything over 10 euros" refines it: '
        'over 10 denied by the limit, not by the seed', () {
      final d = order([seedDeny, anaLimit], 50);
      expect(d.effect, PolicyDecisionEffect.deny);
      expect(d.matchedRuleId, 2);
      expect(d.reason, contains('EUR 10'));
    });

    test('an order at or under the limit goes to the owner', () {
      final d = order([seedDeny, anaLimit], 10);
      expect(d.effect, PolicyDecisionEffect.stepUp);
      expect(d.matchedRuleId, 2);
    });
  });
}
