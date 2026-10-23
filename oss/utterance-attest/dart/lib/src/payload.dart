import 'dart:convert';

/// Canonical JSON payload construction.
///
/// Field order and formatting are fixed by `SPEC.md` (not derived from a
/// Map's insertion order) so both the Dart and Python implementations
/// always produce byte-identical bytes to sign and verify.
class Payload {
  const Payload._();

  /// Builds the canonical, stable-key-order JSON payload that gets signed
  /// and verified: `{hubId, memberId, tier, confidence, spoofRisk,
  /// transcriptHash, capturedAt}`. See `SPEC.md` for the exact byte layout.
  static String canonicalPayload({
    required int hubId,
    required int? memberId,
    required String tier,
    required double confidence,
    required String spoofRisk,
    required String transcriptHash,
    required DateTime capturedAt,
  }) {
    final buffer = StringBuffer('{');
    buffer.write('"hubId":$hubId,');
    buffer.write('"memberId":${memberId ?? 'null'},');
    buffer.write('"tier":${jsonEncode(tier)},');
    buffer.write('"confidence":$confidence,');
    buffer.write('"spoofRisk":${jsonEncode(spoofRisk)},');
    buffer.write('"transcriptHash":${jsonEncode(transcriptHash)},');
    buffer.write(
      '"capturedAt":${jsonEncode(capturedAt.toUtc().toIso8601String())}',
    );
    buffer.write('}');
    return buffer.toString();
  }
}
