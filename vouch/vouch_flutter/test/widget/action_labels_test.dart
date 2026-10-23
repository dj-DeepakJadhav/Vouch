import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/app/theme.dart';
import 'package:vouch_flutter/screens/activity_screen.dart';

void main() {
  test('humanAction maps known tools and falls back to plain words', () {
    expect(humanAction('unlock_front_door'), 'unlock the front door');
    expect(humanAction('place_order'), 'place an order');
    expect(humanAction('add_to_list'), 'add to the shopping list');
    expect(humanAction('get_weather'), 'check the weather');
    expect(humanAction('play_music'), 'play music');
    expect(humanAction('read_calendar'), 'read the calendar');
    expect(humanAction('send_message'), 'send a message');
    expect(humanAction('turn_on_lights'), 'turn on lights');
  });

  test('householdDisplayName drops only a trailing dev seed marker', () {
    expect(householdDisplayName('Priya household (dev seed)'), 'Priya household');
    expect(householdDisplayName('Priya household'), 'Priya household');
  });

  test('tiers read as plain words, not T0/T1/T2', () {
    expect(tierLabel(TrustTier.t0), 'Anyone');
    expect(tierLabel(null), 'Anyone');
    expect(tierLabel(TrustTier.t1), 'Known voice');
    expect(tierLabel(TrustTier.t2), 'Owner approves');
    for (final t in TrustTier.values) {
      expect(tierMeaning(t), isNot(contains('T0')));
      expect(tierMeaning(t), contains(tierLabel(t)));
    }
  });

  test('audit events read as sentences with the actor name', () {
    AuditEvent ev(String type, String action, AuditDecision d, {int? m = 1}) =>
        AuditEvent(
          householdId: 1,
          memberId: m,
          eventType: type,
          action: action,
          decision: d,
          reason: 'x',
          createdAt: DateTime.now(),
        );
    const names = {1: 'Ana'};
    expect(
      describeAuditEvent(
        ev('attestation.submit', 'issue_attestation', AuditDecision.permitted),
        names,
      ),
      "Hub confirmed Ana's voice for one command",
    );
    expect(
      describeAuditEvent(
        ev('mcp.tool_call', 'add_to_list', AuditDecision.permitted),
        names,
      ),
      'Ana was allowed to add to the shopping list',
    );
    expect(
      describeAuditEvent(
        ev('mcp.tool_call', 'unlock_front_door', AuditDecision.denied, m: null),
        names,
      ),
      'Someone was blocked from trying to unlock the front door',
    );
  });
}
