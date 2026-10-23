import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:utterance_attest/utterance_attest.dart';

Map<String, dynamic> _loadVector(String name) {
  final path = '${Directory.current.path}/../vectors/$name';
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('normalise vectors', () {
    final vectors = _loadVector('normalise.json');
    final cases = vectors['cases'] as List;

    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      test(c['input'], () {
        final normalised = Normalise.normalise(c['input'] as String);
        expect(normalised, c['normalised']);
        expect(Normalise.hash(normalised), c['hash']);
      });
    }
  });

  group('matching vectors', () {
    final vectors = _loadVector('matching.json');
    final cases = vectors['cases'] as List;

    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      test('${c['a']} vs ${c['b']}', () {
        final normA = Normalise.normalise(c['a'] as String);
        final normB = Normalise.normalise(c['b'] as String);
        final similarity = Matching.tokenSetSimilarity(normA, normB);
        expect(similarity, closeTo((c['similarity'] as num).toDouble(), 1e-9));
        expect(
          Matching.transcriptsMatch(c['a'] as String, c['b'] as String),
          c['match'],
        );
      });
    }
  });

  group('signed payload vector', () {
    final vector = _loadVector('signed_payload.json');
    final attestation = vector['attestation'] as Map<String, dynamic>;

    test('canonicalPayload matches vector bytes', () {
      final payload = Payload.canonicalPayload(
        hubId: attestation['hubId'] as int,
        memberId: attestation['memberId'] as int?,
        tier: attestation['tier'] as String,
        confidence: (attestation['confidence'] as num).toDouble(),
        spoofRisk: attestation['spoofRisk'] as String,
        transcriptHash: attestation['transcriptHash'] as String,
        capturedAt: DateTime.parse(attestation['capturedAt'] as String),
      );
      expect(payload, vector['canonicalPayload']);
    });

    test('verify accepts the vector signature', () async {
      final ok = await Attest.verify(
        payload: vector['canonicalPayload'] as String,
        signatureBase64: vector['signatureBase64'] as String,
        publicKeyBase64: vector['public_key_base64'] as String,
      );
      expect(ok, isTrue);
    });

    test(
      'signing with the vector private key reproduces the vector signature',
      () async {
        // Proves this Dart implementation, given the SAME fixed test key
        // and the same payload, produces the exact same signature Python's
        // tests verify against — real cross-language compatibility, not
        // just "both accept the other's output".
        final keyPair = await Attest.keyPairFromSeed(
          vector['private_key_base64'] as String,
        );
        final signed = await Attest.sign(
          vector['canonicalPayload'] as String,
          keyPair,
        );
        expect(signed.signatureBase64, vector['signatureBase64']);
        expect(signed.publicKeyBase64, vector['public_key_base64']);
      },
    );

    test('verify rejects a tampered payload', () async {
      final tampered = (vector['canonicalPayload'] as String).replaceFirst(
        '"tier":"t1"',
        '"tier":"t2"',
      );
      final ok = await Attest.verify(
        payload: tampered,
        signatureBase64: vector['signatureBase64'] as String,
        publicKeyBase64: vector['public_key_base64'] as String,
      );
      expect(ok, isFalse);
    });
  });

  group('freshness', () {
    test('within window is fresh', () {
      final now = DateTime.parse('2026-09-24T12:00:30.000Z');
      final captured = DateTime.parse('2026-09-24T12:00:00.000Z');
      expect(
        Attest.isFresh(captured, maxAge: Duration(seconds: 60), now: now),
        isTrue,
      );
      expect(
        Attest.isFresh(captured, maxAge: Duration(seconds: 20), now: now),
        isFalse,
      );
    });

    test('future timestamp is never fresh', () {
      final now = DateTime.parse('2026-09-24T12:00:00.000Z');
      final captured = DateTime.parse('2026-09-24T12:00:30.000Z');
      expect(
        Attest.isFresh(captured, maxAge: Duration(seconds: 60), now: now),
        isFalse,
      );
    });
  });

  group('numeric guard', () {
    test('amount substitution never matches', () {
      expect(
        Matching.transcriptsMatch('send 10 dollars', 'send 1000 dollars'),
        isFalse,
      );
    });
  });
}
