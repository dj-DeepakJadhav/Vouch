/// Turns whatever an endpoint call threw into one short sentence for the UI.
///
/// Serverpod hides the cause of an unhandled server exception: the client
/// only sees "Internal server error" with status 500. Showing that verbatim
/// (or a Dart exception's toString) tells a household owner nothing, so the
/// caller names what it was trying to do ([what]) and gets back a plain
/// message, plus a hint where one is known to help.
String friendlyError(Object error, {required String what, String? hint}) {
  final text = error.toString().toLowerCase();
  final String reason;
  if (text.contains('development mode')) {
    reason = 'this server is not running in development mode';
  } else if (text.contains('expired')) {
    reason = 'the request has expired';
  } else if (text.contains('socketexception') ||
      text.contains('failed to fetch') ||
      text.contains('connection refused') ||
      text.contains('xmlhttprequest') ||
      text.contains('clientexception')) {
    reason = "the server can't be reached";
  } else if (text.contains('401') ||
      text.contains('403') ||
      text.contains('not signed in') ||
      text.contains('owner')) {
    reason = "you're not signed in as this household's owner";
  } else {
    reason = 'the server could not complete it';
  }
  final h = hint == null ? '' : ' $hint';
  return "Couldn't $what: $reason.$h";
}
