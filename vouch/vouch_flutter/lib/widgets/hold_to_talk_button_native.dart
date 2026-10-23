import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Non-web fallback: browser `MediaRecorder` has no equivalent here, so the
/// button is simply hidden (see `hold_to_talk_button.dart`'s doc comment).
Widget buildHoldToTalkButton(
  BuildContext context, {
  required Future<void> Function(Uint8List audioBytes, String mimeType) onRecorded,
  required bool enabled,
}) {
  return const SizedBox.shrink();
}
