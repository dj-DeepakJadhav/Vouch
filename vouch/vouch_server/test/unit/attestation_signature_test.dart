import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';

void main() {
  group('Given a signed attestation payload', () {
    late String payload;
    late String publicKeyBase64;
    late String signatureBase64;

    setUp(() async {
      payload = AttestationSignature.canonicalPayload(
        hubId: 1,
        memberId: 42,
        tier: 't1',
        confidence: 0.97,
        spoofRisk: 'low',
        transcriptHash: 'abc123',
        capturedAt: DateTime.utc(2026, 9, 23, 12, 0, 0),
      );
      final signed = await AttestationSignature.signForTest(payload);
      publicKeyBase64 = signed.publicKeyBase64;
      signatureBase64 = signed.signatureBase64;
    });

    test('when verifying with the correct key then it passes', () async {
      final valid = await AttestationSignature.verify(
        payload: payload,
        signatureBase64: signatureBase64,
        publicKeyBase64: publicKeyBase64,
      );
      expect(valid, isTrue);
    });

    test('when a field in the payload is tampered then it fails', () async {
      final tamperedPayload = AttestationSignature.canonicalPayload(
        hubId: 1,
        memberId: 42,
        tier: 't2', // tampered
        confidence: 0.97,
        spoofRisk: 'low',
        transcriptHash: 'abc123',
        capturedAt: DateTime.utc(2026, 9, 23, 12, 0, 0),
      );

      final valid = await AttestationSignature.verify(
        payload: tamperedPayload,
        signatureBase64: signatureBase64,
        publicKeyBase64: publicKeyBase64,
      );
      expect(valid, isFalse);
    });

    test('when verified against the wrong hub key then it fails', () async {
      final otherSigned = await AttestationSignature.signForTest(payload);
      // Use a different keypair's public key, but the original signature.
      expect(otherSigned.publicKeyBase64, isNot(publicKeyBase64));

      final valid = await AttestationSignature.verify(
        payload: payload,
        signatureBase64: signatureBase64,
        publicKeyBase64: otherSigned.publicKeyBase64,
      );
      expect(valid, isFalse);
    });

    test('when the signature bytes are corrupted then it fails', () async {
      final corrupted =
          '${signatureBase64.substring(0, signatureBase64.length - 4)}AAAA';
      final valid = await AttestationSignature.verify(
        payload: payload,
        signatureBase64: corrupted,
        publicKeyBase64: publicKeyBase64,
      );
      expect(valid, isFalse);
    });

    test(
      'when the public key is malformed then it fails, not throws',
      () async {
        final valid = await AttestationSignature.verify(
          payload: payload,
          signatureBase64: signatureBase64,
          publicKeyBase64: 'not-valid-base64!!',
        );
        expect(valid, isFalse);
      },
    );
  });
}
