// Reads {"payload": str, "signatureBase64": str, "publicKeyBase64": str}
// JSON from stdin and prints "true" or "false" using the real
// AttestationSignature.verify. Used as a cross-language check: the Python
// hub signs a payload, then shells out to this tool to confirm the
// server's Dart Ed25519 verifier accepts it — proving byte-for-byte
// compatibility between `cryptography` (Python) and `package:cryptography`
// (Dart) for the same raw key/signature encoding.
//
// Usage (from vouch/vouch_server):
//   echo '{"payload":"...","signatureBase64":"...","publicKeyBase64":"..."}' \
//     | dart run tool/verify_signature.dart
import 'dart:convert';
import 'dart:io';

import 'package:vouch_server/src/attestation/attestation_signature.dart';

Future<void> main() async {
  final input = await utf8.decoder.bind(stdin).join();
  final Map<String, dynamic> json = jsonDecode(input) as Map<String, dynamic>;

  final result = await AttestationSignature.verify(
    payload: json['payload'] as String,
    signatureBase64: json['signatureBase64'] as String,
    publicKeyBase64: json['publicKeyBase64'] as String,
  );

  print(result);
}
