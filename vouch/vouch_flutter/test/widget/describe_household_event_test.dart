import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/screens/home_screen.dart';

void main() {
  test('an owner decision reads as the owner deciding, not being denied', () {
    final e = HouseholdEvent(
      householdId: 1,
      kind: HouseholdEventKind.approvalDecided,
      memberId: 1,
      action: 'place_order',
      decision: AuditDecision.denied,
      reason: 'denied by owner (approval 32)',
      at: DateTime.now(),
    );
    expect(
      describeHouseholdEvent(e, {1: 'Priya'}),
      'Priya decided a request to place an order: denied by owner',
    );
  });

  test('a rule naming a member is not described as that member acting', () {
    final e = HouseholdEvent(
      householdId: 1,
      kind: HouseholdEventKind.decision,
      memberId: 2,
      action: 'place_order',
      decision: AuditDecision.permitted,
      reason: 'Rule compiled from "Ana can\'t buy anything over 10 euros"',
      at: DateTime.now(),
      eventType: 'policy.rule_created',
    );
    final text = describeHouseholdEvent(e, {2: 'Ana'});
    expect(text, 'New rule for Ana: place an order');
    expect(text, isNot(contains('was allowed')));
  });

  HouseholdEvent ev(AuditDecision d, String reason, {int? member = 2}) =>
      HouseholdEvent(
        householdId: 1,
        kind: HouseholdEventKind.decision,
        memberId: member,
        action: 'place_order',
        decision: d,
        reason: reason,
        at: DateTime.now(),
      );
  final names = {2: 'Ana'};

  test('limit denial reads plainly', () {
    expect(
      describeHouseholdEvent(
        ev(AuditDecision.denied, 'Denied: exceeds household limit of EUR 10'),
        names,
      ),
      "Ana couldn't place an order: over the household limit of EUR 10",
    );
  });

  test('rule denial keeps the rule text, drops the boilerplate', () {
    expect(
      describeHouseholdEvent(
        ev(
          AuditDecision.denied,
          'Denied by policy rule for "place_order" (Children may not order)',
        ),
        names,
      ),
      "Ana couldn't place an order: Children may not order",
    );
    expect(
      describeHouseholdEvent(
        ev(AuditDecision.denied, 'Denied by policy rule for "place_order"'),
        names,
      ),
      "Ana couldn't place an order: a household rule says no",
    );
  });

  test('revoked, challenged, permitted, unrecognised', () {
    expect(
      describeHouseholdEvent(ev(AuditDecision.revoked, 'x'), names),
      "Ana couldn't place an order: voice trust is revoked",
    );
    expect(
      describeHouseholdEvent(ev(AuditDecision.challenged, 'x'), names),
      'Ana needs approval to place an order',
    );
    expect(
      describeHouseholdEvent(ev(AuditDecision.permitted, 'x'), names),
      'Ana was allowed to place an order',
    );
    expect(
      describeHouseholdEvent(
        ev(AuditDecision.denied, 'speaker not recognised', member: null),
        names,
      ),
      "An unrecognised speaker couldn't place an order",
    );
  });
}
