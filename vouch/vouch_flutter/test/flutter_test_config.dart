import 'dart:async';

import 'package:vouch_flutter/design/design.dart';

/// Global widget-test setup: no network font fetches, and no looping
/// ambient motion (so `pumpAndSettle` can settle).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  VType.useGoogleFonts = false;
  VMotion.ambientEnabled = false;
  await testMain();
}
