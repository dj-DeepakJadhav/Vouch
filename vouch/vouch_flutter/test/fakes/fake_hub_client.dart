import 'dart:typed_data';

import 'package:vouch_flutter/data/hub/hub_client.dart';

/// A scripted [HubClient] for widget tests — no real HTTP call.
class FakeHubClient implements HubClient {
  FakeHubClient({
    this.healthy = true,
    this.utteranceResult,
    this.utteranceError,
  });

  /// What `checkHealth()` returns.
  bool healthy;

  /// What `sendUtterance` resolves with when [utteranceError] is null.
  HubUtteranceResult? utteranceResult;

  /// When set, `sendUtterance` throws this instead of returning a result.
  Object? utteranceError;

  int healthChecks = 0;
  final sentAudio = <Uint8List>[];

  @override
  Future<bool> checkHealth() async {
    healthChecks++;
    return healthy;
  }

  @override
  Future<HubUtteranceResult> sendUtterance(
    Uint8List audioBytes,
    String contentType,
  ) async {
    sentAudio.add(audioBytes);
    if (utteranceError != null) throw utteranceError!;
    return utteranceResult ??
        const HubUtteranceResult(
          transcript: null,
          speaker: null,
          confidence: null,
          attestationId: null,
          spoofRisk: null,
          status: 'no_speech',
        );
  }
}
