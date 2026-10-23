import 'verdict_card.dart';

/// Mock tool catalogue exposed over MCP. No real device integration —
/// every tool just builds a plausible text result (see mcp_route.dart's
/// `_runMockTool`).
///
/// Every tool's input schema includes a required `utterance` string field:
/// the natural-language command text Alexa+ heard, verbatim. This is the
/// field attestations are bound to — the guard flow fuzzy-matches
/// `utterance` against the hub's signed, transcript-bound attestation via
/// `TranscriptMatcher`/`AttestationService.consumeMatching` (see
/// transcript_matcher.dart). Without `utterance`, the server would have no
/// way to tie "who was verified speaking" to "what was asked for" — an MCP
/// client could otherwise present an attestation minted for one command and
/// use it to authorize a completely different one.
class McpTool {
  const McpTool({
    required this.name,
    required this.description,
    required this.extraProperties,
    required this.extraRequired,
  });

  final String name;
  final String description;

  /// JSON-Schema `properties` entries beyond the always-present `utterance`.
  final Map<String, dynamic> extraProperties;

  /// Required property names beyond `utterance`.
  final List<String> extraRequired;

  /// Whether this is a T2 (always-step-up) tool. T2 tools accept an
  /// optional `approvalRef` argument for the legacy (2025-11-25) retry flow
  /// — see mcp_route.dart TASKS item 2: legacy clients have no MRTR, so the
  /// signed approval reference is passed as a normal tool argument on
  /// retry instead of an `inputResponses` field.
  bool get isStepUp => const {
    'place_order',
    'send_message',
    'unlock_front_door',
  }.contains(name);

  Map<String, dynamic> get inputSchema => {
    'type': 'object',
    'properties': {
      'utterance': {
        'type': 'string',
        'description':
            'The exact natural-language command text Alexa+ heard '
            '(e.g. "unlock the front door"). Required so the server can '
            'match this call against a hub-issued voice attestation.',
      },
      ...extraProperties,
      if (isStepUp)
        'approvalRef': {
          'type': 'string',
          'description':
              'Legacy (2025-11-25) retry only: the signed approvalRef '
              'returned by a previous approval_pending result for this '
              'same tool call, once the owner has approved it.',
        },
    },
    'required': ['utterance', ...extraRequired],
  };

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'inputSchema': inputSchema,
    // Links every tool to the read-only ui://vouch/verdict card (MCP Apps,
    // SEP-1865 `_meta.ui.resourceUri` — see verdict_card.dart doc comment).
    '_meta': verdictUiMeta,
  };
}

const List<McpTool> mcpTools = [
  McpTool(
    name: 'get_weather',
    description:
        'Get the current weather forecast (T0, no attestation required).',
    extraProperties: {},
    extraRequired: [],
  ),
  McpTool(
    name: 'play_music',
    description: 'Play music (T0, no attestation required).',
    extraProperties: {},
    extraRequired: [],
  ),
  McpTool(
    name: 'add_to_list',
    description: 'Add an item to the household shopping/todo list (T1).',
    extraProperties: {
      'item': {'type': 'string', 'description': 'The item to add.'},
    },
    extraRequired: ['item'],
  ),
  McpTool(
    name: 'read_calendar',
    description: "Read the household's calendar (T1).",
    extraProperties: {},
    extraRequired: [],
  ),
  McpTool(
    name: 'place_order',
    description: 'Place a purchase order (T2 — always requires step-up).',
    extraProperties: {
      'item': {'type': 'string', 'description': 'The item to order.'},
      'amount': {'type': 'number', 'description': 'The order amount.'},
      'currency': {'type': 'string', 'description': 'ISO 4217 currency code.'},
    },
    extraRequired: ['item', 'amount', 'currency'],
  ),
  McpTool(
    name: 'send_message',
    description:
        'Send a message on the speaker\'s behalf (T2 — always requires step-up).',
    extraProperties: {
      'to': {'type': 'string', 'description': 'Message recipient.'},
      'text': {'type': 'string', 'description': 'Message body.'},
    },
    extraRequired: ['to', 'text'],
  ),
  McpTool(
    name: 'unlock_front_door',
    description: 'Unlock the front door (T2 — always requires step-up).',
    extraProperties: {},
    extraRequired: [],
  ),
  McpTool(
    name: 'check_traffic',
    description:
        'Check current traffic conditions. No built-in default tier — the '
        'household has no rule for it, so it is subject to '
        'ToolRiskClassifier / cached ToolClassification (see PolicyEngine '
        '.decide\'s classifiedTier and McpGuard.handleToolCall), falling '
        'back to T2 if never classified.',
    extraProperties: {},
    extraRequired: [],
  ),
];

McpTool? findMcpTool(String name) {
  for (final t in mcpTools) {
    if (t.name == name) return t;
  }
  return null;
}

/// Builds the mock (no real side effect) result text for a permitted tool
/// call.
String runMockTool(String toolName, Map<String, dynamic> args) {
  switch (toolName) {
    case 'get_weather':
      return "It's a mild 18°C and partly cloudy today.";
    case 'play_music':
      return 'Now playing your saved playlist.';
    case 'add_to_list':
      return 'Added "${args['item']}" to the list.';
    case 'read_calendar':
      return "You have no conflicting events on today's calendar.";
    case 'place_order':
      return 'Placed order for "${args['item']}" — ${args['amount']} ${args['currency']}.';
    case 'send_message':
      return 'Sent message to ${args['to']}.';
    case 'unlock_front_door':
      return 'Front door unlocked.';
    default:
      return 'Done.';
  }
}
