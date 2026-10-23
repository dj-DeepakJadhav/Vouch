import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:vouch_server/src/dev/dev_mode_guard.dart';

// `withServerpod`/`serverpod_test` always boots the server with
// `ServerpodRunMode.test` (or `.development`), so a production run cannot be
// exercised through an integration test. `DevModeGuard.check` is extracted
// as a standalone function of `ServerpodRunMode` specifically so every
// `DevEndpoint` method's guard can be verified against
// `ServerpodRunMode.production` directly, without a running server.
void main() {
  group('Given DevModeGuard.check', () {
    test('when runMode is production then it throws', () {
      expect(
        () => DevModeGuard.check(ServerpodRunMode.production),
        throwsA(isA<Exception>()),
      );
    });

    test('when runMode is staging then it throws', () {
      expect(
        () => DevModeGuard.check(ServerpodRunMode.staging),
        throwsA(isA<Exception>()),
      );
    });

    test('when runMode is development then it does not throw', () {
      expect(
        () => DevModeGuard.check(ServerpodRunMode.development),
        returnsNormally,
      );
    });

    test('when runMode is test then it does not throw', () {
      expect(
        () => DevModeGuard.check(ServerpodRunMode.test),
        returnsNormally,
      );
    });
  });
}
