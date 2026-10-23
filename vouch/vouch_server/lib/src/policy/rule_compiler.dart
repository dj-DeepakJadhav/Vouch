import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../ai/model_routing.dart';
import '../ai/nebius_client.dart';
import '../audit/audit_service.dart';
import '../generated/protocol.dart';
import '../mcp/tools.dart';
import 'policy_engine.dart' as policy_engine;

/// Raised when a proposal (from the model, or hand-supplied to [confirm])
/// fails strict server-side validation. [reason] is a short, stable,
/// machine-checkable code; [detail] is a human-readable explanation safe to
/// show a household admin.
class RuleValidationException implements Exception {
  const RuleValidationException(this.reason, this.detail);
  final String reason;
  final String detail;

  @override
  String toString() => 'RuleValidationException($reason): $detail';
}

/// Raised when the Nemotron call itself fails, or its output cannot be
/// interpreted as a list of rule proposals at all (as distinct from
/// individual proposals failing validation, which is reported per-item
/// instead of thrown).
class RuleCompilationException implements Exception {
  const RuleCompilationException(this.message);
  final String message;

  @override
  String toString() => 'RuleCompilationException: $message';
}

/// One member of a household, reduced to just what proposal validation
/// needs — kept separate from the generated [Member] model so validation
/// can be unit-tested with hand-written data, no database required.
class HouseholdMemberRef {
  const HouseholdMemberRef({
    required this.id,
    required this.displayName,
    required this.role,
  });
  final int id;
  final String displayName;
  final MemberRole role;
}

/// Compiles plain-language household rule text into [RuleProposal]s via
/// Nemotron, and validates/saves them.
///
/// Nothing here ever trusts the model's output at face value: every
/// proposal — whether freshly generated or replayed into [confirm] — goes
/// through [validate] again before it can become a [PolicyRule] row.
class RuleCompiler {
  const RuleCompiler._();

  static const Set<String> _allowedTopLevelKeys = {
    'actionPattern',
    'requiredTier',
    'effect',
    'memberId',
    'role',
    'argConditions',
    'explanation',
  };

  static const Set<String> _allowedArgConditionKeys = {'maxAmount', 'currency'};

