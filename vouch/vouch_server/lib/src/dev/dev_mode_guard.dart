import 'package:serverpod/serverpod.dart';

/// Guard shared by every `DevEndpoint` method: throws unless the server is
/// running in development (or test) mode. Extracted to a standalone,
/// runMode-parameterized function — rather than inlined per-method — so it
/// can be tested directly against `ServerpodRunMode.production` without
/// needing to boot a server in that mode (`withServerpod`/`serverpod_test`
/// cannot override `runMode` to `production`; see
/// `test/unit/dev_mode_guard_test.dart`).
class DevModeGuard {
  const DevModeGuard._();

  /// Throws an [Exception] unless [runMode] is `development` or `test`
  /// (one of the [ServerpodRunMode] string constants). `test` is included
  /// alongside `development` so `DevEndpoint`'s own test suite (and any
  /// integration test that seeds a household) can exercise it —
  /// `serverpod_test` runs with `ServerpodRunMode.test` by default, not
  /// `development`. Both modes run against an ephemeral/local database,
  /// never a real deployment.
  static void check(String runMode) {
    if (runMode != ServerpodRunMode.development &&
        runMode != ServerpodRunMode.test) {
      throw Exception(
        'DevEndpoint is only available when the server is running in '
        'development mode.',
      );
    }
  }
}
