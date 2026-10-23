import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'verdict_model.dart';

/// Colours for a verdict kind: green allowed, red blocked, amber waiting.
VTone verdictTone(BuildContext context, VerdictKind kind) {
  final c = context.v;
  return switch (kind) {
    VerdictKind.allowed => c.ok,
    VerdictKind.blocked || VerdictKind.error => c.bad,
    VerdictKind.waiting => c.tier2,
    _ => c.neutral,
  };
}

/// The one big answer: a plain sentence on a tinted panel, with the server's
/// precise reason as a small secondary line.
class VerdictPanel extends StatelessWidget {
  const VerdictPanel({super.key, required this.verdict});

  final AlexaVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final tone = verdictTone(context, verdict.kind);
    final icon = switch (verdict.kind) {
      VerdictKind.allowed => VIcons.ok,
      VerdictKind.blocked || VerdictKind.error => VIcons.fail,
      VerdictKind.waiting => VIcons.pending,
      _ => VIcons.privacy,
    };
    final label = switch (verdict.kind) {
      VerdictKind.allowed => 'ALLOWED',
      VerdictKind.blocked => 'BLOCKED',
      VerdictKind.waiting => 'WAITING FOR OWNER',
      VerdictKind.deciding => 'DECIDING',
      VerdictKind.error => 'ERROR',
      VerdictKind.idle => 'VERDICT',
    };
    return AnimatedContainer(
      key: const Key('verdict-panel'),
      duration: VMotion.of(context, VMotion.medium),
      curve: VMotion.standard,
      padding: const EdgeInsets.all(VSpace.s5),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: VRadius.elementR,
        border: Border.all(color: tone.fg.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tone.fg, size: VSize.iconMd),
              const SizedBox(width: VSpace.s2),
              Text(label, style: VType.codeSm.copyWith(color: tone.text)),
            ],
          ),
          const SizedBox(height: VSpace.s3),
          Text(
            verdict.headline,
            key: const Key('verdict-headline'),
            style: VType.h2.copyWith(color: c.textPrimary),
          ),
          if (verdict.detail != null && verdict.detail!.isNotEmpty) ...[
            const SizedBox(height: VSpace.s2),
            Text(
              verdict.detail!,
              key: const Key('verdict-detail'),
              style: VType.supporting.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
