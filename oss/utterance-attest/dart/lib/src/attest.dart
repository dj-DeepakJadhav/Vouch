import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Ed25519 signing and verification of canonical attestation payloads, plus
/// a freshness-window helper.
///
/// Keys are always raw 32-byte Ed25519 keys, base64-encoded. Callers own key
/// storage and rotation; this module only signs and verifies bytes.
///
/// Package choice: `package:cryptography` (publisher `dint.dev`, actively
/// maintained, pure-Dart Ed25519 implementation) rather than
/// `package:ed25519_edwards` (unmaintained since 2021).
class Attest {
  const Attest._();

  static final Ed25519 _algorithm = Ed25519();

  /// Signs [payload] (as produced by `Payload.canonicalPayload`) with
  /// [keyPair] and returns the payload plus base64 signature and public key,
  /// ready to hand to a verifier.
  static Future<
    ({String payload, String signatureBase64, String publicKeyBase64})
  >
  sign(String payload, SimpleKeyPair keyPair) async {
    final publicKey = await keyPair.extractPublicKey();
    final signature = await _algorithm.sign(
      Uint8List.fromList(utf8.encode(payload)),
      keyPair: keyPair,
    );
    return (
      payload: payload,
      signatureBase64: base64.encode(signature.bytes),
      publicKeyBase64: base64.encode(publicKey.bytes),
    );
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

  /// Builds a [SimpleKeyPair] from a raw 32-byte base64-encoded Ed25519
  /// private (seed) key, e.g. for loading a fixed test key or a key read
  /// from secure storage.
  static Future<SimpleKeyPair> keyPairFromSeed(String privateKeyBase64) {
    final seed = base64.decode(privateKeyBase64);
    return _algorithm.newKeyPairFromSeed(seed);
  }

  /// True iff [capturedAt] is within [maxAge] of [now] (default: the
  /// current UTC time) and not in the future. Freshness is the caller's
  /// responsibility to check on every use — a valid signature only proves
  /// who signed the payload and that it has not been altered, not that it
  /// is still current.
  static bool isFresh(
    DateTime capturedAt, {
    required Duration maxAge,
    DateTime? now,
  }) {
    final reference = (now ?? DateTime.now()).toUtc();
    final captured = capturedAt.toUtc();
    if (captured.isAfter(reference)) return false;
    return reference.difference(captured) <= maxAge;
  }
}
