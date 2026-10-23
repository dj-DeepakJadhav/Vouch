import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../logic/household_controller.dart';
import '../logic/rules_controller.dart';
import '../logic/friendly_error.dart';

/// Human-readable scope for a rule/proposal: the member's name if it's
/// member-specific, the role (pluralised) if it's role-specific, or
/// "Everyone" for a household-wide rule.
String describeScope(int? memberId, MemberRole? role, List<Member> members) {
  if (memberId != null) {
    for (final m in members) {
      if (m.id == memberId) return m.displayName;
    }
    return 'Member #$memberId';
  }
  if (role != null) {
    switch (role) {
      case MemberRole.owner:
        return 'Owners';
      case MemberRole.adult:
        return 'Adults';
      case MemberRole.child:
        return 'Children';
      case MemberRole.guest:
        return 'Guests';
    }
  }
  return 'Everyone';
}

/// A tool/action pattern as a plain noun phrase ("place_order" ->
/// "orders", "unlock_*" -> "unlocking doors"). Unknown names fall back to
/// their words with no stray spaces.
String describeAction(String actionPattern) {
  const known = {
    'place_order': 'orders',
    'place_*': 'orders',
    'unlock_*': 'unlocking doors',
    'unlock_front_door': 'unlocking the front door',
    'add_to_list': 'adding to the shopping list',
    'get_weather': 'weather questions',
    'get_time': 'time questions',
    'play_music': 'playing music',
    'read_calendar': 'reading the calendar',
    'calendar_write': 'calendar changes',
    'send_message': 'sending messages',
  };
  final hit = known[actionPattern];
  if (hit != null) return hit;
  final words = actionPattern
      .replaceAll('*', ' ')
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .join(' ');
  return actionPattern.endsWith('*') ? 'anything starting "$words"' : words;
}

/// The `{"maxAmount":10,"currency":"EUR"}`-style argConditions JSON as a
/// plain amount, e.g. "EUR 10". Returns `null` if there is no limit or it
/// could not be parsed.
String? describeLimits(String? argConditionsJson) {
  if (argConditionsJson == null || argConditionsJson.isEmpty) return null;
  try {
    final decoded = jsonDecode(argConditionsJson);
    if (decoded is! Map) return null;
    final maxAmount = decoded['maxAmount'];
    if (maxAmount is! num) return null;
    final currency = decoded['currency'];
    final amount = maxAmount == maxAmount.roundToDouble()
        ? '${maxAmount.toInt()}'
        : '$maxAmount';
    return currency != null ? '$currency $amount' : amount;
  } catch (_) {
    return null;
  }
}

bool _isPlural(String action) => const {
  'orders',
  'weather questions',
  'time questions',
  'calendar changes',
}.contains(action);

/// One plain sentence stating what a [RuleProposal] (or confirmed
/// [PolicyRule]) will do, mirroring PolicyEngine's evaluation: a deny rule
/// always blocks; a require rule with a maxAmount blocks anything over it
/// and applies its tier at or below it. E.g.
/// "Ana: orders over EUR 10 are blocked; orders up to EUR 10 need your
/// approval."
String describeRule({
  required int? memberId,
  required MemberRole? role,
  required String actionPattern,
  required PolicyEffect effect,
  required TrustTier requiredTier,
  required String? argConditionsJson,
  required List<Member> members,
}) {
  final scope = describeScope(memberId, role, members);
  final action = describeAction(actionPattern);
  final limit = describeLimits(argConditionsJson);
  final plural = _isPlural(action) || limit != null;
  final be = plural ? 'are' : 'is';
  if (effect == PolicyEffect.deny) {
    return '$scope: $action $be always blocked.';
  }
  final consequence = switch (requiredTier) {
    TrustTier.t2 => '${plural ? 'need' : 'needs'} your approval each time',
    TrustTier.t1 => '${plural ? 'need' : 'needs'} a known voice',
    TrustTier.t0 => '$be allowed for anyone',
  };
  if (limit != null) {
    return '$scope: $action over $limit are blocked; '
        '$action up to $limit $consequence.';
  }
  return '$scope: $action $consequence.';
}

