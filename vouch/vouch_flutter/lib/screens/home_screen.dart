import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../logic/approvals_controller.dart';
import '../logic/household_controller.dart';
import '../logic/friendly_error.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HouseholdController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.select<ApprovalsController?, int>(
      (c) => c?.pendingCount ?? 0,
    );
    return Consumer<HouseholdController>(
      builder: (context, controller, _) {
        if (controller.loading && controller.overview == null) {
          return const VPage(
            children: [
              _HeaderSkeleton(),
              _StatSkeleton(),
              SizedBox(height: VSpace.s8),
              VListSkeleton(rows: 4),
            ],
          );
        }
        if (controller.error != null && controller.overview == null) {
          return Center(
            child: VEmptyState(
              icon: VIcons.warn,
              title: 'Could not load household',
              body: friendlyError(
                controller.error!,
                what: 'load your household',
              ),
              action: OutlinedButton.icon(
                onPressed: controller.load,
                icon: const Icon(VIcons.retry),
                label: const Text('Try again'),
              ),
            ),
          );
        }
        final overview = controller.overview!;
        final names = {
          for (final m in overview.members)
            if (m.id != null) m.id!: m.displayName,
        };
        final events = controller.events;
        final blocked = events
            .where(
              (e) =>
                  e.decision == AuditDecision.denied ||
                  e.decision == AuditDecision.revoked,
            )
            .length;

        return VPage(
          onRefresh: controller.load,
          children: [
            FadeSlideIn(
              child: VPageHeader(
                title: householdDisplayName(overview.household.name),
                subtitle: overview.hubs.isEmpty
                    ? 'No hub registered yet'
                    : '${overview.hubs.length} hub${overview.hubs.length == 1 ? '' : 's'} · '
                          'last check-in ${_lastSeen(overview.hubs)}',
              ),
            ),
            _StatGrid(
              stats: [
                _Stat('Members', overview.members.length, VIcons.members),
                _Stat(
                  'Awaiting you',
                  pending,
                  VIcons.approvals,
                  tone: pending > 0 ? context.v.tier2 : null,
                ),
                _Stat('Decisions', events.length, VIcons.activity),
                _Stat(
                  'Blocked',
                  blocked,
                  VIcons.denied,
                  tone: blocked > 0 ? context.v.bad : null,
                ),
              ],
            ),
            const SizedBox(height: VSpace.s8),
            FadeSlideIn(
              index: 3,
              child: VSectionHeader('Members', count: overview.members.length),
            ),
            FadeSlideIn(
              index: 4,
              child: Wrap(
                spacing: VSpace.s2,
                runSpacing: VSpace.s2,
                children: [
                  for (final m in overview.members) _MemberPill(member: m),
                ],
              ),
            ),
            const SizedBox(height: VSpace.s8),
            FadeSlideIn(
              index: 5,
              child: VSectionHeader(
                'Live feed',
                count: events.length,
                trailing: _LiveTag(live: events.isNotEmpty),
              ),
            ),
            if (events.isEmpty)
              const VSurface(
                child: VEmptyState(
                  icon: VIcons.voice,
                  title: 'Nothing has happened yet',
                  body:
                      'When someone speaks to Alexa, you will see who it was, '
                      'what they asked and what Vouch decided.',
                ),
              )
            else
              FadeSlideIn(
                index: 6,
                child: VSurface(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < events.length; i++) ...[
                        if (i > 0) const Divider(indent: 60),
                        // Keyed per event: a new arrival animates in at the
                        // top while existing rows stay put.
                        FadeSlideIn(
                          key: ValueKey(
                            '${events[i].at.microsecondsSinceEpoch}-${events[i].kind.name}',
                          ),
                          offset: -6,
                          child: _FeedRow(event: events[i], memberNames: names),
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

  String _lastSeen(List<Hub> hubs) {
    final times = hubs.map((h) => h.lastSeen).whereType<DateTime>().toList();
    if (times.isEmpty) return 'never';
    times.sort();
    final r = vRelativeTime(times.last);
    return r == 'now' ? 'just now' : '$r ago';
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: VSpace.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 220, height: 28),
          SizedBox(height: VSpace.s3),
          Skeleton(width: 160, height: 12),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640 ? 4 : 2;
        const gap = VSpace.s3;
        final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < 4; i++)
              SizedBox(
                width: w,
                child: const VSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 70, height: 11),
                      SizedBox(height: VSpace.s3),
                      Skeleton(width: 40, height: 26),
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

class _Stat {
  const _Stat(this.label, this.value, this.icon, {this.tone});
  final String label;
  final int value;
  final IconData icon;
  final VTone? tone;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640 ? 4 : 2;
        const gap = VSpace.s3;
        final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < stats.length; i++)
              SizedBox(
                width: w,
                child: FadeSlideIn(
                  index: i,
                  child: _StatTile(stat: stats[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final tone = stat.tone;
    return VSurface(
      padding: const EdgeInsets.fromLTRB(
        VSpace.s4,
        VSpace.s3,
        VSpace.s4,
        VSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VType.supporting.copyWith(color: c.textSecondary),
                ),
              ),
              Icon(
                stat.icon,
                size: VSize.iconXs + 2,
                color: tone?.fg ?? c.textDisabled,
              ),
            ],
          ),
          const SizedBox(height: VSpace.s2),
          CountUp(
            value: stat.value,
            style: VType.metric.copyWith(color: tone?.text ?? c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  const _MemberPill({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        VSpace.s1,
        VSpace.s1,
        VSpace.s3,
        VSpace.s1,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: VRadius.fullR,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VAvatar(name: member.displayName, size: 26),
          const SizedBox(width: VSpace.s2),
          Text(
            member.displayName,
            style: VType.label.copyWith(color: c.textPrimary),
          ),
          const SizedBox(width: VSpace.s1_5),
          Text(
            member.role.name,
            style: VType.supporting.copyWith(color: c.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _LiveTag extends StatelessWidget {
  const _LiveTag({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseDot(color: live ? c.success : c.t0, live: live, size: 6),
        const SizedBox(width: VSpace.s2),
        Text('Streaming', style: VType.codeSm.copyWith(color: c.textSecondary)),
      ],
    );
  }
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({required this.event, required this.memberNames});

  final HouseholdEvent event;
  final Map<int, String> memberNames;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final (icon, tone) = _glyph(context, event);
    final blocked =
        event.decision == AuditDecision.denied ||
        event.decision == AuditDecision.revoked;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VSpace.s4,
        vertical: VSpace.s3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VIconBox(icon: icon, tone: tone, size: VSize.elementMd),
          const SizedBox(width: VSpace.s3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                describeHouseholdEvent(event, memberNames),
                style: VType.body.copyWith(
                  color: blocked ? c.errorText : c.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: VSpace.s3),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TierChip(tier: _tierOf(event), dense: true),
                const SizedBox(width: VSpace.s2),
                Tooltip(
                  message: vFullStamp(event.at),
                  child: SizedBox(
                    width: 28,
                    child: Text(
                      vRelativeTime(event.at),
                      textAlign: TextAlign.right,
                      style: VType.codeSm.copyWith(color: c.textDisabled),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Approval events are, by definition, about a step-up: show the tier the
  /// action needed (owner approves), not the speaker's voice tier.
  static TrustTier? _tierOf(HouseholdEvent e) =>
      e.kind == HouseholdEventKind.approvalPending ||
          e.kind == HouseholdEventKind.approvalDecided ||
          e.decision == AuditDecision.challenged
      ? TrustTier.t2
      : e.tierPresent;

  static (IconData, VTone?) _glyph(BuildContext context, HouseholdEvent e) {
    final c = context.v;
    return switch (e.kind) {
      HouseholdEventKind.attestationAccepted => (VIcons.recognised, c.ok),
      HouseholdEventKind.attestationRejected => (VIcons.unrecognised, c.bad),
      HouseholdEventKind.approvalPending => (VIcons.pending, c.tier2),
      HouseholdEventKind.approvalDecided => (VIcons.approvals, null),
      HouseholdEventKind.decision => switch (e.decision) {
        AuditDecision.permitted => (VIcons.ok, null),
        AuditDecision.denied || AuditDecision.revoked => (VIcons.denied, c.bad),
        AuditDecision.challenged => (VIcons.lock, c.tier2),
        null => (VIcons.activity, null),
      },
    };
  }
}

/// Turns a raw [HouseholdEvent] (kind + memberId + action + decision +
/// reason) into a single human sentence for the Home feed, e.g. "Ana
/// couldn't place an order: over the household limit of EUR 10", rather
/// than exposing raw event kinds/enum names.
String describeHouseholdEvent(HouseholdEvent e, Map<int, String> memberNames) {
  final who = e.memberId != null
      ? (memberNames[e.memberId] ?? 'A member')
      : 'An unrecognised speaker';
  final action = e.action == null ? null : humanAction(e.action!);
  // Internal row ids ("approval 42") mean nothing to a household.
  final reason = e.reason.replaceAll(
    RegExp(r'\s*\((approval|attestation) \d+\)'),
    '',
  );

  // Administrative events name a member without that member doing
  // anything; describing them as the member's own action would be false
  // (a rule about Ana is not "Ana was allowed to place an order").
  switch (e.eventType) {
    case 'policy.rule_created':
      return e.memberId != null
          ? 'New rule for $who: ${action ?? 'an action'}'
          : 'New household rule: ${action ?? 'an action'}';
    case 'member.revoke':
      return "$who's voice trust was revoked";
    case 'member.restore':
      return "$who's voice trust was restored";
    case 'pairing.redeem':
      return e.decision == AuditDecision.permitted
          ? 'A device was paired with the household'
          : 'A pairing attempt was rejected';
  }

  switch (e.kind) {
    case HouseholdEventKind.attestationAccepted:
      return e.transcript != null && e.transcript!.isNotEmpty
          ? '$who was recognised speaking: "${e.transcript}"'
          : '$who was recognised speaking.';

    case HouseholdEventKind.attestationRejected:
      return e.memberId != null
          ? "$who's voice could not be verified ($reason)"
          : 'A voice could not be verified ($reason)';

    case HouseholdEventKind.decision:
      final what = action ?? 'take an action';
      final why = _denialReason(reason);
      final suffix = why.isEmpty ? '' : ': $why';
      return switch (e.decision) {
        AuditDecision.permitted => '$who was allowed to $what',
        AuditDecision.denied => "$who couldn't $what$suffix",
        AuditDecision.revoked => "$who couldn't $what: voice trust is revoked",
        AuditDecision.challenged => '$who needs approval to $what',
        null => '$who tried to $what',
      };

    case HouseholdEventKind.approvalPending:
      return "$who asked to ${action ?? 'take an action'} — waiting for the owner's approval";

    case HouseholdEventKind.approvalDecided:
      // memberId is the owner who decided (AuditService: approval.decide).
      return "$who decided a request to ${action ?? 'take an action'}: $reason";
  }
}

/// A policy denial reason without the engine's boilerplate: "Denied: exceeds
/// household limit of EUR 10" -> "over the household limit of EUR 10";
/// "Denied by policy rule for place_order (Children may not order)" ->
/// "Children may not order".
String _denialReason(String reason) {
  var r = reason.trim();
  if (r.toLowerCase() == 'speaker not recognised') return '';
  final limit = RegExp(
    r'exceeds household limit of (.+)$',
    caseSensitive: false,
  ).firstMatch(r);
  if (limit != null) return 'over the household limit of ${limit[1]}';
  final rule = RegExp(
    r'^Denied by policy rule for\s+"?[^"(]*"?\s*(?:\((.*)\))?$',
    caseSensitive: false,
  ).firstMatch(r);
  if (rule != null) {
    final src = rule[1]?.trim();
    return src == null || src.isEmpty ? 'a household rule says no' : src;
  }
  r = r.replaceFirst(RegExp(r'^Denied:\s*', caseSensitive: false), '');
  return r.isEmpty ? r : r[0].toLowerCase() + r.substring(1);
}