  /// Validates a single raw proposal map (as decoded from Nemotron's JSON
  /// output, or supplied directly to [confirm]) against every known field
  /// semantic, and against [members] for household membership. Never
  /// trusts anything about the shape or values without checking it here —
  /// this is the one place a malicious or malformed proposal is caught.
  ///
  /// Throws [RuleValidationException] on the first violation found.
  static RuleProposal validate(
    Map<String, dynamic> raw, {
    required List<HouseholdMemberRef> members,
  }) {
    for (final key in raw.keys) {
      if (!_allowedTopLevelKeys.contains(key)) {
        throw RuleValidationException(
          'unknown_field',
          'unknown field "$key" in proposal',
        );
      }
    }

    final actionPattern = raw['actionPattern'];
    if (actionPattern is! String || actionPattern.isEmpty) {
      throw const RuleValidationException(
        'invalid_action_pattern',
        'actionPattern must be a non-empty string',
      );
    }
    _validateActionPattern(actionPattern);

    final tierRaw = raw['requiredTier'];
    if (tierRaw is! String) {
      throw const RuleValidationException(
        'invalid_tier',
        'requiredTier must be one of t0, t1, t2',
      );
    }
    final tier = TrustTier.values.where((t) => t.name == tierRaw).firstOrNull;
    if (tier == null) {
      throw RuleValidationException(
        'invalid_tier',
        'requiredTier "$tierRaw" is not one of t0, t1, t2',
      );
    }

    var effect = PolicyEffect.require;
    final effectRaw = raw['effect'];
    if (effectRaw != null) {
      if (effectRaw is! String) {
        throw const RuleValidationException(
          'invalid_effect',
          'effect must be one of require, deny',
        );
      }
      final matched = PolicyEffect.values
          .where((e) => e.name == effectRaw)
          .firstOrNull;
      if (matched == null) {
        throw RuleValidationException(
          'invalid_effect',
          'effect "$effectRaw" is not one of require, deny',
        );
      }
      effect = matched;
    }

    // Never let a compiled/replayed proposal be weaker than the household's
    // built-in default for the action(s) it matches. A "require" rule whose
    // tier is below the built-in default for any tool the pattern matches
    // is rejected outright — e.g. "X can't buy anything over N" must never
    // compile to a t0 rule for place_order (whose built-in default is t2).
    // A "deny" rule is never weaker than any tier, so it is exempt.
    if (effect == PolicyEffect.require) {
      final matchedTools = _matchedToolNames(actionPattern);
      var maxDefaultRank = -1;
      TrustTier? maxDefaultTier;
      for (final toolName in matchedTools) {
        final toolDefault = policy_engine.resolveDefaultTier(toolName);
        final rank = policy_engine.tierRank(toolDefault);
        if (rank > maxDefaultRank) {
          maxDefaultRank = rank;
          maxDefaultTier = toolDefault;
        }
      }
      if (maxDefaultTier != null &&
          policy_engine.tierRank(tier) < maxDefaultRank) {
        throw RuleValidationException(
          'tier_below_default',
          'requiredTier "${tier.name}" is weaker than the household '
              'default "${maxDefaultTier.name}" for action "$actionPattern" '
              '— a rule may only require the same tier or stricter, never '
              'looser (use effect "deny" instead, or omit maxAmount above '
              'the default tier, to tighten access below N)',
        );
      }
    }

    int? memberId;
    final memberIdRaw = raw['memberId'];
    if (memberIdRaw != null) {
      if (memberIdRaw is! int) {
        throw const RuleValidationException(
          'invalid_member_id',
          'memberId must be an integer',
        );
      }
      final belongs = members.any((m) => m.id == memberIdRaw);
      if (!belongs) {
        throw RuleValidationException(
          'member_not_in_household',
          'memberId $memberIdRaw does not belong to this household',
        );
      }
      memberId = memberIdRaw;
    }

    MemberRole? role;
    final roleRaw = raw['role'];
    if (roleRaw != null) {
      if (roleRaw is! String) {
        throw const RuleValidationException(
          'invalid_role',
          'role must be one of owner, adult, child, guest',
        );
      }
      final matched = MemberRole.values
          .where((r) => r.name == roleRaw)
          .firstOrNull;
      if (matched == null) {
        throw RuleValidationException(
          'invalid_role',
          'role "$roleRaw" is not one of owner, adult, child, guest',
        );
      }
      role = matched;
    }

    if (memberId != null && role != null) {
      throw const RuleValidationException(
        'ambiguous_scope',
        'a proposal cannot set both memberId and role',
      );
    }

    String? argConditionsJson;
    final argConditionsRaw = raw['argConditions'];
    if (argConditionsRaw != null) {
      if (argConditionsRaw is! Map) {
        throw const RuleValidationException(
          'invalid_arg_conditions',
          'argConditions must be an object',
        );
      }
      final conditions = argConditionsRaw.cast<String, dynamic>();
      for (final key in conditions.keys) {
        if (!_allowedArgConditionKeys.contains(key)) {
          throw RuleValidationException(
            'unknown_field',
            'unknown argConditions field "$key"',
          );
        }
      }
      final maxAmount = conditions['maxAmount'];
      if (maxAmount != null) {
        if (maxAmount is! num || maxAmount < 0) {
          throw const RuleValidationException(
            'invalid_max_amount',
            'argConditions.maxAmount must be a number >= 0',
          );
        }
      }
      final currency = conditions['currency'];
      if (currency != null && currency is! String) {
        throw const RuleValidationException(
          'invalid_currency',
          'argConditions.currency must be a string',
        );
      }
      argConditionsJson = jsonEncode(conditions);
    }

    final explanation = raw['explanation'];
    if (explanation is! String || explanation.isEmpty) {
      throw const RuleValidationException(
        'invalid_explanation',
        'explanation must be a non-empty string',
      );
    }

    return RuleProposal(
      memberId: memberId,
      role: role,
      actionPattern: actionPattern,
      requiredTier: tier,
      effect: effect,
      argConditions: argConditionsJson,
      explanation: explanation,
    );
  }

  /// actionPattern must be exactly a known tool name, or a `<prefix>*` glob
  /// that matches at least one known tool — never an arbitrary/unknown
  /// string the model invented.
  static void _validateActionPattern(String pattern) {
    if (pattern.endsWith('*')) {
      final prefix = pattern.substring(0, pattern.length - 1);
      final matchesAny = mcpTools.any((t) => t.name.startsWith(prefix));
      if (!matchesAny) {
        throw RuleValidationException(
          'unknown_action_pattern',
          'actionPattern "$pattern" matches no known tool',
        );
      }
      return;
    }
    if (findMcpTool(pattern) == null) {
      throw RuleValidationException(
        'unknown_action_pattern',
        'actionPattern "$pattern" is not a known tool',
      );
    }
  }

