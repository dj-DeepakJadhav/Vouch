import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Verifies Ed25519 signatures the hub attaches to attestation payloads.
///
/// Package choice: `package:cryptography` (publisher `dint.dev`, actively
/// maintained, pure-Dart Ed25519 implementation usable on both the server
/// and the hub's future Dart tooling) rather than `package:ed25519_edwards`
/// (unmaintained since 2021, no null-safety-era releases tracked against
/// current Dart SDKs). `cryptography` also gives us a single dependency we
/// can later reuse for any symmetric encryption needs on the hub side.
class AttestationSignature {
  const AttestationSignature._();

  static final Ed25519 _algorithm = Ed25519();

  /// Builds the canonical, stable-key-order JSON payload the hub signs and
  /// the server verifies against. Field order is fixed (not derived from a
  /// Map's insertion order) so both sides always produce identical bytes.
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

  /// Verifies [signatureBase64] over [payload] against [publicKeyBase64].
  /// Returns `true` iff the signature is valid for that exact payload and
  /// key. Never throws for malformed input — treats it as an invalid
  /// signature, since this sits on the accept/reject path for security
  /// decisions and must not leak parse errors as exceptions callers forget
  /// to catch.
  static Future<bool> verify({
    required String payload,
    required String signatureBase64,
    required String publicKeyBase64,
  }) async {
    try {
      final publicKeyBytes = base64.decode(publicKeyBase64);
      final signatureBytes = base64.decode(signatureBase64);

      final publicKey = SimplePublicKey(
        publicKeyBytes,
        type: KeyPairType.ed25519,
      );
      final signature = Signature(signatureBytes, publicKey: publicKey);

      return await _algorithm.verify(
        Uint8List.fromList(utf8.encode(payload)),
        signature: signature,
      );
    } catch (_) {
      return false;
    }
  }

  /// Convenience for tests / the future hub implementation: generates a
  /// keypair and signs [payload], returning (publicKeyBase64,
  /// signatureBase64).
  static Future<
    ({String publicKeyBase64, String signatureBase64, SimpleKeyPair keyPair})
  >
  signForTest(String payload, {SimpleKeyPair? keyPair}) async {
    final kp = keyPair ?? await _algorithm.newKeyPair();
    final publicKey = await kp.extractPublicKey();
    final signature = await _algorithm.sign(
      Uint8List.fromList(utf8.encode(payload)),
      keyPair: kp,
    );
    return (
      publicKeyBase64: base64.encode(publicKey.bytes),
      signatureBase64: base64.encode(signature.bytes),
      keyPair: kp,
    );
  }
}
