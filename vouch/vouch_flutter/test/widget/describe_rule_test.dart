import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/screens/rules_screen.dart';

final _members = [
  Member(
    id: 7,
    householdId: 1,
    displayName: 'Ana',
    role: MemberRole.child,
    status: MemberStatus.active,
  ),
];

String _d({
  int? memberId,
  MemberRole? role,
  required String action,
  PolicyEffect effect = PolicyEffect.require,
  TrustTier tier = TrustTier.t2,
  String? args,
}) => describeRule(
  memberId: memberId,
  role: role,
  actionPattern: action,
  effect: effect,
  requiredTier: tier,
  argConditionsJson: args,
  members: _members,
);

void main() {
  test('spending limit states what is blocked and what needs approval', () {
    expect(
      _d(
        memberId: 7,
        action: 'place_order',
        args: '{"maxAmount":10,"currency":"EUR"}',
      ),
      'Ana: orders over EUR 10 are blocked; orders up to EUR 10 need your '
      'approval each time.',
    );
  });

  test('glob action has no dangling space or dash', () {
    final s = _d(action: 'unlock_*');
    expect(s, 'Everyone: unlocking doors needs your approval each time.');
    expect(s.contains('  '), isFalse);
    expect(s.contains('—'), isFalse);
  });

  test('deny reads as always blocked', () {
    expect(
      _d(role: MemberRole.guest, action: 'unlock_*', effect: PolicyEffect.deny),
      'Guests: unlocking doors is always blocked.',
    );
  });

  test('t0 never says "T0 approval"', () {
    final s = _d(action: 'get_weather', tier: TrustTier.t0);
    expect(s, 'Everyone: weather questions are allowed for anyone.');
    expect(s.toLowerCase().contains('t0'), isFalse);
  });

  test('unknown glob falls back to words without stray spaces', () {
    expect(describeAction('foo_bar_*'), 'anything starting "foo bar"');
  });
}
