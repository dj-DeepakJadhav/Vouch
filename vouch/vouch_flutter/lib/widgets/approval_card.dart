import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';

/// A single pending (or just-decided) step-up approval. Pure presentation
/// + a countdown timer — no direct repository access — so it's easily
/// widget-tested with a plain [Approval] fixture (VOUCH task D2 item 10).
class ApprovalCard extends StatefulWidget {
  const ApprovalCard({
    super.key,
    required this.approval,
    required this.memberName,
    this.confidence,
    required this.onApprove,
    required this.onDeny,
  });

  final Approval approval;

  /// The speaking member's display name, or null/"unrecognised" if the
  /// speaker could not be attested.
  final String? memberName;

  /// The attestation confidence for the speaker who triggered this step-up,
  /// 0..1, if known — from [Approval.speakerConfidence], set by the MCP
  /// guard from the attestation consumed when the step-up was created.
  /// `null` when the speaker was unrecognised.
  final double? confidence;

  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  State<ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends State<ApprovalCard> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recompute();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
  }

  void _recompute() {
    final now = DateTime.now().toUtc();
    final remaining = widget.approval.expiresAt.difference(now);
    if (!mounted) return;
    setState(
      () => _remaining = remaining.isNegative ? Duration.zero : remaining,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get _args {
    try {
      return (jsonDecode(widget.approval.argsJson) as Map)
          .cast<String, dynamic>();
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final a = widget.approval;
    final pending = a.status == ApprovalStatus.pending;
    final who = widget.memberName ?? 'unrecognised speaker';
    final recognised = widget.memberName != null;
    // The hub heard something close to, but not the same as, the text Alexa
    // sent: the speaker is plausible but NOT bound to this command.
    final wordingDiffered = a.transcriptMatch == 'near_miss';
    final confidence = widget.confidence;
    final totalWindow = a.expiresAt.difference(a.createdAt).inSeconds;
    final fraction = totalWindow <= 0
        ? 0.0
        : (_remaining.inMilliseconds / (totalWindow * 1000)).clamp(0.0, 1.0);
    final urgent = pending && _remaining.inSeconds <= 15;
    // The server rejects a decision after expiresAt; don't offer one.
    final lapsed = pending && _remaining == Duration.zero;

    return Padding(
      key: Key('approval-card-${a.id}'),
      padding: const EdgeInsets.only(bottom: VSpace.s3),
      child: VSurface(
        emphasized: pending,
        accent: pending ? c.t2 : null,
        padding: const EdgeInsets.all(VSpace.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VAvatar(
                  name: recognised ? who : '?',
                  size: VSize.elementLg + 4,
                  ring: recognised ? c.success : c.error,
                ),
                const SizedBox(width: VSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$who wants to ${humanAction(a.action)}',
                        style: VType.h3.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: VSpace.s1),
                      _SpeakerLine(
                        recognised: recognised,
                        who: who,
                        confidence: confidence,
                        wordingDiffered: wordingDiffered,
                      ),
                      const SizedBox(height: VSpace.s2),
                      const TierChip(tier: TrustTier.t2, dense: true),
                    ],
                  ),
                ),
                const SizedBox(width: VSpace.s3),
                if (pending)
                  _CountdownRing(
                    key: const Key('countdown-bar'),
                    fraction: fraction,
                    seconds: _remaining.inSeconds,
                    urgent: urgent,
                  )
              ],
            ),
            const SizedBox(height: VSpace.s4),
            // What was actually said, as the hub transcribed it.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: VSpace.s3,
                vertical: VSpace.s2 + 2,
              ),
              decoration: BoxDecoration(
                color: c.muted,
                borderRadius: VRadius.elementR,
                border: Border.all(color: c.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      VIcons.voice,
                      size: VSize.iconSm,
                      color: c.textDisabled,
                    ),
                  ),
                  const SizedBox(width: VSpace.s2),
                  Expanded(
                    child: Text(
                      '"${a.utterance}"',
                      style: VType.body.copyWith(
                        color: c.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (wordingDiffered) ...[
              const SizedBox(height: VSpace.s3),
              WordingNotice(
                heard: a.heardTranscript,
                alexaSent: a.utterance,
              ),
            ],
            if (_args.isNotEmpty) ...[
              const SizedBox(height: VSpace.s3),
              Wrap(
                spacing: VSpace.s1_5,
                runSpacing: VSpace.s1_5,
                children: [
                  for (final entry in _args.entries)
                    _ArgChip(k: entry.key, v: '${entry.value}'),
                ],
              ),
            ],
            const SizedBox(height: VSpace.s4),
            AnimatedSwitcher(
              duration: VMotion.of(context, VMotion.mediumMin),
              switchInCurve: VMotion.standard,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SizeTransition(
                  sizeFactor: anim,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: pending
                  ? Row(
                      key: const ValueKey('actions'),
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('approve-button'),
                            onPressed: lapsed ? null : widget.onApprove,
                            icon: const Icon(VIcons.check),
                            label: Text(lapsed ? 'Expired' : 'Approve'),
                          ),
                        ),
                        const SizedBox(width: VSpace.s3),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('deny-button'),
                            onPressed: lapsed ? null : widget.onDeny,
                            icon: const Icon(VIcons.close),
                            label: const Text('Deny'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: c.errorText,
                            ),
                          ),
                        ),
                      ],
                    )
                  : KeyedSubtree(
                      key: ValueKey(a.status),
                      child: _DecidedBadge(status: a.status),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Amber notice shown when Alexa's text differed from what the hub heard
/// (`Approval.transcriptMatch == 'near_miss'`). Public so the Alexa tab's
/// inline owner's-phone card shows the identical wording.
class WordingNotice extends StatelessWidget {
  const WordingNotice({
    super.key,
    required this.heard,
    required this.alexaSent,
  });

  final String? heard;
  final String alexaSent;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final tone = c.tier2;
    return Container(
      key: const Key('wording-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(VSpace.s3),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: VRadius.elementR,
        border: Border.all(color: tone.fg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(VIcons.unrecognised, size: VSize.iconSm, color: tone.fg),
          const SizedBox(width: VSpace.s2),
          Expanded(
            child: Text(
              "Alexa's wording differed from what the hub heard, so this "
              'command was not verified as spoken. '
              "Heard: '${heard ?? '—'}'. Alexa sent: '$alexaSent'.",
              style: VType.supporting.copyWith(color: tone.text, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakerLine extends StatelessWidget {
  const _SpeakerLine({
    required this.recognised,
    required this.who,
    required this.confidence,
    this.wordingDiffered = false,
  });

  final bool recognised;
  final String who;
  final double? confidence;
  final bool wordingDiffered;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final tone = !recognised ? c.bad : (wordingDiffered ? c.tier2 : c.ok);
    return Row(
      children: [
        Icon(
          recognised ? VIcons.recognised : VIcons.unrecognised,
          size: VSize.iconXs + 1,
          color: tone.fg,
        ),
        const SizedBox(width: VSpace.s1_5),
        Flexible(
          child: Text(
            recognised
                ? '${wordingDiffered ? 'Voice resembles' : 'Recognised'}: $who'
                      '${confidence != null ? ' · ${(confidence! * 100).round()}% confidence' : ''}'
                      '${wordingDiffered ? ' · wording differs' : ''}'
                : 'Speaker not recognised',
            style: VType.supporting.copyWith(color: tone.text, height: 1.3),
          ),
        ),
        if (recognised && confidence != null) ...[
          const SizedBox(width: VSpace.s2),
          SizedBox(
            width: 40,
            child: VMeter(value: confidence!, color: tone.fg, height: 3),
          ),
        ],
      ],
    );
  }
}

class _ArgChip extends StatelessWidget {
  const _ArgChip({required this.k, required this.v});

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VSpace.s2, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: VRadius.innerR,
        border: Border.all(color: c.border),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$k: ',
              style: TextStyle(color: c.textDisabled),
            ),
            TextSpan(
              text: v,
              style: TextStyle(color: c.textPrimary),
            ),
          ],
        ),
        style: VType.codeSm,
      ),
    );
  }
}

/// Time left to decide, as a ring that drains. It turns red in the last 15s.
/// The remaining seconds sit in the middle in mono.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    super.key,
    required this.fraction,
    required this.seconds,
    required this.urgent,
  });

  final double fraction;
  final int seconds;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final color = urgent ? c.error : c.t2;
    final label = seconds >= 60 ? '${seconds ~/ 60}m' : '${seconds}s';
    return Tooltip(
      message: '$seconds seconds left to decide',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fraction),
        duration: VMotion.of(context, const Duration(milliseconds: 950)),
        curve: Curves.linear,
        builder: (context, f, _) => SizedBox.square(
          dimension: 44,
          child: CustomPaint(
            painter: _RingPainter(fraction: f, color: color, track: c.track),
            child: Center(
              child: Text(
                label,
                style: VType.codeSm.copyWith(
                  color: urgent ? c.errorText : c.t2Text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
  });

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.5;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}

class _DecidedBadge extends StatelessWidget {
  const _DecidedBadge({required this.status});

  final ApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final (label, tone, icon) = switch (status) {
      ApprovalStatus.approved => (
        'Approved. Alexa will continue',
        c.ok,
        VIcons.ok,
      ),
      ApprovalStatus.denied => ('Denied', c.bad, VIcons.denied),
      ApprovalStatus.expired => ('Expired', c.neutral, VIcons.clock),
      ApprovalStatus.pending => ('Pending', c.tier2, VIcons.pending),
    };
    return Row(
      children: [
        Icon(icon, size: VSize.iconSm, color: tone.fg),
        const SizedBox(width: VSpace.s2),
        Text(
          label,
          style: VType.label.copyWith(
            color: tone.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
