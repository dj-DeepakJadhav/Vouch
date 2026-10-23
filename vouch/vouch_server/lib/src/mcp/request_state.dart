import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

/// The decoded payload carried inside an MRTR `requestState` blob (spec
/// 2026-07-28, see Docs/spikes/S2-mcp-challenge-flow.md). Per the spike,
/// MRTR is stateless: everything the server needs to validate a retried
/// `tools/call` must be encoded here and signed, rather than relying on
/// server-side connection/session state.
class RequestStatePayload {
  const RequestStatePayload({
    required this.approvalId,
    required this.householdId,
    required this.tool,
    required this.argsHash,
    required this.exp,
  });

  final int approvalId;
  final int householdId;
  final String tool;

  /// sha256 hex digest of the canonical-JSON-encoded tool args, so a retry
  /// can be checked against the *same* call it was issued for (spike S2:
  /// requestState must encode "a digest of the original tool-call params").
  final String argsHash;

  /// Unix seconds expiry.
  final int exp;

  Map<String, dynamic> toJson() => {
    'approvalId': approvalId,
    'householdId': householdId,
    'tool': tool,
    'argsHash': argsHash,
    'exp': exp,
  };

  static RequestStatePayload fromJson(Map<String, dynamic> json) {
    return RequestStatePayload(
      approvalId: json['approvalId'] as int,
      householdId: json['householdId'] as int,
      tool: json['tool'] as String,
      argsHash: json['argsHash'] as String,
      exp: json['exp'] as int,
    );
  }
}

/// Builds and verifies the opaque, HMAC-SHA256-protected `requestState`
/// blob used by the MCP MRTR guard flow.
///
/// Shape: base64url(payloadJsonBytes) + '.' + base64url(hmacSha256(secret,
/// payloadJsonBytes)). Kept as two dot-separated base64url segments (JWT-
/// like, but deliberately NOT a JWT — no header/alg negotiation surface to
/// attack) so it round-trips safely as an opaque string in JSON-RPC params.
class RequestStateCodec {
  const RequestStateCodec._();

  static String _secret(Session session) {
    final secret = session.passwords['mcpRequestStateSecret'];
    if (secret == null || secret.isEmpty) {
      throw StateError(
        'mcpRequestStateSecret is not configured in passwords.yaml',
      );
    }
    return secret;
  }

  static String encode(Session session, RequestStatePayload payload) {
    final payloadBytes = utf8.encode(jsonEncode(payload.toJson()));
    final sig = Hmac(
      sha256,
      utf8.encode(_secret(session)),
    ).convert(payloadBytes);
    return '${base64Url.encode(payloadBytes)}.${base64Url.encode(sig.bytes)}';
  }

  /// Returns the decoded, verified payload, or `null` if the blob is
  /// malformed or the HMAC does not verify (tampered / wrong secret). Does
  /// NOT check expiry — callers check `exp` themselves so they can produce
  /// a distinct "expired" vs "tampered" outcome.
  static RequestStatePayload? decodeAndVerify(Session session, String raw) {
    final parts = raw.split('.');
    if (parts.length != 2) return null;
    Uint8List payloadBytes;
    Uint8List sigBytes;
    try {
      payloadBytes = base64Url.decode(_pad(parts[0]));
      sigBytes = base64Url.decode(_pad(parts[1]));
    } catch (_) {
      return null;
    }

    final expectedSig = Hmac(
      sha256,
      utf8.encode(_secret(session)),
    ).convert(payloadBytes);
    if (!_constantTimeEquals(expectedSig.bytes, sigBytes)) return null;

    try {
      final decoded = jsonDecode(utf8.decode(payloadBytes));
      if (decoded is! Map<String, dynamic>) return null;
      return RequestStatePayload.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static String _pad(String s) {
    final rem = s.length % 4;
    if (rem == 0) return s;
    return s + ('=' * (4 - rem));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// sha256 hex digest of the canonical JSON encoding of [args] (keys
  /// sorted, so the same logical args always hash the same way regardless
  /// of map insertion order).
  static String hashArgs(Map<String, dynamic> args) {
    final sortedKeys = args.keys.toList()..sort();
    final canonical = <String, dynamic>{for (final k in sortedKeys) k: args[k]};
    return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
  }
}
