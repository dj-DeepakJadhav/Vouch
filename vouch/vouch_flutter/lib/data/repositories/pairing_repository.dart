import 'package:vouch_client/vouch_client.dart';

/// Backs the hub-pairing screen: redeems a 6-digit code the hub printed
/// (`python -m vouch_hub pair`) to link the app's anonymous session to a
/// household owner.
abstract class PairingRepository {
  Future<HouseholdOverview> redeem(String code);
}

class ServerpodPairingRepository implements PairingRepository {
  ServerpodPairingRepository(this._client);

  final Client _client;

  @override
  Future<HouseholdOverview> redeem(String code) => _client.pairing.redeem(code);
}

/// Turns whatever the server throws for a rejected pairing attempt into a
/// short, user-facing message. The server only ever throws a plain
/// `PairingRejected` (not a serialized protocol exception — see
/// `pairing_endpoint.dart`), which crosses the RPC boundary as a generic
/// exception whose `toString()` is `"PairingRejected: <reason>"`; this
/// parses that reason back out rather than showing the raw exception text.
String pairingErrorMessage(Object error) {
  final text = error.toString();
  const prefix = 'PairingRejected: ';
  final reason = text.contains(prefix)
      ? text.substring(text.indexOf(prefix) + prefix.length).trim()
      : null;
  switch (reason) {
    case 'invalid_code':
      return "That code doesn't match. Double-check the hub's screen and try again.";
    case 'expired_code':
      return 'That code has expired. Run `vouch_hub pair` on the hub for a new one.';
    case 'already_used':
      return 'That code has already been used. Run `vouch_hub pair` on the hub for a new one.';
    case 'rate_limited':
      return 'Too many attempts — wait a few minutes and try again.';
    default:
      return 'Could not pair: $text';
  }
}
