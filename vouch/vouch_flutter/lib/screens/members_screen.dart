import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../data/demo_session.dart';
import '../logic/household_controller.dart';
import '../logic/members_controller.dart';
import '../logic/friendly_error.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembersController>().load();
    });
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    MembersController controller,
    Member member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke voice trust?'),
        content: Text(
          "${member.displayName}'s voice will no longer be accepted for any "
          'command, effective immediately. Their last few seconds of voice '
          'trust are also withdrawn, so nothing already spoken can slip '
          'through. You can restore them at any time.',
        ),
        actions: [
          TextButton(
            key: const Key('revoke-cancel-button'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('revoke-confirm-button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await controller.revokeMember(member);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            friendlyError(e, what: 'revoke ${member.displayName}'),
          ),
        ),
      );
    }
  }

  Future<void> _restore(
    BuildContext context,
    MembersController controller,
    Member member,
  ) async {
    try {
      await controller.restoreMember(member);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            friendlyError(e, what: 'restore ${member.displayName}'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Last time each member's voice was accepted, from the household feed.
    final lastHeard = <int, DateTime>{};
    for (final e
        in context.watch<HouseholdController?>()?.events ??
            const <HouseholdEvent>[]) {
      final id = e.memberId;
      if (id == null || e.kind != HouseholdEventKind.attestationAccepted) {
        continue;
      }
      final prev = lastHeard[id];
      if (prev == null || e.at.isAfter(prev)) lastHeard[id] = e.at;
    }
    return Consumer<MembersController>(
      builder: (context, controller, _) {
        return VPage(
          onRefresh: controller.load,
          children: [
            const FadeSlideIn(
              child: VPageHeader(
                title: 'Members',
                subtitle:
                    'Voiceprints stay on the hub. The server only knows how good '
                    'each enrolment is, never what it sounds like.',
              ),
            ),
            if (controller.loading)
              const _MembersSkeleton()
            else if (controller.members.isEmpty)
              const VSurface(
                child: VEmptyState(
                  icon: VIcons.members,
                  title: 'No members yet',
                  body: 'Enrol people from the hub and they will appear here.',
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 720 ? 2 : 1;
                  const gap = VSpace.s3;
                  final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var i = 0; i < controller.members.length; i++)
                        SizedBox(
                          width: w,
                          child: FadeSlideIn(
                            index: i,
                            child: _MemberCard(
                              member: controller.members[i],
                              enrolment:
                                  controller.enrolmentByMemberId[controller
                                      .members[i]
                                      .id],
                              lastHeard: lastHeard[controller.members[i].id],
                              busy: controller.pendingMemberIds.contains(
                                controller.members[i].id,
                              ),
                              onRevoke: () => _confirmRevoke(
                                context,
                                controller,
                                controller.members[i],
                              ),
                              onRestore: () => _restore(
                                context,
                                controller,
                                controller.members[i],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// "Owner · Active · last heard 2 min ago": role, status and recency, only from data we actually have.
String _info(Member member, DateTime? lastHeard) {
  final parts = [
    _capitalise(member.role.name),
    _capitalise(member.status.name),
    if (lastHeard != null) 'last heard ${vAgo(lastHeard)}',
  ];
  return parts.join(' · ');
}

class _MembersSkeleton extends StatelessWidget {
  const _MembersSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: VSpace.s3),
            child: VSurface(
              padding: EdgeInsets.all(VSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Skeleton(width: 40, height: 40, radius: VRadius.full),
                      SizedBox(width: VSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(width: 120, height: 16),
                            SizedBox(height: VSpace.s2),
                            Skeleton(width: 200, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: VSpace.s4),
                  Skeleton(height: 6),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.enrolment,
    required this.busy,
    this.lastHeard,
    required this.onRevoke,
    required this.onRestore,
  });

  final Member member;
  final Enrolment? enrolment;

  /// When this member's voice was last accepted, if the feed has seen it.
  final DateTime? lastHeard;

  /// True while a revoke/restore call for this member is in flight.
  final bool busy;
  final VoidCallback onRevoke;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final revoked = enrolment?.revokedAt != null;
    final enrolled = enrolment != null && !revoked;
    final active = member.status == MemberStatus.active;
    // Distinct from `revoked` above (enrolment quality gone, re-enrol on the
    // hub): this is the owner's own "cut this person off now" action.
    final trustRevoked = member.status == MemberStatus.revoked;
    final isOwner = member.role == MemberRole.owner;

    // The no-hub demo household has no hub to enrol on: the app signs its
    // attestations itself, so Priya and Ana are recognised by design. Say
    // that rather than "Not enrolled" (real households are unchanged).
    final demoVoice = enrolment == null && DemoSession.current != null;
    final (statusLabel, statusTone, statusIcon) = demoVoice
        ? ('Demo voice', trustRevoked ? c.neutral : c.ok, VIcons.voice)
        : enrolment == null
        ? ('Not enrolled', c.neutral, VIcons.unrecognised)
        : revoked
        ? ('Enrolment revoked', c.bad, VIcons.disable)
        : ('Voice enrolled', c.ok, VIcons.voice);

    return VSurface(
      padding: const EdgeInsets.all(VSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VAvatar(
                name: member.displayName,
                size: 40,
                ring: (enrolled || demoVoice) && !trustRevoked
                    ? c.success
                    : null,
              ),
              const SizedBox(width: VSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VType.h4.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        PulseDot(color: active ? c.success : c.t0, size: 5),
                        const SizedBox(width: VSpace.s1_5),
                        Flexible(
                          child: Text(
                            _info(member, lastHeard),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: VType.supporting.copyWith(
                              color: c.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: demoVoice
                    ? 'Demo household: voices are simulated in this browser; '
                          'real households verify on the hub'
                    : statusLabel,
                child: VBadge(
                  label: statusLabel,
                  tone: statusTone,
                  icon: statusIcon,
                ),
              ),
            ],
          ),
          const SizedBox(height: VSpace.s4),
          if (enrolled) ...[
            Row(
              children: [
                Text(
                  'Quality',
                  style: VType.supporting.copyWith(color: c.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${(enrolment!.qualityScore * 100).toStringAsFixed(0)}%',
                  style: VType.codeSm.copyWith(color: c.textPrimary),
                ),
                Text(
                  '  ·  ${enrolment!.sampleCount} samples',
                  style: VType.codeSm.copyWith(color: c.textDisabled),
                ),
              ],
            ),
            const SizedBox(height: VSpace.s2),
            VMeter(
              value: enrolment!.qualityScore,
              color: enrolment!.qualityScore >= 0.8
                  ? c.success
                  : enrolment!.qualityScore >= 0.6
                  ? c.t2
                  : c.error,
            ),
          ] else
            Text(
              revoked
                  ? 'This voice is no longer accepted. Re-enrol on the hub to restore it.'
                  : demoVoice
                  ? 'Demo household: this voice is simulated by the app, no hub '
                        'enrolment needed.'
                  : 'Run enrolment on the hub so Vouch can recognise this voice.',
              style: VType.supporting.copyWith(color: c.textSecondary),
            ),
          if (!isOwner) ...[
            const SizedBox(height: VSpace.s4),
            if (trustRevoked)
              Row(
                children: [
                  Icon(VIcons.disable, size: 16, color: c.error),
                  const SizedBox(width: VSpace.s1_5),
                  Expanded(
                    child: Text(
                      'Voice trust revoked — no command from '
                      '${member.displayName} will be accepted.',
                      style: VType.supporting.copyWith(color: c.error),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: VSpace.s2),
            Align(
              alignment: Alignment.centerRight,
              child: trustRevoked
                  ? OutlinedButton.icon(
                      key: Key('restore-member-button-${member.id}'),
                      onPressed: busy ? null : onRestore,
                      icon: const Icon(VIcons.check),
                      label: Text(busy ? 'Restoring…' : 'Restore'),
                    )
                  : OutlinedButton.icon(
                      key: Key('revoke-member-button-${member.id}'),
                      onPressed: busy ? null : onRevoke,
                      icon: const Icon(VIcons.disable),
                      label: Text(busy ? 'Revoking…' : 'Revoke trust'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.error,
                        side: BorderSide(color: c.error),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
