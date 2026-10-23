import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_flutter/data/mcp/mcp_tool_catalog.dart';

void main() {
  test('order args come from the sentence, not the canned default', () {
    final a = argsFromUtterance(
      'place_order',
      'Order the new PlayStation for 500 euros',
    );
    expect(a['item'], 'new PlayStation');
    expect(a['amount'], 500.0);
    expect(a['currency'], 'EUR');
  });

  test('list item comes from the sentence', () {
    expect(
      argsFromUtterance(
        'add_to_list',
        'Put chocolate on the shopping list',
      )['item'],
      'chocolate',
    );
    expect(
      argsFromUtterance('add_to_list', 'Add milk to the list')['item'],
      'milk',
    );
  });

  test('falls back to defaults when nothing is stated', () {
    expect(
      argsFromUtterance('add_to_list', 'add something'),
      defaultArgsFor('add_to_list'),
    );
    expect(
      argsFromUtterance('unlock_front_door', 'Unlock the front door'),
      isEmpty,
    );
  });

  group('ambiguous amounts keep the canned default', () {
    final fallback = defaultArgsFor('place_order')['amount'];
    for (final u in [
      'order two things for 5 and 10 euros',
      'order a gift for 5 euros or 10 euros',
      'buy headphones for 5-10 euros',
      'order the headphones',
    ]) {
      test(u, () {
        expect(argsFromUtterance('place_order', u)['amount'], fallback);
      });
    }
  });

  test('one stated amount is used even with other numbers around', () {
    expect(
      argsFromUtterance(
        'place_order',
        'order 2 headphones for 50 euros',
      )['amount'],
      50.0,
    );
    expect(unambiguousEuroAmount('buy it for €12,50'), 12.5);
    expect(unambiguousEuroAmount('buy it for 12 EUR'), 12.0);
  });
}
