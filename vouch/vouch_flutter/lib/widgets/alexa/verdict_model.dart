/// Plain-language reading of one `structuredContent.vouch` trace, for the
/// simulated Alexa+ screen: the big verdict sentence, the 3-row summary and
/// what Alexa+ says out loud. Pure functions, no widgets: the precise server
/// reason is kept as the verdict's secondary line, never in Alexa's bubble.
library;

import '../../design/action_labels.dart';

enum VerdictKind { idle, deciding, allowed, blocked, waiting, error }

class AlexaVerdict {
  const AlexaVerdict(this.kind, this.headline, [this.detail]);

  final VerdictKind kind;

  /// One big plain sentence.
  final String headline;

  /// The server's precise reason (secondary line).
  final String? detail;
}

class SummaryRow {
  const SummaryRow(this.label, this.value, this.kind);
  final String label;
  final String value;

  /// allowed = good, blocked = bad, waiting = amber, idle = neutral.
  final VerdictKind kind;
}

/// Server reason text rewritten for display only: no "(approval 45)", tool
/// names as plain actions, no doubled parentheses, "household default".
String friendlyReason(String text) {
  var t = text.replaceAll(
    RegExp(r'\s*\(approval\s*#?\d+\)', caseSensitive: false),
    '',
  );
  t = t.replaceAllMapped(
    RegExp(r'"([a-z][a-z0-9]*(?:_[a-z0-9]+)+)"'),
    (m) => humanAction(m[1]!),
  );
  t = t.replaceAllMapped(
    RegExp(r'\s*\(([^()]*)\)\s*\(([^()]*)\)'),
    (m) => ' (${m[1]}, ${m[2]})',
  );
  // "for place an order (Children may...)" reads oddly; keep the rule in dashes.
  t = t.replaceAllMapped(
    RegExp(r'\s*\(\s*\(([^()]*)\)\s*\)'),
    (m) => ' (${m[1]})',
  );
  t = t.replaceAll(
    RegExp(r'default policy', caseSensitive: false),
    'household default',
  );
  return t.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

String? _clean(String? r) => r == null ? null : friendlyReason(r);

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _decision(Map<String, dynamic> v) => v['decision'] as String? ?? '';

bool _isWaiting(String d) => d == 'stepUp' || d == 'pending';
bool _isAllowed(String d) => d == 'allow' || d == 'approved';

String? _speakerName(Map<String, dynamic> v) =>
    (v['speaker'] as Map<String, dynamic>?)?['displayName'] as String?;

String? _speakerRole(Map<String, dynamic> v) =>
    (v['speaker'] as Map<String, dynamic>?)?['role'] as String?;

/// The verdict for the right-hand panel. [vouch] is the latest (merged)
/// trace; [ownerName] is whoever approves step-ups.
AlexaVerdict buildVerdict(
  Map<String, dynamic>? vouch, {
  required bool inFlight,
  String ownerName = 'the owner',
  String? error,
}) {
  if (vouch == null) {
    if (error != null) {
      return AlexaVerdict(
        VerdictKind.error,
        'Something went wrong. Try again.',
        error,
      );
    }
    return inFlight
        ? const AlexaVerdict(VerdictKind.deciding, 'Checking who spoke…')
        : const AlexaVerdict(
            VerdictKind.idle,
            'Say something to Alexa+ and the verdict appears here.',
          );
  }
  final d = _decision(vouch);
  final name = _speakerName(vouch);
  final reason = vouch['reason'] as String?;
  if (_isReplayedApproval(reason)) {
    return const AlexaVerdict(
      VerdictKind.blocked,
      'Blocked. This approval has already been used.',
      'Each approval authorises one action. Nothing ran a second time.',
    );
  }
  if (_isWaiting(d)) {
    return AlexaVerdict(
      VerdictKind.waiting,
      'Waiting for $ownerName to approve on their phone.',
      _clean(reason),
    );
  }
  if (_isAllowed(d)) {
    return AlexaVerdict(
      VerdictKind.allowed,
      d == 'approved'
          ? 'Allowed. $ownerName approved it.'
          : name == null
          ? 'Allowed. This one is open to anyone.'
          : 'Allowed. $name is cleared for this.',
      _clean(reason),
    );
  }
  final headline = switch (d) {
    'denied' => 'Blocked. $ownerName said no.',
    'expired' => 'Blocked. Nobody approved in time.',
    _ =>
      name == null
          ? "Blocked. Vouch doesn't recognise this voice."
          : "Blocked. $name isn't allowed to do this.",
  };
  return AlexaVerdict(VerdictKind.blocked, headline, _clean(reason));
}

/// The three collapsed trace rows: who spoke, does it match what Alexa
/// sent, and the decision with the rule behind it.
List<SummaryRow> buildSummary(Map<String, dynamic> vouch) {
  final name = _speakerName(vouch);
  final conf = (vouch['confidence'] as num?)?.toDouble();
  final matched = vouch['attestationMatched'] as bool? ?? false;
  final heard = vouch['matchedTranscript'] as String?;
  final d = _decision(vouch);
  final rule = vouch['ruleSource'] as String?;

  final (matchText, matchKind) = matched
      ? ('Yes', VerdictKind.allowed)
      : (heard != null && heard.isNotEmpty)
      ? ('Reworded', VerdictKind.waiting)
      : ('No', VerdictKind.blocked);

  final verdict = buildVerdict(vouch, inFlight: false);
  final word = switch (verdict.kind) {
    VerdictKind.allowed => 'Allowed',
    VerdictKind.waiting => 'Waiting for the owner',
    _ => 'Blocked',
  };
  return [
    SummaryRow(
      'Who spoke',
      name == null
          ? 'Unknown voice'
          : conf == null
          ? name
          : '$name · ${(conf * 100).round()}%',
      name == null ? VerdictKind.blocked : VerdictKind.allowed,
    ),
    SummaryRow('Matches what Alexa sent', matchText, matchKind),
    SummaryRow(
      'Decision',
      '$word · ${friendlyReason(rule ?? (d == 'allow' ? 'open to anyone' : 'household default'))}',
      verdict.kind,
    ),
  ];
}

/// What Alexa+ says in the conversation bubble. Allowed calls keep the
/// tool's own result text ("Front door unlocked.").
String alexaReply(
  Map<String, dynamic>? vouch, {
  required String toolText,
  required bool isError,
  String ownerName = 'the owner',
  String? toolName,
}) {
  if (!isError) return toolText;
  if (vouch == null) return toolText;
  final d = _decision(vouch);
  final name = _speakerName(vouch);
  if (_isReplayedApproval(vouch['reason'] as String?)) {
    return "That approval has already been used. I didn't repeat the action.";
  }
  if (d == 'denied') return '$ownerName said no, so I didn\'t do that.';
  if (d == 'expired') return "Nobody approved that in time, so I didn't do it.";
  final reason = (vouch['reason'] as String? ?? '');
  final lower = reason.toLowerCase();

  // Amount limit: say so, whatever the speaker's role.
  final limit = RegExp(
    r'exceeds household limit of ([^()]+?)\s*(?:\(|$)',
    caseSensitive: false,
  ).firstMatch(reason)?[1];
  if (limit != null) {
    return name == null
        ? "Sorry, that's over the household limit of $limit."
        : "Sorry $name, that's over your $limit limit.";
  }
  if (name == null) {
    if (lower.contains('revoked')) {
      return "Sorry, that voice's access has been turned off, so I can't do "
          'that.';
    }
    return "Sorry, I don't recognise your voice, so I can't do that.";
  }
  // Reworded: the voice was recognised but not bound to these exact words.
  if (lower.contains('attested tier below')) {
    return "Sorry $name, I couldn't confirm you said exactly that, so I "
        "can't do it.";
  }
  final ruleDeny = lower.startsWith('denied by policy rule');
  if (ruleDeny && _speakerRole(vouch) == 'child') {
    final what = switch (toolName) {
      'place_order' => 'ordering',
      'unlock_front_door' => 'unlocking the door',
      'send_message' => 'sending messages',
      _ => 'that',
    };
    return "Sorry $name, $what needs a parent. ${_cap(ownerName)} can see "
        'this in the activity log.';
  }
  if (ruleDeny) return 'Sorry $name, a household rule says no to that.';
  return "Sorry $name, I can't do that for you.";
}

/// Alexa's line while a step-up waits on the owner.
String waitingReply(String ownerName) =>
    "I've sent this to $ownerName's phone to approve.";

bool _isReplayedApproval(String? reason) =>
    reason?.toLowerCase().contains('replayed requeststate') ?? false;