const _exampleChips = [
  "Ana can't buy anything over 10 euros",
  "Guests can't unlock doors",
];

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final _textController = TextEditingController();
  final Set<int> _accepted = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RulesController>().load();
    });
    // Rebuild on every keystroke so the Preview button's enabled state
    // (which reads _textController.text directly) stays in sync.
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _preview(RulesController controller) async {
    _accepted.clear();
    await controller.requestPreview(_textController.text.trim());
    // Pre-check every proposal that passed server-side validation — the
    // household admin only needs to uncheck the ones they disagree with.
    final p = controller.preview;
    if (p != null) {
      setState(() {
        _accepted
          ..clear()
          ..addAll(List.generate(p.proposals.length, (i) => i));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final members =
        context.watch<HouseholdController>().overview?.members ?? const [];
    return Consumer<RulesController>(
      builder: (context, controller, _) {
        final canPreview =
            !controller.previewing && _textController.text.trim().isNotEmpty;
        return VPage(
          maxWidth: 760,
          children: [
            const FadeSlideIn(
              child: VPageHeader(
                title: 'Rules',
                subtitle:
                    'Write it the way you would say it. Nemotron turns it into '
                    'precise rules you can check one by one.',
              ),
            ),
            const FadeSlideIn(index: 1, child: TierLegend()),
            const SizedBox(height: VSpace.s4),
            FadeSlideIn(
              index: 1,
              child: VSurface(
                emphasized: true,
                padding: const EdgeInsets.all(VSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('rule-text-field'),
                      controller: _textController,
                      minLines: 2,
                      maxLines: 4,
                      style: VType.large.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'e.g. "Ana can\'t buy anything over 10 euros"',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(VSpace.s1),
                      ),
                    ),
                    const SizedBox(height: VSpace.s3),
                    Wrap(
                      spacing: VSpace.s1_5,
                      runSpacing: VSpace.s1_5,
                      children: [
                        for (final chip in _exampleChips)
                          _SuggestionPill(
                            label: chip,
                            onTap: () =>
                                setState(() => _textController.text = chip),
                          ),
                      ],
                    ),
                    const SizedBox(height: VSpace.s3),
                    Divider(color: c.border),
                    const SizedBox(height: VSpace.s3),
                    Row(
                      children: [
                        Icon(
                          VIcons.lock,
                          size: VSize.iconXs,
                          color: c.textDisabled,
                        ),
                        const SizedBox(width: VSpace.s1_5),
                        Expanded(
                          child: Text(
                            'Nothing is saved until you confirm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: VType.supporting.copyWith(
                              color: c.textDisabled,
                            ),
                          ),
                        ),
                        if (controller.preview != null)
                          Padding(
                            padding: const EdgeInsets.only(right: VSpace.s2),
                            child: TextButton(
                              onPressed: () {
                                controller.clearPreview();
                                setState(() => _accepted.clear());
                              },
                              child: const Text('Discard'),
                            ),
                          ),
                        FilledButton.icon(
                          key: const Key('preview-button'),
                          onPressed: canPreview
                              ? () => _preview(controller)
                              : null,
                          icon: controller.previewing
                              ? SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: c.textDisabled,
                                  ),
                                )
                              : const Icon(VIcons.compile),
                          label: const Text('Preview'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (controller.previewError != null) ...[
              const SizedBox(height: VSpace.s3),
              VInlineError(
                friendlyError(
                  controller.previewError!,
                  what: 'compile that rule',
                  hint:
                      'Rule compilation needs a Nebius API key on the server '
                      '(nebiusApiKey in config/passwords.yaml); everything '
                      'else works without it.',
                ),
              ),
            ],
            AnimatedSize(
              duration: VMotion.of(context, VMotion.medium),
              curve: VMotion.standard,
              alignment: Alignment.topCenter,
              child: controller.preview == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: VSpace.s4),
                      child: FadeSlideIn(
                        child: _PreviewPanel(
                          preview: controller.preview!,
                          members: members,
                          accepted: _accepted,
                          onToggle: (i, v) => setState(() {
                            if (v) {
                              _accepted.add(i);
                            } else {
                              _accepted.remove(i);
                            }
                          }),
                          onConfirm: () async {
                            final chosen = [
                              for (final i in _accepted)
                                controller.preview!.proposals[i],
                            ];
                            if (chosen.isEmpty) return;
                            await controller.confirm(
                              chosen,
                              _textController.text.trim(),
                            );
                            _textController.clear();
                            setState(() => _accepted.clear());
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: VSpace.s10),
            VSectionHeader(
              'Active rules',
              count: controller.loading ? null : controller.rules.length,
            ),
            if (controller.loading)
              const VListSkeleton(rows: 3)
            else if (controller.rules.isEmpty)
              const VSurface(
                child: VEmptyState(
                  icon: VIcons.rules,
                  title: 'No rules configured yet',
                  body:
                      'Without rules, only the default tiers apply. Write your first one above.',
                ),
              )
            else
              VSurface(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < controller.rules.length; i++) ...[
                      if (i > 0) const Divider(),
                      FadeSlideIn(
                        key: ValueKey('rule-${controller.rules[i].id}'),
                        index: i,
                        child: _RuleRow(
                          rule: controller.rules[i],
                          members: members,
                          onDisable: controller.disable,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Pressable(
      onTap: onTap,
      borderRadius: VRadius.fullR,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: VSpace.s3, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: VRadius.fullR,
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(VIcons.arrowRight, size: VSize.iconXs, color: c.textDisabled),
            const SizedBox(width: VSpace.s1_5),
            Flexible(
              child: Text(
                label,
                style: VType.supporting.copyWith(
                  color: c.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.preview,
    required this.members,
    required this.accepted,
    required this.onToggle,
    required this.onConfirm,
  });

  final RulePreviewResult preview;
  final List<Member> members;
  final Set<int> accepted;
  final void Function(int index, bool value) onToggle;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return VSurface(
      key: const Key('rule-preview-panel'),
      padding: const EdgeInsets.all(VSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const VEyebrow('Compiled'),
              const SizedBox(width: VSpace.s2),
              Expanded(
                child: Text(
                  'Check the ones you want to save.',
                  style: VType.supporting.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: VSpace.s3),
          for (var i = 0; i < preview.proposals.length; i++)
            FadeSlideIn(
              index: i,
              child: _ProposalTile(
                key: Key('proposal-checkbox-$i'),
                proposal: preview.proposals[i],
                members: members,
                checked: accepted.contains(i),
                onChanged: (v) => onToggle(i, v ?? false),
              ),
            ),
          if (preview.rejected.isNotEmpty) ...[
            const SizedBox(height: VSpace.s3),
            const VEyebrow('Could not apply'),
            const SizedBox(height: VSpace.s2),
            for (final r in preview.rejected)
              Padding(
                key: const Key('rejected-proposal'),
                padding: const EdgeInsets.only(top: VSpace.s1),
                child: QuietDenialBorder(
                  child: Text(
                    r,
                    style: VType.body.copyWith(color: c.errorText),
                  ),
                ),
              ),
          ],
          const SizedBox(height: VSpace.s4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('confirm-button'),
              onPressed: accepted.isEmpty ? null : onConfirm,
              icon: const Icon(VIcons.check),
              label: Text(
                accepted.isEmpty
                    ? 'Confirm'
                    : 'Confirm ${accepted.length} rule${accepted.length == 1 ? '' : 's'}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One proposal: the whole card is the checkbox target. The plain-English
/// rule sentence (scope, action, effect, tier, limits — see [describeRule])
/// sits above the model's explanation.
class _ProposalTile extends StatelessWidget {
  const _ProposalTile({
    super.key,
    required this.proposal,
    required this.members,
    required this.checked,
    required this.onChanged,
  });

  final RuleProposal proposal;
  final List<Member> members;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final sentence = describeRule(
      memberId: proposal.memberId,
      role: proposal.role,
      actionPattern: proposal.actionPattern,
      effect: proposal.effect,
      requiredTier: proposal.requiredTier,
      argConditionsJson: proposal.argConditions,
      members: members,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: VSpace.s2),
      child: Pressable(
        onTap: () => onChanged(!checked),
        selected: checked,
        borderRadius: VRadius.elementR,
        scale: false,
        child: AnimatedContainer(
          duration: VMotion.of(context, VMotion.fast),
          curve: VMotion.standard,
          padding: const EdgeInsets.all(VSpace.s3),
          decoration: BoxDecoration(
            color: checked ? c.surfaceRaised : Colors.transparent,
            borderRadius: VRadius.elementR,
            border: Border.all(color: checked ? c.borderEmphasized : c.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: checked,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: VSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence,
                      style: VType.label.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      proposal.explanation,
                      style: VType.supporting.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VSpace.s3),
              TierChip(tier: proposal.requiredTier),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.rule,
    required this.members,
    required this.onDisable,
  });

  final PolicyRule rule;
  final List<Member> members;
  final Future<void> Function(int ruleId) onDisable;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final sentence = describeRule(
      memberId: rule.memberId,
      role: rule.role,
      actionPattern: rule.actionPattern,
      effect: rule.effect,
      requiredTier: rule.requiredTier,
      argConditionsJson: rule.argConditions,
      members: members,
    );
    final deny = rule.effect == PolicyEffect.deny;
    return AnimatedOpacity(
      duration: VMotion.of(context, VMotion.fast),
      opacity: rule.enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VSpace.s4,
          vertical: VSpace.s3,
        ),
        child: Row(
          children: [
            VIconBox(
              icon: deny ? VIcons.denied : VIcons.rules,
              tone: deny && rule.enabled ? c.bad : null,
            ),
            const SizedBox(width: VSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sentence,
                    style: VType.label.copyWith(color: c.textPrimary),
                  ),
                  if (rule.sourceText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '“${rule.sourceText}”',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VType.supporting.copyWith(
                        color: c.textDisabled,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: VSpace.s3),
            TierChip(tier: rule.requiredTier, dense: true),
            const SizedBox(width: VSpace.s2),
            rule.enabled
                ? TextButton(
                    onPressed: () => onDisable(rule.id!),
                    child: const Text('Disable'),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: VSpace.s3),
                    child: Text(
                      'Disabled',
                      style: VType.supporting.copyWith(color: c.textDisabled),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
