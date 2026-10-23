import 'dart:convert';

/// Builds the canonical, stable-key-order JSON payload the hub signs and
/// the server verifies against for an enrolment report. Mirrors
/// `AttestationSignature.canonicalPayload`'s approach (fixed field order,
/// not Map insertion order) so both sides always produce identical bytes.
/// Signature verification itself is payload-agnostic, so this reuses
/// `AttestationSignature.verify` directly rather than duplicating it.
class EnrolmentSignature {
  const EnrolmentSignature._();

  static String canonicalPayload({
    required int hubId,
    required int memberId,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime capturedAt,
  }) {
    final buffer = StringBuffer('{');
    buffer.write('"hubId":$hubId,');
    buffer.write('"memberId":$memberId,');
    buffer.write('"embeddingRef":${jsonEncode(embeddingRef)},');
    buffer.write('"qualityScore":$qualityScore,');
    buffer.write('"sampleCount":$sampleCount,');
    buffer.write(
      '"capturedAt":${jsonEncode(capturedAt.toUtc().toIso8601String())}',
    );
    buffer.write('}');
    return buffer.toString();
  }
}
