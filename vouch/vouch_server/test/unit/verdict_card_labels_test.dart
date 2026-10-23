import 'package:test/test.dart';
import 'package:vouch_server/src/mcp/verdict_card.dart';

void main() {
  test('verdict card shows plain tier labels and hides approval ids', () {
    final html = buildVerdictCardHtml(null);
    expect(html, contains("return 'Owner approves';"));
    // The Dart string must deliver real regex escapes to the browser.
    expect(html, contains(r"replace(/\s*\(approval \d+\)/g, '')"));
  });
}
