import 'dart:convert';

import 'attest.dart';
import 'normalise.dart';
import 'payload.dart';

/// Combined evidence checks. Policy and atomic single-use storage remain
/// the caller's responsibility; success is not an authorisation decision.
class Verification {
  const Verification._();

  /// [trustedPublicKeyBase64] must come from an enrolled hub's trusted
  /// record, never from the envelope being verified. Freshness uses only
  /// the timestamp inside the signed payload.
  static Future<bool> verifyForCommand({
    required String payload,
    required String signatureBase64,
    required String trustedPublicKeyBase64,
    required String command,
    required int expectedHubId,
    required int? expectedMemberId,
    required Duration maxAge,
    DateTime? now,
  }) async {
    if (payload.length > 8192 ||
        command.length > 4096 ||
        maxAge.isNegative ||
        expectedHubId < 1 ||
        (expectedMemberId != null && expectedMemberId < 1)) {
      return false;
    }
    try {
      for (final pair in [
        (signatureBase64, 64),
        (trustedPublicKeyBase64, 32)
      ]) {
        if (pair.$1.length > 128) return false;
        final bytes = base64.decode(pair.$1);
        if (bytes.length != pair.$2 || base64.encode(bytes) != pair.$1)
          return false;
      }
      if (!await Attest.verify(
          payload: payload,
          signatureBase64: signatureBase64,
          publicKeyBase64: trustedPublicKeyBase64)) return false;
      final fields = jsonDecode(payload);
      const required = {
        'hubId',
        'memberId',
        'tier',
        'confidence',
        'spoofRisk',
        'transcriptHash',
        'capturedAt'
      };
      if (fields is! Map<String, dynamic> ||
          fields.length != required.length ||
          !required.every(fields.containsKey)) return false;
      if (fields['hubId'] is! int ||
          fields['hubId'] != expectedHubId ||
          (fields['memberId'] != null && fields['memberId'] is! int) ||
          fields['memberId'] != expectedMemberId) return false;
      final confidence = fields['confidence'];
      if (confidence is! num ||
          !confidence.isFinite ||
          confidence < 0 ||
          confidence > 1) return false;
      for (final name in [
        'tier',
        'spoofRisk',
        'transcriptHash',
        'capturedAt'
      ]) {
        if (fields[name] is! String) return false;
      }
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
          .hasMatch(fields['capturedAt'] as String)) return false;
      final captured = DateTime.parse(fields['capturedAt'] as String);
      final canonical = Payload.canonicalPayload(
        hubId: fields['hubId'] as int,
        memberId: fields['memberId'] as int?,
        tier: fields['tier'] as String,
        confidence: confidence.toDouble(),
        spoofRisk: fields['spoofRisk'] as String,
        transcriptHash: fields['transcriptHash'] as String,
        capturedAt: captured,
      );
      if (canonical != payload ||
          !Attest.isFresh(captured, maxAge: maxAge, now: now)) return false;
      final text = Normalise.normalise(command);
      return text.isNotEmpty &&
          Normalise.hash(text) == fields['transcriptHash'];
    } catch (_) {
      return false;
    }
  }
}
