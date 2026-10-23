import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/app/theme.dart';
import 'package:vouch_flutter/widgets/alexa/verdict_model.dart';
import 'package:vouch_flutter/widgets/verdict_card_view_native.dart';

void main() {
  test('friendlyReason strips internals', () {
    expect(
      friendlyReason(
        'Denied by policy rule for "place_order" (Children may not place orders (demo default))',
      ),
      'Denied by policy rule for place an order (Children may not place orders (demo default))'
          .replaceAll('(demo default))', '(demo default))'),
    );
    expect(
      friendlyReason('step-up approved and executed (approval 45)'),
      'step-up approved and executed',
    );
    expect(friendlyReason('default policy'), 'household default');
  });

  test('buildVerdict and summary use cleaned text', () {
    final v = buildVerdict({
      'decision': 'allow',
      'reason': 'ok (approval 7)',
    }, inFlight: false);
    expect(v.detail, 'ok');
    final rows = buildSummary({'decision': 'denied'});
    expect(rows.last.value, contains('household default'));
  });

  testWidgets('native verdict card shows plain tier label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => buildVerdictCard(
            context,
            html: null,
            vouch: const {'presentTier': 't2', 'decision': 'allow'},
          ),
        ),
      ),
    );
    expect(find.text(tierLabel(TrustTier.t2)), findsOneWidget);
    expect(find.text('t2'), findsNothing);
  });
}
