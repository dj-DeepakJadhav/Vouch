import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:utterance_attest/utterance_attest.dart';

void main() {
  final fixture =
      jsonDecode(File('../vectors/signed_payload.json').readAsStringSync())
          as Map<String, dynamic>;
  final cases =
      (jsonDecode(File('../vectors/verify_command.json').readAsStringSync())
          as Map<String, dynamic>)['cases'] as List;
  Future<bool> check(
          {String? payload, String? signature, String? key, String? command}) =>
      Verification.verifyForCommand(
        payload: payload ?? fixture['canonicalPayload'] as String,
        signatureBase64: signature ?? fixture['signatureBase64'] as String,
        trustedPublicKeyBase64: key ?? fixture['public_key_base64'] as String,
        command: command ?? 'send 10 dollars to mom',
        expectedHubId: 1,
        expectedMemberId: 42,
        maxAge: const Duration(seconds: 30),
        now: DateTime.utc(2026, 9, 24, 12, 0, 1),
      );
  for (final item in cases) {
    final c = item as Map<String, dynamic>;
    test('shared command vector: ${c['name']}', () async {
      expect(
          await Verification.verifyForCommand(
            payload: fixture['canonicalPayload'] as String,
            signatureBase64: fixture['signatureBase64'] as String,
            trustedPublicKeyBase64: fixture['public_key_base64'] as String,
            command: c['command'] as String,
            expectedHubId: c['hubId'] as int,
            expectedMemberId: c['memberId'] as int?,
            maxAge: Duration(seconds: c['maxAgeSeconds'] as int),
            now: DateTime.parse(c['now'] as String),
          ),
          c['expected']);
    });
  }
  final p = fixture['canonicalPayload'] as String;
  final malformed = [
    'null',
    '[]',
    '{}',
    '{',
    ' $p',
    p.replaceFirst('"hubId":1,', '"hubId":1,"hubId":1,'),
    p.replaceFirst('"hubId":1', '"hubId":true'),
    p.replaceFirst('"confidence":0.97', '"confidence":1.1'),
    p.replaceFirst('2026-09-24', '2026-02-30'),
    p.replaceFirst('.000Z', '.000123Z')
  ];
  for (var i = 0; i < malformed.length; i++) {
    test('valid signature with invalid or noncanonical payload $i fails',
        () async {
      final key =
          await Attest.keyPairFromSeed(fixture['private_key_base64'] as String);
      final signed = await Attest.sign(malformed[i], key);
      expect(
          await check(
              payload: signed.payload, signature: signed.signatureBase64),
          isFalse);
    });
  }
  test('tampered signature, wrong trusted key and noncanonical base64 fail',
      () async {
    expect(await check(payload: p.replaceFirst('"tier":"t1"', '"tier":"t2"')),
        isFalse);
    final other = await Attest.keyPairFromSeed(
        base64.encode(List.generate(32, (i) => i + 32)));
    final signed = await Attest.sign(p, other);
    expect(await check(key: signed.publicKeyBase64), isFalse);
    expect(await check(signature: '${fixture['signatureBase64']}\n'), isFalse);
  });
  test('input limits fail closed', () async {
    expect(await check(command: List.filled(4097, 'a').join()), isFalse);
    expect(await check(payload: List.filled(8193, 'a').join()), isFalse);
  });
}
