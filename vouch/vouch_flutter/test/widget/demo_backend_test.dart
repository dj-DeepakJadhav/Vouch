import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_flutter/data/repositories/demo_repository.dart';

void main() {
  Future<bool> yes() async => true;
  Future<bool> no() async => false;
  Future<bool> boom() async => throw Exception('no such endpoint');

  group('chooseDemoBackend', () {
    test('hosted demo wins when the server has demoMode on', () async {
      var devProbed = false;
      final b = await chooseDemoBackend(
        hostedAvailable: yes,
        devAvailable: () async {
          devProbed = true;
          return true;
        },
      );
      expect(b, DemoBackend.hosted);
      expect(devProbed, isFalse);
    });

    test('falls back to dev only when demoMode is off', () async {
      expect(
        await chooseDemoBackend(hostedAvailable: no, devAvailable: yes),
        DemoBackend.dev,
      );
    });

    test('an older server without DemoEndpoint still uses dev', () async {
      expect(
        await chooseDemoBackend(hostedAvailable: boom, devAvailable: yes),
        DemoBackend.dev,
      );
    });

    test('neither available (or unreachable) hides the demo', () async {
      expect(
        await chooseDemoBackend(hostedAvailable: no, devAvailable: no),
        DemoBackend.none,
      );
      expect(
        await chooseDemoBackend(hostedAvailable: boom, devAvailable: boom),
        DemoBackend.none,
      );
    });
  });
}
