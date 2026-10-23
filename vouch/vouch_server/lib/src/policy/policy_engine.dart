import 'dart:convert';

import '../generated/protocol.dart';

/// The final effect of a policy decision. Distinct from [PolicyEffect] (the
/// model-level `require`/`deny` a single [PolicyRule] carries): this is the
/// resolved outcome after tier comparison, with a third possibility —
/// [stepUp] — for actions that always require a fresh verification.
enum PolicyDecisionEffect {
  /// The action is permitted immediately.
  allow,

  /// The action requires a fresh step-up verification before it may
  /// proceed (always the case for T2 actions).
  stepUp,

  /// The action is refused.
  deny,
}

/// The outcome of a [PolicyEngine.decide] call.
class PolicyDecision {
  const PolicyDecision({
    required this.effect,
    required this.requiredTier,
    required this.matchedRuleId,
    required this.reason,
  });

  /// The resolved effect: allow, step-up, or deny.
  final PolicyDecisionEffect effect;

  /// The trust tier that was resolved as required for this action, either
  /// from a matched rule or from the built-in defaults.
  final TrustTier requiredTier;

  /// The id of the [PolicyRule] that determined this decision, if any rule
  /// matched. `null` when the built-in defaults were used.
  final int? matchedRuleId;

  /// A human-readable explanation of why this decision was reached, for
  /// audit logging.
  final String reason;
}

/// How specific a matching [PolicyRule] is. Higher values win when several
/// rules match the same action.
enum _Specificity {
  householdWide,
  role,
  member,
}

/// Built-in default required tiers, used when no [PolicyRule] matches an
/// action. Fail-safe: anything not explicitly listed defaults to T2.
const Map<String, TrustTier> _defaultTierByAction = {
  'get_weather': TrustTier.t0,
  'get_time': TrustTier.t0,
  'play_music': TrustTier.t0,
  'add_to_list': TrustTier.t1,
  'read_calendar': TrustTier.t1,
  'place_order': TrustTier.t2,
  'send_message': TrustTier.t2,
  'calendar_write': TrustTier.t2,
};

/// Actions whose default tier is resolved by a glob prefix rather than an
/// exact name (e.g. `unlock_door`, `unlock_front_door`).
const List<String> _defaultGlobActionPrefixes = ['unlock_'];

TrustTier _resolveDefaultTier(String action) {
  final exact = _defaultTierByAction[action];
  if (exact != null) return exact;
  for (final prefix in _defaultGlobActionPrefixes) {
    if (action.startsWith(prefix)) return TrustTier.t2;
  }
  // Fail safe: any other unknown action requires the highest tier.
  return TrustTier.t2;
}

/// Public wrapper around [_resolveDefaultTier] for callers outside this
/// file (e.g. [RuleCompiler]'s validator, which must reject any proposal
/// weaker than the built-in default for the action it matches).
TrustTier resolveDefaultTier(String action) => _resolveDefaultTier(action);

/// Public wrapper around [_tierRank] for callers outside this file.
int tierRank(TrustTier tier) => _tierRank(tier);

/// True if [action] has an explicit built-in default tier (an exact match
/// in [_defaultTierByAction], or a glob prefix in
/// [_defaultGlobActionPrefixes]) — as opposed to falling through to the
/// t2 fail-safe purely because it is unrecognised. Callers with an unknown
/// tool catalogue use this to decide whether a cached
/// `ToolClassification` result should apply instead of the fail-safe
/// default (see [PolicyEngine.decide]'s `classifiedTier` parameter and
/// `ToolRiskClassifier`).
bool hasBuiltInDefaultTier(String action) {
  if (_defaultTierByAction.containsKey(action)) return true;
  return _defaultGlobActionPrefixes.any((p) => action.startsWith(p));
}

int _tierRank(TrustTier tier) {
  switch (tier) {
    case TrustTier.t0:
      return 0;
    case TrustTier.t1:
      return 1;
    case TrustTier.t2:
      return 2;
  }
}

bool _actionMatches(String pattern, String action) {
  if (pattern == action) return true;
  if (pattern.endsWith('*')) {
    final prefix = pattern.substring(0, pattern.length - 1);
    return action.startsWith(prefix);
  }
  return false;
}

