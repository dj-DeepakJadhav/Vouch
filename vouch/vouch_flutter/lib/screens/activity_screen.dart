import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../logic/audit_controller.dart';
import '../logic/household_controller.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final names = {
      for (final m
          in context.watch<HouseholdController?>()?.overview?.members ??
              const <Member>[])
        if (m.id != null) m.id!: m.displayName,
    };
    return Consumer<AuditController>(
      builder: (context, controller, _) {
        final events = controller.sorted;
        return VPage(
          onRefresh: controller.load,
          children: [
            FadeSlideIn(
              child: VPageHeader(
                title: 'Activity',
                subtitle:
                    'Every decision the guard made, append-only. Nothing here can be edited or deleted.',
                trailing: MediaQuery.sizeOf(context).width >= 600
                    ? VBadge(
                        label: 'GDPR Art. 30',
                        tone: c.neutral,
                        icon: VIcons.lock,
                        mono: true,
                      )
                    : null,
              ),
            ),
            const FadeSlideIn(index: 1, child: TierLegend()),
            const SizedBox(height: VSpace.s4),
            FadeSlideIn(
              index: 1,
              child: VSurface(
                padding: const EdgeInsets.fromLTRB(
                  VSpace.s4,
                  VSpace.s1,
                  VSpace.s2,
                  VSpace.s1,
                ),
                child: Row(
                  children: [
                    Icon(
                      VIcons.filter,
                      size: VSize.iconSm,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: VSpace.s3),
                    Expanded(
                      child: Text(
                        'Blocked / denied first',
                        overflow: TextOverflow.ellipsis,
                        style: VType.label.copyWith(color: c.textPrimary),
                      ),
                    ),
                    Switch(
                      key: const Key('blocked-first-switch'),
                      value: controller.blockedOnlyFirst,
                      onChanged: (_) => controller.toggleBlockedFirst(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: VSpace.s6),
            VSectionHeader(
              'Log',
              count: controller.loading ? null : events.length,
            ),
            if (controller.loading)
              const VListSkeleton(rows: 5)
            else if (events.isEmpty)
              const VSurface(
                child: VEmptyState(
                  icon: VIcons.activity,
                  title: 'No activity yet',
                  body:
                      'Decisions appear here the moment the guard makes them.',
                ),
              )
            else
              FadeSlideIn(
                index: 2,
                child: VSurface(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < events.length; i++) ...[
                        if (i > 0) const Divider(),
                        _AuditRow(
                          key: ValueKey('audit-${events[i].id ?? i}'),
                          event: events[i],
                          memberNames: names,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AuditRow extends StatefulWidget {
  const _AuditRow({
    super.key,
    required this.event,
    this.memberNames = const {},
  });

  final AuditEvent event;
  final Map<int, String> memberNames;

  @override
  State<_AuditRow> createState() => _AuditRowState();
}

class _AuditRowState extends State<_AuditRow> {
  bool _expanded = false;

  bool get _blocked =>
      widget.event.decision == AuditDecision.denied ||
      widget.event.decision == AuditDecision.revoked;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final e = widget.event;
    final (icon, tone) = switch (e.decision) {
      AuditDecision.permitted => (VIcons.ok, c.ok),
      AuditDecision.denied => (VIcons.denied, c.bad),
      AuditDecision.revoked => (VIcons.disable, c.bad),
      AuditDecision.challenged => (VIcons.lock, c.tier2),
    };
    final d = VMotion.of(context, VMotion.fastMax);

    final header = Pressable(
      key: Key('audit-row-${e.id}'),
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.zero,
      scale: false,
      semanticLabel:
          '${describeAuditEvent(e, widget.memberNames)}. ${_expanded ? 'Collapse' : 'Expand'} details',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VSpace.s4,
          vertical: VSpace.s3,
        ),
        child: Row(
          children: [
            VIconBox(
              icon: icon,
              tone: _blocked ? tone : null,
              size: VSize.elementMd,
            ),
            const SizedBox(width: VSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    describeAuditEvent(e, widget.memberNames),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: VType.body.copyWith(
                      color: _blocked ? c.errorText : c.textPrimary,
                    ),
                  ),
                  Tooltip(
                    message: vFullStamp(e.createdAt),
                    child: Text(
                      vAgo(e.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VType.supporting.copyWith(
                        color: c.textDisabled,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: VSpace.s2),
            TierChip(tier: e.tierPresent, dense: true),
            const SizedBox(width: VSpace.s2),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: d,
              curve: VMotion.standard,
              child: Icon(
                VIcons.expand,
                size: VSize.iconSm,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    final details = Padding(
      key: Key('audit-why-${e.id}'),
      padding: const EdgeInsets.fromLTRB(60, 0, VSpace.s4, VSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why', style: VType.eyebrow.copyWith(color: c.textDisabled)),
              const SizedBox(width: VSpace.s3),
              Expanded(
                child: Text(
                  e.reason,
                  style: VType.body.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: VSpace.s3),
          Wrap(
            spacing: VSpace.s1_5,
            runSpacing: VSpace.s1_5,
            children: [
              _Fact(
                'Needed: ${e.tierRequired == null ? "n/a" : tierLabel(e.tierRequired)}',
              ),
              _Fact(
                'Had: ${e.tierPresent == null ? "none" : tierLabel(e.tierPresent)}',
              ),
              if (e.confidence != null)
                _Fact(
                  'Confidence: ${(e.confidence! * 100).toStringAsFixed(0)}%',
                ),
            ],
          ),
        ],
      ),
    );

    final row = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        AnimatedSize(
          duration: VMotion.of(context, VMotion.mediumMin),
          curve: VMotion.standard,
          alignment: Alignment.topCenter,
          child: _expanded
              ? FadeSlideIn(offset: -4, child: details)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
    if (!_blocked) return row;
    // Quiet denial: a thin red rail on the leading edge, overlaid so blocked
    // rows keep the same alignment as their neighbours.
    return Stack(
      children: [
        row,
        Positioned(
          left: 0,
          top: VSpace.s3,
          bottom: VSpace.s3,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: c.error,
              borderRadius: VRadius.fullR,
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VSpace.s2, vertical: 3),
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: VRadius.innerR,
        border: Border.all(color: c.border),
      ),
      child: Text(text, style: VType.codeSm.copyWith(color: c.textSecondary)),
    );
  }
}

/// One plain sentence for an audit row, e.g. "Hub confirmed Ana's voice for
/// one command" or "Ana was allowed to add to the shopping list". Names come
/// from [memberNames]; unknown speakers read as "Someone".
String describeAuditEvent(AuditEvent e, Map<int, String> memberNames) {
  final name = e.memberId != null ? memberNames[e.memberId] : null;
  final who = name ?? (e.memberId != null ? 'A member' : 'Someone');
  final poss = name != null ? "$name's" : 'a';
  final ok = e.decision == AuditDecision.permitted;
  final act = humanAction(e.action);
  switch (e.eventType) {
    case 'attestation.submit':
      return ok
          ? 'Hub confirmed $poss voice for one command'
          : 'Hub could not confirm who was speaking';
    case 'attestation.consume':
      return ok
          ? "Alexa's command was matched to $poss voice"
          : "Alexa's command did not match a confirmed voice";
    case 'attestation.expire':
      return 'A voice confirmation for $who expired unused';
    case 'member.revoke':
      return "${name ?? 'A member'}'s voice trust was revoked";
    case 'member.restore':
      return "${name ?? 'A member'}'s voice trust was restored";
    case 'pairing.redeem':
      return ok
          ? 'The owner paired this app with the household'
          : 'A pairing code was rejected';
    case 'policy.rule_created':
      return 'A new household rule was saved';
    case 'approval.decide':
      return '$who decided a request to $act';
  }
  return switch (e.decision) {
    AuditDecision.permitted => '$who was allowed to $act',
    AuditDecision.denied => '$who was blocked from trying to $act',
    AuditDecision.challenged => "$who needs the owner's approval to $act",
    AuditDecision.revoked =>
      '$who was blocked from trying to $act: voice trust revoked',
  };
}
