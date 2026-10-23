// Minimal end-to-end example: sign an attestation for one utterance, then
// verify it and check freshness + transcript match, the way an MCP-style
// guard would before allowing a tool call.
//
// Run (from dart/): dart pub get && dart run example/basic.dart

import 'package:cryptography/cryptography.dart';
import 'package:utterance_attest/utterance_attest.dart';

Future<void> main() async {
  // --- On the hub, right after speaker verification decides who spoke ---

  final keyPair = await Ed25519().newKeyPair();

  final transcript = Normalise.normalise('Alexa, send ten dollars to Mom');
  final hash = Normalise.hash(transcript);

  final payload = Payload.canonicalPayload(
    hubId: 1,
    memberId: 42,
    tier: 't1',
    confidence: 0.97,
    spoofRisk: 'low',
    transcriptHash: hash,
    capturedAt: DateTime.now().toUtc(),
  );

  final signed = await Attest.sign(payload, keyPair);

  // --- On the MCP server/guard, given the signed attestation plus the text
  // the voice agent itself recognised for the same command ---

  const alexaRecognisedText = 'send 10 dollars to mom';

  final signatureOk = await Attest.verify(
    payload: signed.payload,
    signatureBase64: signed.signatureBase64,
    publicKeyBase64: signed.publicKeyBase64,
  );
  final fresh = Attest.isFresh(DateTime.now().toUtc(), maxAge: Duration(seconds: 30));
  final sameUtterance = Matching.transcriptsMatch(transcript, alexaRecognisedText);

  final trusted = signatureOk && fresh && sameUtterance;

  print('signature valid: $signatureOk');
  print('fresh:           $fresh');
  print('same utterance:  $sameUtterance');
  print('=> allow tool call: $trusted');

  if (!trusted) {
    throw StateError('example should trust this attestation');
  }
}
