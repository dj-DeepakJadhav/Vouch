import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'hold_to_talk_button_native.dart'
    if (dart.library.html) 'hold_to_talk_button_web.dart' as impl;

/// A "Hold to talk" button (task F3): press and hold to record from the
/// browser mic (`package:web`'s `MediaRecorder`), release to stop and hand
/// the recorded bytes to [onRecorded] (a POST to the local hub's
/// `/utterance`, see `data/hub/hub_client.dart`).
///
/// Web-only feature: on any other platform this renders nothing
/// (`hold_to_talk_button_native.dart`'s `SizedBox.shrink()`) since browser
/// `MediaRecorder` has no equivalent here.
class HoldToTalkButton extends StatelessWidget {
  const HoldToTalkButton({super.key, required this.onRecorded, required this.enabled});

  /// Called once recording stops with the recorded audio bytes and its
  /// MIME type (`audio/webm;codecs=opus` on virtually all browsers). Any
  /// error it throws is caught and shown inline as the button's error state.
  final Future<void> Function(Uint8List audioBytes, String mimeType) onRecorded;

  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      impl.buildHoldToTalkButton(context, onRecorded: onRecorded, enabled: enabled);
}
