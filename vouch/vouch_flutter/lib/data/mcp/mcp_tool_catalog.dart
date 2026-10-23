/// Mirrors the mock tool catalogue exposed by the real MCP server
/// (vouch_server/lib/src/mcp/tools.dart) closely enough for the Alexa
/// simulator screen to build a `tools/call` request. Kept intentionally
/// small and hand-written rather than fetched via `tools/list` on every
/// screen open, so the example chips can be wired to a known-good tool +
/// argument shape without an extra round trip.
class McpToolSpec {
  const McpToolSpec({
    required this.name,
    required this.label,
    required this.isStepUp,
  });

  final String name;
  final String label;
  final bool isStepUp;
}

const List<McpToolSpec> mcpToolCatalog = [
  McpToolSpec(name: 'get_weather', label: 'Weather (T0)', isStepUp: false),
  McpToolSpec(name: 'play_music', label: 'Play music (T0)', isStepUp: false),
  McpToolSpec(name: 'add_to_list', label: 'Add to list (T1)', isStepUp: false),
  McpToolSpec(
    name: 'read_calendar',
    label: 'Read calendar (T1)',
    isStepUp: false,
  ),
  McpToolSpec(name: 'place_order', label: 'Place order (T2)', isStepUp: true),
  McpToolSpec(name: 'send_message', label: 'Send message (T2)', isStepUp: true),
  McpToolSpec(
    name: 'unlock_front_door',
    label: 'Unlock front door (T2)',
    isStepUp: true,
  ),
];

/// Best-effort keyword heuristic mapping a free-typed (or hub-observed)
/// utterance to the tool it most likely refers to, for the Alexa simulator
/// screen — both for manually typed text and for "Follow hub" mode, where
/// only the utterance (not a tool name) is known. This is a demo
/// convenience, not a real intent classifier: Alexa+ itself would resolve
/// utterance -> tool via its own NLU before ever calling the MCP server.
String inferToolFromUtterance(String utterance) {
  final text = utterance.toLowerCase();
  if (text.contains('unlock') || text.contains('door')) {
    return 'unlock_front_door';
  }
  if (text.contains('order') ||
      text.contains('buy') ||
      text.contains('purchase')) {
    return 'place_order';
  }
  if (text.contains('message') ||
      text.contains('text') ||
      text.contains('tell')) {
    return 'send_message';
  }
  if (text.contains('add') ||
      text.contains('list') ||
      text.contains('shopping')) {
    return 'add_to_list';
  }
  if (text.contains('calendar') || text.contains('schedule')) {
    return 'read_calendar';
  }
  if (text.contains('music') ||
      text.contains('play') ||
      text.contains('song')) {
    return 'play_music';
  }
  return 'get_weather';
}

/// Default demo arguments for a tool, for chips / follow-hub mode where no
/// argument form has been filled in by hand.
Map<String, dynamic> defaultArgsFor(String toolName) {
  switch (toolName) {
    case 'add_to_list':
      return {'item': 'milk'};
    case 'place_order':
      return {
        'item': 'wireless headphones',
        'amount': 249.0,
        'currency': 'EUR',
      };
    case 'send_message':
      return {'to': 'Priya', 'text': 'Running late.'};
    default:
      return {};
  }
}

/// Arguments for [toolName] taken from what was actually said, falling back
/// to [defaultArgsFor] for anything the sentence doesn't state. A demo
/// convenience like [inferToolFromUtterance]: real Alexa+ extracts these
/// itself before calling the MCP server.
Map<String, dynamic> argsFromUtterance(String toolName, String utterance) {
  final args = Map<String, dynamic>.of(defaultArgsFor(toolName));
  final text = utterance.trim();
  switch (toolName) {
    case 'place_order':
      final amount = unambiguousEuroAmount(text);
      if (amount != null) args['amount'] = amount;
      final item = RegExp(
        r'(?:order|buy|purchase)\s+(?:me\s+)?(?:the\s+|a\s+|an\s+)?(.+?)(?:\s+for\s+\d|\s*$)',
        caseSensitive: false,
      ).firstMatch(text);
      if (item != null && item.group(1)!.trim().isNotEmpty) {
        args['item'] = item.group(1)!.trim();
      }
    case 'add_to_list':
      final item = RegExp(
        r'(?:add|put)\s+(?:some\s+)?(.+?)\s+(?:to|on)\s+(?:my\s+|the\s+)?(?:shopping\s+)?list',
        caseSensitive: false,
      ).firstMatch(text);
      if (item != null && item.group(1)!.trim().isNotEmpty) {
        args['item'] = item.group(1)!.trim();
      }
  }
  return args;
}

/// The single euro amount stated in [text] ("for 500 euros", "€12.50"), or
/// null when there is none or it is ambiguous: two or more amounts
/// ("5 euros and 10 euros"), or a list/range sharing one currency word
/// ("5 and 10 euros", "5-10 euros"). Callers keep their default then rather
/// than guess, since the server matches every number exactly.
double? unambiguousEuroAmount(String text) {
  const num = r'\d+(?:[.,]\d+)?';
  final listed = RegExp(
    '$num\\s*(?:and|or|to|-|–|,)\\s*$num\\s*(?:euros?|eur\\b|€)',
    caseSensitive: false,
  );
  if (listed.hasMatch(text)) return null;
  final matches = [
    ...RegExp(
      '($num)\\s*(?:euros?|eur\\b|€)',
      caseSensitive: false,
    ).allMatches(text).map((m) => m.group(1)!),
    ...RegExp('€\\s*($num)').allMatches(text).map((m) => m.group(1)!),
  ];
  final values = matches
      .map((v) => double.parse(v.replaceAll(',', '.')))
      .toSet();
  return values.length == 1 ? values.single : null;
}
