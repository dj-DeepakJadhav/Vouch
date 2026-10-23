import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_flutter/app/router.dart';

void main() {
  test('a deep link to a tab survives a reload', () {
    expect(initialShellLocation(deepLink: '/rules', demo: false), '/rules');
    expect(
      initialShellLocation(deepLink: '/approvals', demo: true),
      '/approvals',
    );
  });

  test('root or unknown paths fall back to the default tab', () {
    expect(initialShellLocation(deepLink: '/', demo: false), '/home');
    expect(initialShellLocation(deepLink: '/', demo: true), '/alexa');
    expect(initialShellLocation(deepLink: '/nope', demo: false), '/home');
    expect(initialShellLocation(deepLink: null, demo: false), '/home');
  });
}