_Specificity _specificityOf(PolicyRule rule) {
  if (rule.memberId != null) return _Specificity.member;
  if (rule.role != null) return _Specificity.role;
  return _Specificity.householdWide;
}

class _ArgConditionResult {
  const _ArgConditionResult({required this.violated, this.reason});
  final bool violated;
  final String? reason;
}

_ArgConditionResult _checkArgConditions(
  PolicyRule rule,
  Map<String, dynamic> args,
) {
  final raw = rule.argConditions;
  if (raw == null || raw.isEmpty) {
    return const _ArgConditionResult(violated: false);
  }
  Map<String, dynamic> conditions;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const _ArgConditionResult(violated: false);
    }
    conditions = decoded;
  } catch (_) {
    // Malformed argConditions do not block the request; they simply add no
    // extra constraint.
    return const _ArgConditionResult(violated: false);
  }

  final maxAmount = conditions['maxAmount'];
  if (maxAmount is num) {
    final amount = args['amount'];
    if (amount is num && amount > maxAmount) {
      final currency = conditions['currency'];
      final limitText = currency != null
          ? '$currency $maxAmount'
          : '$maxAmount';
      return _ArgConditionResult(
        violated: true,
        reason: 'exceeds household limit of $limitText',
      );
    }
  }

  return const _ArgConditionResult(violated: false);
}

/// A pure, DB-free decision engine for Vouch policy rules.
///
/// [decide] performs no I/O and is synchronous, so it can be unit-tested
/// without a database or a [Session].
class PolicyEngine {
  const PolicyEngine._();

