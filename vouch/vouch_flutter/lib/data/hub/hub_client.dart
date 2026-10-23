import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Result of `POST /utterance` against the local hub server
/// (`vouch_hub serve`, `hub/vouch_hub/httpserver.py`): the same fields the
/// hub returns as JSON.
class HubUtteranceResult {
  const HubUtteranceResult({
    required this.transcript,
    required this.speaker,
    required this.confidence,
    required this.attestationId,
    required this.spoofRisk,
    this.status,
  });

  factory HubUtteranceResult.fromJson(Map<String, dynamic> json) {
    return HubUtteranceResult(
      transcript: json['transcript'] as String?,
      speaker: json['speaker'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      attestationId: json['attestationId'] as int?,
      spoofRisk: json['spoofRisk'] as String?,
      status: json['status'] as String?,
    );
  }

  final String? transcript;
  final String? speaker;
  final double? confidence;
  final int? attestationId;
  final String? spoofRisk;

  /// Set when the hub couldn't identify speech (`no_speech` /
  /// `unrecognised`) — see `httpserver.py`'s response building.
  final String? status;
}

/// Thrown when the hub is unreachable (connection refused/timeout) or
/// answers with something other than 200.
class HubUnreachableException implements Exception {
  HubUnreachableException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Talks to the local `vouch_hub serve` process (127.0.0.1:8765 only —
/// voiceprints never leave the hub; this client only ever exchanges recorded
/// audio bytes and the JSON result).
abstract class HubClient {
  /// True if `GET /health` answers `{"ok": true}` within [timeout].
  Future<bool> checkHealth();

  /// Uploads recorded audio (`audio/webm;codecs=opus` or `audio/wav`) and
  /// returns the hub's attestation result.
  Future<HubUtteranceResult> sendUtterance(
    Uint8List audioBytes,
    String contentType,
  );
}

class HttpHubClient implements HubClient {
  HttpHubClient({this.baseUrl = 'http://127.0.0.1:8765', http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<bool> checkHealth() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode != 200) return false;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<HubUtteranceResult> sendUtterance(
    Uint8List audioBytes,
    String contentType,
  ) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/utterance'),
            headers: {'Content-Type': contentType},
            body: audioBytes,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw HubUnreachableException(
        'Could not reach the hub at $baseUrl. Start it with: '
        'cd hub && .venv/bin/python -m vouch_hub serve',
      );
    }
    if (res.statusCode != 200) {
      String detail = res.body;
      try {
        detail =
            (jsonDecode(res.body) as Map<String, dynamic>)['error']
                as String? ??
            res.body;
      } catch (_) {}
      throw HubUnreachableException('Hub returned ${res.statusCode}: $detail');
    }
    return HubUtteranceResult.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }
}
