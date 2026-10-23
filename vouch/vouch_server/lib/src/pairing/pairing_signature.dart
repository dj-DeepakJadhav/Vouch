import 'dart:convert';

/// Builds the canonical, stable-key-order JSON payload the hub signs and
/// the server verifies against for a pairing-code creation request.
/// Mirrors `EnrolmentSignature.canonicalPayload`'s approach (fixed field
/// order, not Map insertion order) so both sides always produce identical
/// bytes. Signature verification itself is payload-agnostic, so this
/// reuses `AttestationSignature.verify` directly rather than duplicating
/// it (see `PairingEndpoint.createCode`).
class PairingSignature {
  const PairingSignature._();

  static String canonicalPayload({
    required int hubId,
    required DateTime capturedAt,
  }) {
    final buffer = StringBuffer('{');
    buffer.write('"hubId":$hubId,');
    buffer.write(
      '"capturedAt":${jsonEncode(capturedAt.toUtc().toIso8601String())}',
    );
    buffer.write('}');
    return buffer.toString();
  }
}