  /// The known tool name(s) an already-validated [pattern] matches — either
  /// the single exact tool name, or every known tool starting with the
  /// pattern's prefix (for a `"prefix*"` glob).
  static List<String> _matchedToolNames(String pattern) {
    if (pattern.endsWith('*')) {
      final prefix = pattern.substring(0, pattern.length - 1);
      return mcpTools
          .where((t) => t.name.startsWith(prefix))
          .map((t) => t.name)
          .toList();
    }
    final tool = findMcpTool(pattern);
    return tool == null ? const [] : [tool.name];
  }

  static String _toolCatalogueDescription() {
    final buffer = StringBuffer();
    for (final tool in mcpTools) {
      final args = [
        ...tool.extraRequired,
        ...tool.extraProperties.keys.where(
          (k) => !tool.extraRequired.contains(k),
        ),
      ];
      buffer.writeln(
        '- ${tool.name}: ${tool.description}'
        '${args.isNotEmpty ? ' (args: ${args.join(', ')})' : ''}',
      );
    }
    return buffer.toString();
  }

  static String _membersDescription(List<HouseholdMemberRef> members) {
    final buffer = StringBuffer();
    for (final m in members) {
      buffer.writeln('- id ${m.id}: "${m.displayName}" (role: ${m.role.name})');
    }
    return buffer.toString();
  }

  static String _buildPrompt({
    required String text,
    required List<HouseholdMemberRef> members,
  }) {
    return '''
You compile a household's plain-language access rule into structured policy
rules for a voice-authentication system.

Household members:
${_membersDescription(members)}

Available tools (actions a voice assistant may be asked to perform):
${_toolCatalogueDescription()}

Field semantics for each rule you propose:
- actionPattern: must be exactly one of the tool names above, or a prefix
  ending in "*" that matches one or more of them (e.g. "unlock_*").
- requiredTier: one of "t0", "t1", "t2" — the minimum trust tier required.
  t0 = no verification, t1 = voice match, t2 = voice match + step-up.
- effect: "require" (permitted once the tier is met) or "deny" (refused
  outright regardless of tier).
- Scope the rule to at most one of: memberId (an id from the list above) or
  role (one of "owner", "adult", "child", "guest"). Omit both for a
  household-wide rule.
- argConditions (optional object): {"maxAmount": <number>, "currency":
  "<ISO 4217 code>"} — a spending limit condition, only meaningful for
  actions that take an amount/currency (e.g. place_order).
- explanation: one plain-English sentence describing what the rule does.

CRITICAL — never propose a rule weaker than the built-in default for the
action it matches. Built-in defaults: get_weather/play_music = t0,
add_to_list/read_calendar = t1, place_order/send_message/unlock_* = t2.
A "requiredTier" below that default for a "require" rule will be rejected.
In particular:
- A spending limit ("X can't buy anything over N") must NOT be compiled as
  a t0/t1 rule — place_order's default is already t2. Compile it as ONE
  rule scoped to X, with actionPattern "place_order", requiredTier "t2",
  effect "require" and argConditions.maxAmount = N. The policy engine
  blocks any order over N outright and sends orders at or under N to the
  owner for approval. Do NOT add a second "deny" rule for the same scope
  and action: a deny without argConditions would block every order,
  including those under N.
- "Can't <do something>" for an action whose default is already t2 (buy,
  unlock, send a message) should generally use effect "deny" scoped to the
  named member/role, since t2 is already the strictest tier and a "require"
  rule cannot express an outright refusal.

The household admin said:
"$text"

Reply with ONLY a JSON object of the form {"rules": [ { ...one object per
field semantics above... } ]}. Propose one or more rules that implement
what was asked. Do not include any field not listed above. Do not include
any prose outside the JSON object.
''';
  }

  /// Calls Nemotron to compile [text] into proposed rules for [householdId],
  /// then strictly validates every proposal returned. Never saves anything
  /// — see [confirm] for that. Returns both the proposals that passed
  /// validation and a human-readable rejection message for every proposal
  /// (well-formed or not) that didn't.
  static Future<RulePreviewResult> preview(
    Session session, {
    required int householdId,
    required String text,
    NebiusClient? client,
    String model = ModelRouting.ruleCompilation,
  }) async {
    final members = await Member.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
    );
    final memberRefs = members
        .map(
          (m) => HouseholdMemberRef(
            id: m.id!,
            displayName: m.displayName,
            role: m.role,
          ),
        )
        .toList();

    final nebius = client ?? await _defaultClient(session);
    final prompt = _buildPrompt(text: text, members: memberRefs);

