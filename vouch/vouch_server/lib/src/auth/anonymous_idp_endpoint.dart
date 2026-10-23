import 'package:serverpod_auth_idp_server/providers/anonymous.dart';

/// By extending [AnonymousIdpBaseEndpoint], anonymous sign-in is exposed on
/// the server. The app calls `anonymousIdp.login()` automatically on launch
/// (with no UI), then links the resulting session to a household via
/// `pairing.redeem` (see `../pairing/pairing_endpoint.dart`).
class AnonymousIdpEndpoint extends AnonymousIdpBaseEndpoint {}
