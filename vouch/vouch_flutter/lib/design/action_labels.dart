/// Plain-language labels for tool names and household names, so no raw
/// identifier (`unlock_front_door`, `Priya household (dev seed)`) reaches a
/// screen a household member reads.
library;

const _humanActions = {
  'unlock_front_door': 'unlock the front door',
  'place_order': 'place an order',
  'add_to_list': 'add to the shopping list',
  'get_weather': 'check the weather',
  'get_time': 'check the time',
  'play_music': 'play music',
  'read_calendar': 'read the calendar',
  'calendar_write': 'change the calendar',
  'send_message': 'send a message',
};

/// A tool name as a verb phrase: `humanAction('unlock_front_door')` ->
/// `unlock the front door`. Unknown tools fall back to their words
/// (underscores to spaces).
String humanAction(String tool) {
  final hit = _humanActions[tool];
  if (hit != null) return hit;
  return tool.replaceAll('_', ' ').trim();
}

/// The household name as people should see it: the dev seed's trailing
/// " (dev seed)" marker is dropped (the stored name is unchanged).
String householdDisplayName(String name) =>
    name.replaceFirst(RegExp(r'\s*\(dev seed\)\s*$'), '').trim();