    NebiusChatResult result;
    try {
      result = await nebius.chatCompletion(
        model: model,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        responseFormat: const {'type': 'json_object'},
      );
    } on NebiusApiException catch (e) {
      // Structured output not supported by this model/deployment: fall
      // back to a strict prompt + manual parse, no response_format.
      try {
        result = await nebius.chatCompletion(
          model: model,
          messages: [
            {'role': 'user', 'content': prompt},
          ],
        );
      } on NebiusApiException catch (e2) {
        throw RuleCompilationException(
          'Nemotron call failed: $e (retry without response_format also '
          'failed: $e2)',
        );
      }
    }

    final rawRules = _extractRulesList(result.content);
    if (rawRules == null) {
      throw RuleCompilationException(
        'Nemotron output could not be parsed as a rules list: '
        '${result.content}',
      );
    }

    final proposals = <RuleProposal>[];
    final rejected = <String>[];
    for (final raw in rawRules) {
      if (raw is! Map) {
        rejected.add('proposal was not a JSON object: $raw');
        continue;
      }
      try {
        proposals.add(
          validate(raw.cast<String, dynamic>(), members: memberRefs),
        );
      } on RuleValidationException catch (e) {
        rejected.add('${e.reason}: ${e.detail}');
      }
    }

    return RulePreviewResult(
      proposals: proposals,
      rejected: rejected,
      rawModelOutput: result.content,
    );
  }

  /// Parses the model's JSON content, tolerating either `{"rules": [...]}`
  /// or a bare top-level `[...]` (models sometimes drop the wrapper object
  /// even under an explicit instruction not to). Returns `null` if neither
  /// shape can be found.
  static List<dynamic>? _extractRulesList(String content) {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      return null;
    }
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['rules'] is List) {
      return decoded['rules'] as List;
    }
    return null;
  }

  static Future<NebiusClient> _defaultClient(Session session) async {
    final apiKey = session.passwords['nebiusApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const RuleCompilationException(
        'nebiusApiKey is not configured for this run mode',
      );
    }
    return NebiusClient(apiKey: apiKey);
  }

  /// Re-validates every proposal in [proposals] (never trusting that a
  /// previous [preview] call actually produced them unmodified — the
  /// Flutter app round-trips them through the client) and, only if every
  /// single one passes, saves them all as enabled [PolicyRule] rows with
  /// `sourceText` set to [sourceText]. All-or-nothing: throws
  /// [RuleValidationException] (naming the first offending proposal) and
  /// saves nothing if any proposal fails.
  static Future<List<PolicyRule>> confirm(
    Session session, {
    required int householdId,
    required List<RuleProposal> proposals,
    required String sourceText,
  }) async {
    final members = await Member.db.find(
      session,
      where: (t) => t.householdId.equals(householdId),
    );
    final memberRefs = members
        .map(
          (m) => HouseholdMemberRef(
            id: m.id!,
            displayName: m.displayName,
            role: m.role,
          ),
        )
        .toList();

    // Re-validate by round-tripping each proposal back through the exact
    // same raw-map validator confirm's caller (Nemotron, or a hand-crafted
    // client request) would have produced — never trust the typed
    // RuleProposal object alone, since it was still built from
    // caller-supplied data over RPC.
    final revalidated = <RuleProposal>[];
    for (final proposal in proposals) {
      final raw = <String, dynamic>{
        'actionPattern': proposal.actionPattern,
        'requiredTier': proposal.requiredTier.name,
        'effect': proposal.effect.name,
        if (proposal.memberId != null) 'memberId': proposal.memberId,
        if (proposal.role != null) 'role': proposal.role!.name,
        if (proposal.argConditions != null)
          'argConditions': jsonDecode(proposal.argConditions!),
        'explanation': proposal.explanation,
      };
      revalidated.add(validate(raw, members: memberRefs));
    }

    final saved = <PolicyRule>[];
    for (final proposal in revalidated) {
      final rule = PolicyRule(
        householdId: householdId,
        memberId: proposal.memberId,
        role: proposal.role,
        actionPattern: proposal.actionPattern,
        requiredTier: proposal.requiredTier,
        effect: proposal.effect,
        sourceText: sourceText,
        argConditions: proposal.argConditions,
        enabled: true,
      );
      saved.add(await PolicyRule.db.insertRow(session, rule));
    }

    for (final rule in saved) {
      await AuditService.append(
        session,
        householdId: householdId,
        memberId: rule.memberId,
        eventType: 'policy.rule_created',
        action: rule.actionPattern,
        decision: AuditDecision.permitted,
        reason:
            'Rule compiled from "$sourceText": ${rule.effect.name} '
            '${rule.requiredTier.name} for "${rule.actionPattern}"',
      );
    }

    return saved;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