  /// Decides whether [action] with [args] may proceed, given the household's
  /// [rules], the resolved [speaker] (or `null` if unrecognised), their
  /// [speakerRole], and the [attestedTier] presented for this request.
  ///
  /// [classifiedTier] is an optional cached `ToolClassification` result
  /// (looked up by the caller, keyed by [action]) for a tool that has no
  /// built-in default tier. It is only ever consulted when no [PolicyRule]
  /// matches AND [action] has no built-in default (see
  /// [hasBuiltInDefaultTier]) — a rule always wins, and a tool with a
  /// built-in default never needs classification. Passing `null` (no
  /// cached classification yet) simply keeps the existing fail-safe t2
  /// default.
  static PolicyDecision decide({
    required List<PolicyRule> rules,
    Member? speaker,
    required MemberRole? speakerRole,
    required String action,
    required Map<String, dynamic> args,
    required TrustTier attestedTier,
    TrustTier? classifiedTier,
  }) {
    final matching = rules.where(
      (r) => r.enabled && _actionMatches(r.actionPattern, action),
    );

    // Only consider rules that actually apply to this speaker: member-
    // specific rules must match the speaker's member id, role rules must
    // match the speaker's role. Household-wide rules always apply.
    final applicable = matching.where((r) {
      final specificity = _specificityOf(r);
      switch (specificity) {
        case _Specificity.member:
          return speaker != null && r.memberId == speaker.id;
        case _Specificity.role:
          return speakerRole != null && r.role == speakerRole;
        case _Specificity.householdWide:
          return true;
      }
    }).toList();

    PolicyRule? chosen;
    _ArgConditionResult? chosenArgResult;
    _Specificity? chosenSpecificity;

    if (applicable.isNotEmpty) {
      // Highest specificity present among applicable rules.
      final maxSpecificity = applicable
          .map(_specificityOf)
          .reduce((a, b) => a.index > b.index ? a : b);
      final atMaxSpecificity = applicable
          .where((r) => _specificityOf(r) == maxSpecificity)
          .toList();

      for (final rule in atMaxSpecificity) {
        final argResult = _checkArgConditions(rule, args);
        final effectiveEffect = argResult.violated
            ? PolicyEffect.deny
            : rule.effect;

        if (chosen == null) {
          chosen = rule;
          chosenArgResult = argResult;
          chosenSpecificity = maxSpecificity;
          continue;
        }

        final chosenArg = chosenArgResult!;
        final chosenEffective = chosenArg.violated
            ? PolicyEffect.deny
            : chosen.effect;

        // Deny beats require at equal specificity.
        if (effectiveEffect == PolicyEffect.deny &&
            chosenEffective != PolicyEffect.deny) {
          chosen = rule;
          chosenArgResult = argResult;
          continue;
        }
        if (chosenEffective == PolicyEffect.deny &&
            effectiveEffect != PolicyEffect.deny) {
          continue;
        }

        // Same effect: higher tier wins.
        if (_tierRank(rule.requiredTier) > _tierRank(chosen.requiredTier)) {
          chosen = rule;
          chosenArgResult = argResult;
        }
      }
      chosenSpecificity ??= maxSpecificity;
    }

    late TrustTier requiredTier;
    late String reason;
    int? matchedRuleId;
    var isDeny = false;

    if (chosen != null) {
      matchedRuleId = chosen.id;
      requiredTier = chosen.requiredTier;
      final argResult = chosenArgResult!;
      if (argResult.violated) {
        isDeny = true;
        reason = 'Denied: ${argResult.reason}';
      } else if (chosen.effect == PolicyEffect.deny) {
        isDeny = true;
        reason =
            'Denied by policy rule for "$action"'
            '${chosen.sourceText != null ? ' (${chosen.sourceText})' : ''}';
      } else {
        reason =
            'Matched policy rule requiring '
            '${requiredTier.name} for "$action"';
      }
    } else if (classifiedTier != null && !hasBuiltInDefaultTier(action)) {
      requiredTier = classifiedTier;
      reason =
          'No matching rule and no built-in default; cached risk '
          'classification tier ${requiredTier.name} applied for "$action"';
    } else {
      requiredTier = _resolveDefaultTier(action);
      reason =
          'No matching rule; default tier ${requiredTier.name} '
          'applied for "$action"';
    }

    // Unknown speaker: only T0 actions are permitted at all.
    if (speaker == null && !isDeny) {
      if (requiredTier != TrustTier.t0) {
        return PolicyDecision(
          effect: PolicyDecisionEffect.deny,
          requiredTier: requiredTier,
          matchedRuleId: matchedRuleId,
          reason: 'speaker not recognised',
        );
      }
    }

    if (isDeny) {
      return PolicyDecision(
        effect: PolicyDecisionEffect.deny,
        requiredTier: requiredTier,
        matchedRuleId: matchedRuleId,
        reason: reason,
      );
    }

    switch (requiredTier) {
      case TrustTier.t0:
        return PolicyDecision(
          effect: PolicyDecisionEffect.allow,
          requiredTier: requiredTier,
          matchedRuleId: matchedRuleId,
          reason: reason,
        );
      case TrustTier.t1:
        if (_tierRank(attestedTier) >= _tierRank(TrustTier.t1)) {
          return PolicyDecision(
            effect: PolicyDecisionEffect.allow,
            requiredTier: requiredTier,
            matchedRuleId: matchedRuleId,
            reason: reason,
          );
        }
        return PolicyDecision(
          effect: PolicyDecisionEffect.deny,
          requiredTier: requiredTier,
          matchedRuleId: matchedRuleId,
          reason: 'attested tier below required tier ${requiredTier.name}',
        );
      case TrustTier.t2:
        // T2 always requires a fresh step-up, regardless of attested tier.
        return PolicyDecision(
          effect: PolicyDecisionEffect.stepUp,
          requiredTier: requiredTier,
          matchedRuleId: matchedRuleId,
          reason: reason,
        );
    }
  }

  /// Builds the default household-wide [PolicyRule] rows matching the
  /// built-in tier defaults in [_defaultTierByAction]. These are `require`
  /// effect, household-wide (no member, no role) rules, intended to be
  /// inserted once when a household is created.
  static List<PolicyRule> buildDefaultHouseholdRules(int householdId) {
    final rules = <PolicyRule>[];
    _defaultTierByAction.forEach((action, tier) {
      rules.add(
        PolicyRule(
          householdId: householdId,
          actionPattern: action,
          requiredTier: tier,
          effect: PolicyEffect.require,
          enabled: true,
        ),
      );
    });
    for (final prefix in _defaultGlobActionPrefixes) {
      rules.add(
        PolicyRule(
          householdId: householdId,
          actionPattern: '$prefix*',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.require,
          enabled: true,
        ),
      );
    }
    return rules;
  }
}
