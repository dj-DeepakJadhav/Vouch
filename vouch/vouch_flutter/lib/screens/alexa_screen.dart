import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';
import '../data/demo_session.dart';
import '../data/mcp/mcp_gateway.dart';
import '../logic/alexa_controller.dart';
import '../logic/approvals_controller.dart';
import '../logic/household_controller.dart';
import '../widgets/approval_card.dart';
import 'approvals_screen.dart' show decideAndReport;
import '../widgets/hold_to_talk_button.dart';
import '../widgets/alexa/echo_ring.dart';
import '../widgets/alexa/verdict_model.dart';
import '../widgets/alexa/verdict_panel.dart';
import '../widgets/verdict_card_view.dart';
import '../logic/friendly_error.dart';

/// One-tap demo scenarios: who speaks, what the hub heard, and what Alexa+
/// sent. [heardByHub] differs from [says] only for the paraphrase case.
class _Scenario {
  const _Scenario(this.label, this.speaker, this.says, {this.heardByHub});
  final String label;
  final DemoSpeaker speaker;
  final String says;
  final String? heardByHub;
}

const _scenarios = [
  _Scenario(
    'TV orders a PlayStation',
    DemoSpeaker.tv,
    'Order the new PlayStation for 500 euros',
  ),
  _Scenario(
    'Ana orders a PlayStation',
    DemoSpeaker.child,
    'Order the new PlayStation for 500 euros',
  ),
  _Scenario(
    'Priya unlocks the door',
    DemoSpeaker.owner,
    'Unlock the front door',
  ),
  _Scenario(
    'Reworded command',
    DemoSpeaker.child,
    'Put chocolate on the shopping list',
    heardByHub: 'Add chocolate to the shopping list',
  ),
];

const _exampleUtterances = [
  'What\'s the weather?',
  'Add milk to the list',
  'Order the wireless headphones for 249 euros',
  'Unlock the front door',
];

/// A simulated Alexa+ surface: this is the Amazon demo. Types (or, in
/// "Follow hub" mode, replays) an utterance, sends it to the *real* MCP
/// endpoint, and renders a decision-trace panel with a tick/cross per step.
class AlexaScreen extends StatefulWidget {
  const AlexaScreen({super.key});

  @override
  State<AlexaScreen> createState() => _AlexaScreenState();
}

class _AlexaScreenState extends State<AlexaScreen> {
  final _textController = TextEditingController();
  Timer? _healthTimer;

  /// How often the hub hint re-checks `GET /health` while this tab is open.
  static const hubHealthInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<AlexaController>();
      controller.startFollowingHub();
      // A demo household has no hub: never probe 127.0.0.1:8765 (the
      // browser logs every refused connection as a console error).
      if (!controller.isDemo) {
        controller.checkHubHealth();
        _healthTimer = Timer.periodic(
          hubHealthInterval,
          (_) => controller.checkHubHealth(),
        );
      }
    });
    // Rebuild on every keystroke so the Send button's enabled state (which
    // reads _textController.text directly) stays in sync.
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  final _verdictKey = GlobalKey();
  String? _signature;

  /// On narrow screens the verdict sits under the (tall) device panel: bring
  /// it into view whenever a command starts or its outcome changes.
  void _maybeScroll(AlexaController c, bool narrow) {
    final sig = '${c.inFlight}|${c.lastVouch?['decision']}|${c.thread.length}';
    final first = _signature == null;
    if (sig == _signature) return;
    _signature = sig;
    if (first || !narrow) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _verdictKey.currentContext;
      if (!mounted || ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.02,
        duration: VMotion.of(context, VMotion.medium),
        curve: VMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlexaController>(
      builder: (context, controller, _) {
        final device = _DevicePanel(
          controller: controller,
          textController: _textController,
        );
        final verdict = KeyedSubtree(
          key: _verdictKey,
          child: VerdictPanel(verdict: controller.verdict),
        );
        final result = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            verdict,
            const SizedBox(height: VSpace.s4),
            const OwnerPhoneCard(),
            _TracePane(
              steps: controller.trace,
              vouch: controller.lastVouch,
              inFlight: controller.inFlight,
            ),
            VerdictCardView(
              html: controller.verdictCardHtml,
              vouch: controller.lastVouch,
            ),
          ],
        );

        return VPage(
          maxWidth: 1080,
          children: [
            const FadeSlideIn(
              child: VPageHeader(
                title: 'Alexa',
                subtitle: 'Speak as a family member and watch Vouch decide.',
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 860;
                _maybeScroll(controller, !wide);
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        child: FadeSlideIn(index: 1, child: device),
                      ),
                      const SizedBox(width: VSpace.s6),
                      Expanded(child: FadeSlideIn(index: 2, child: result)),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(index: 1, child: device),
                    const SizedBox(height: VSpace.s4),
                    result,
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

class _DevicePanel extends StatelessWidget {
  const _DevicePanel({required this.controller, required this.textController});

  final AlexaController controller;
  final TextEditingController textController;

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty || controller.inFlight) return;
    controller.sendUtterance(t);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final canSend =
        !controller.inFlight && textController.text.trim().isNotEmpty;
    return VSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The "device": an Echo-style light ring that sweeps while the
          // guard decides, with the conversation right under it.
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: VSpace.s4,
              horizontal: VSpace.s4,
            ),
            decoration: BoxDecoration(
              color: c.muted,
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: EchoRing(active: controller.inFlight, size: 116)),
                const SizedBox(height: VSpace.s1),
                Center(
                  child: AnimatedSwitcher(
                    duration: VMotion.of(context, VMotion.fast),
                    child: Text(
                      controller.inFlight
                          ? 'Deciding…'
                          : controller.followHub
                          ? 'Following the hub'
                          : 'Alexa+',
                      key: ValueKey(
                        '${controller.inFlight}-${controller.followHub}',
                      ),
                      style: VType.codeSm.copyWith(color: c.textSecondary),
                    ),
                  ),
                ),
                if (controller.thread.isNotEmpty) ...[
                  const SizedBox(height: VSpace.s3),
                  _ChatThread(turns: controller.thread),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(VSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.isDemo) ...[
                  Text(
                    "Who's speaking?",
                    style: VType.label.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: VSpace.s2),
                  _SpeakerPicker(controller: controller),
                  const SizedBox(height: VSpace.s3),
                  Text(
                    'Scenarios',
                    style: VType.label.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: VSpace.s2),
                  Wrap(
                    spacing: VSpace.s1_5,
                    runSpacing: VSpace.s1_5,
                    children: [
                      for (final sc in _scenarios)
                        _UtterancePill(
                          label: sc.label,
                          onTap: controller.inFlight
                              ? null
                              : () => controller.runScenario(
                                  sc.speaker,
                                  sc.says,
                                  heardByHub: sc.heardByHub,
                                ),
                        ),
                      if (controller.canReplayApprovedRequest)
                        _UtterancePill(
                          label: 'Replay the used approval',
                          onTap: controller.replayApprovedRequest,
                        ),
                    ],
                  ),
                  if (controller.canReplayApprovedRequest) ...[
                    const SizedBox(height: VSpace.s2),
                    Text(
                      'Test the same approved request again, without new '
                      'voice evidence. A used approval must be rejected.',
                      style: VType.label.copyWith(color: c.textSecondary),
                    ),
                  ],
                  const SizedBox(height: VSpace.s3),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        VIcons.hub,
                        size: VSize.iconSm,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: VSpace.s2),
                      Expanded(
                        child: Text(
                          'Follow hub',
                          style: VType.label.copyWith(color: c.textPrimary),
                        ),
                      ),
                      Switch(
                        key: const Key('follow-hub-switch'),
                        value: controller.followHub,
                        onChanged: controller.setFollowHub,
                      ),
                    ],
                  ),
                  const SizedBox(height: VSpace.s3),
                  Row(
                    children: [
                      Expanded(
                        child: HoldToTalkButton(
                          enabled: !controller.inFlight,
                          onRecorded: (bytes, mimeType) =>
                              controller.sendRecordedAudio(bytes, mimeType),
                        ),
                      ),
                    ],
                  ),
                  if (controller.hubHealthy == false) ...[
                    const SizedBox(height: VSpace.s2),
                    Text(
                      'Hub unreachable. Start it with: '
                      'cd hub && .venv/bin/python -m vouch_hub serve',
                      style: VType.supporting.copyWith(color: c.errorText),
                    ),
                  ],
                ],
                const SizedBox(height: VSpace.s3),
                TextField(
                  key: const Key('alexa-text-field'),
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Type what Alexa heard…',
                    prefixIcon: Icon(VIcons.voice, size: VSize.iconSm),
                  ),
                  onSubmitted: (v) => controller.sendUtterance(v),
                ),
                const SizedBox(height: VSpace.s3),
                Wrap(
                  spacing: VSpace.s1_5,
                  runSpacing: VSpace.s1_5,
                  children: [
                    for (final u in _exampleUtterances)
                      _UtterancePill(
                        label: u,
                        onTap: controller.inFlight
                            ? null
                            : () {
                                textController.text = u;
                                controller.sendUtterance(u);
                              },
                      ),
                  ],
                ),
                const SizedBox(height: VSpace.s4),
                FilledButton.icon(
                  onPressed: canSend ? () => _send(textController.text) : null,
                  icon: controller.inFlight
                      ? SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: c.textDisabled,
                          ),
                        )
                      : const Icon(VIcons.send),
                  label: const Text('Send to Alexa+'),
                ),
                if (controller.tokenError != null) ...[
                  const SizedBox(height: VSpace.s3),
                  VInlineError(
                    friendlyError(
                      controller.tokenError!,
                      what: 'connect the simulated Alexa',
                    ),
                  ),
                ],
                if (controller.statusMessage != null &&
                    controller.verdict.kind == VerdictKind.error) ...[
                  const SizedBox(height: VSpace.s3),
                  Text(
                    controller.statusMessage!,
                    style: VType.supporting.copyWith(color: c.textSecondary),
                  ),
                ],
                const SizedBox(height: VSpace.s3),
                Text(
                  'Simulated Alexa+ · Alexa sends Vouch text only; voices are '
                  'checked on the household hub',
                  key: const Key('alexa-caption'),
                  style: VType.supporting.copyWith(
                    color: c.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A one-tap speaker switch that flashes when a scenario chip changes it.
class _SpeakerPicker extends StatefulWidget {
  const _SpeakerPicker({required this.controller});
  final AlexaController controller;

  @override
  State<_SpeakerPicker> createState() => _SpeakerPickerState();
}

class _SpeakerPickerState extends State<_SpeakerPicker> {
  bool _flash = false;
  Timer? _timer;

  int _seen = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final controller = widget.controller;
    if (controller.speakerFlash != _seen) {
      _seen = controller.speakerFlash;
      _flash = true;
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) setState(() => _flash = false);
      });
    }
    const icons = {
      DemoSpeaker.owner: Icons.person_outline,
      DemoSpeaker.child: Icons.child_care,
      DemoSpeaker.tv: Icons.tv,
    };
    return AnimatedContainer(
      duration: VMotion.of(context, VMotion.medium),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: VRadius.elementR,
        color: _flash ? EchoRing.cyan.withValues(alpha: 0.16) : null,
        border: Border.all(
          color: _flash ? EchoRing.cyan : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: SegmentedButton<DemoSpeaker>(
        key: const Key('speaker-picker'),
        showSelectedIcon: false,
        segments: [
          for (final s in DemoSpeaker.values)
            ButtonSegment(
              value: s,
              icon: Icon(icons[s], size: VSize.iconSm),
              label: Text(
                controller.speakerLabel(s),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.textPrimary),
              ),
            ),
        ],
        selected: {controller.speaker},
        onSelectionChanged: controller.inFlight
            ? null
            : (v) => controller.setSpeaker(v.first),
      ),
    );
  }
}

/// The conversation so far, newest at the bottom: the speaker on the right,
/// Alexa+ on the left, so it reads like talking to Alexa+.
class _ChatThread extends StatelessWidget {
  const _ChatThread({required this.turns});

  final List<ChatTurn> turns;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final recent = turns.length > 4 ? turns.sublist(turns.length - 4) : turns;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          key: const Key('alexa-thread'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in recent)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: VSpace.s1),
                child: Align(
                  alignment: t.fromAlexa
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: VSpace.s3,
                      vertical: VSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: t.fromAlexa
                          ? (t.blocked
                                ? c.errorText.withValues(alpha: 0.12)
                                : t.waiting
                                ? c.t2.withValues(alpha: 0.14)
                                : EchoRing.cyan.withValues(alpha: 0.12))
                          : c.surfaceRaised,
                      borderRadius: VRadius.elementR,
                      border: Border.all(
                        color: t.blocked
                            ? c.errorText
                            : t.fromAlexa
                            ? EchoRing.cyan.withValues(alpha: 0.5)
                            : c.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: t.fromAlexa
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          t.who,
                          style: VType.codeSm.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.text,
                          style: VType.body.copyWith(color: c.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UtterancePill extends StatelessWidget {
  const _UtterancePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Pressable(
      onTap: onTap,
      borderRadius: VRadius.fullR,
      child: AnimatedOpacity(
        duration: VMotion.of(context, VMotion.fast),
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VSpace.s3,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: VRadius.fullR,
            border: Border.all(color: c.border),
          ),
          child: Text(
            label,
            style: VType.supporting.copyWith(
              color: c.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

/// The decision trace: three plain rows by default, the full timeline behind
/// "Show details". Steps arrive in order with a short stagger.
class _TracePane extends StatefulWidget {
  const _TracePane({
    required this.steps,
    required this.vouch,
    required this.inFlight,
  });

  final List<TraceStep> steps;
  final Map<String, dynamic>? vouch;
  final bool inFlight;

  @override
  State<_TracePane> createState() => _TracePaneState();
}

class _TracePaneState extends State<_TracePane> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final inFlight = widget.inFlight;
    if (steps.isEmpty) {
      return VSurface(
        child: VEmptyState(
          icon: VIcons.privacy,
          title: inFlight ? 'Waiting for the guard' : 'No command yet',
          body:
              'Pick a scenario or type a command. Vouch checks who spoke '
              'before Alexa+ acts.',
        ),
      );
    }
    final c = context.v;
    // The badge follows the final Result step, never an earlier red step.
    final result = steps.where((s) => s.label == 'Result');
    final status = result.isNotEmpty ? result.last.status : null;
    final (badge, tone) = inFlight && status == null
        ? ('running', c.neutral)
        : switch (status) {
            TraceStepStatus.ok => ('passed', c.ok),
            TraceStepStatus.pending => ('waiting', c.tier2),
            TraceStepStatus.fail => ('blocked', c.bad),
            _ => inFlight ? ('running', c.neutral) : ('blocked', c.bad),
          };
    final vouch = widget.vouch;
    final summary = vouch == null ? null : buildSummary(vouch);
    return VSurface(
      key: const Key('decision-trace-panel'),
      padding: const EdgeInsets.fromLTRB(
        VSpace.s5,
        VSpace.s4,
        VSpace.s5,
        VSpace.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const VEyebrow('Why'),
              const Spacer(),
              VBadge(label: badge, tone: tone, mono: true),
            ],
          ),
          const SizedBox(height: VSpace.s3),
          if (summary != null && !_expanded)
            for (final row in summary) _SummaryRowView(row: row),
          if (summary == null || _expanded)
            // Keyed per step: a step that arrives animates in; a step that
            // only changes status (pending -> ok) stays put and recolours.
            Column(
              key: const Key('trace-details'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < steps.length; i++)
                  FadeSlideIn(
                    key: ValueKey('$i-${steps[i].label}'),
                    index: i,
                    child: _TraceRow(
                      step: steps[i],
                      last: i == steps.length - 1,
                    ),
                  ),
              ],
            ),
          if (summary != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('trace-toggle'),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Hide details' : 'Show details'),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRowView extends StatelessWidget {
  const _SummaryRowView({required this.row});
  final SummaryRow row;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final tone = verdictTone(context, row.kind);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VSpace.s1_5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: VSpace.s2),
            decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle),
          ),
          Expanded(
            flex: 5,
            child: Text(
              row.label,
              style: VType.supporting.copyWith(color: c.textSecondary),
            ),
          ),
          const SizedBox(width: VSpace.s2),
          Expanded(
            flex: 6,
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: VType.label.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.step, required this.last});

  final TraceStep step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final icon = switch (step.status) {
      TraceStepStatus.ok => VIcons.ok,
      TraceStepStatus.fail => VIcons.fail,
      TraceStepStatus.pending => VIcons.pending,
      TraceStepStatus.skipped => Icons.remove,
    };
    // Tier colour wins when the step carries one (VOUCH-DESIGN.md §6.3);
    // otherwise fall back to the plain ok/fail/pending colour.
    final tone = step.status == TraceStepStatus.skipped
        ? c.neutral
        : step.tier != null
        ? tierTone(context, step.tier)
        : switch (step.status) {
            TraceStepStatus.ok => c.ok,
            TraceStepStatus.fail => c.bad,
            TraceStepStatus.pending => c.tier2,
            TraceStepStatus.skipped => c.neutral,
          };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Node and connector.
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.bg,
                    border: Border.all(color: tone.fg.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, color: tone.fg, size: VSize.iconSm),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: c.borderEmphasized,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: VSpace.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: last ? VSpace.s2 : VSpace.s5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          step.label,
                          style: VType.h4.copyWith(color: c.textPrimary),
                        ),
                      ),
                      if (step.tier != null) ...[
                        const SizedBox(width: VSpace.s2),
                        TierChip(tier: step.tier, dense: true),
                      ],
                    ],
                  ),
                  if (step.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.detail!,
                      style: VType.supporting.copyWith(
                        color: step.status == TraceStepStatus.fail
                            ? c.errorText
                            : c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The owner's phone, inline on the Alexa tab: while a step-up is pending
/// it shows the same [ApprovalCard] the Approvals tab shows (speaker,
/// command, confidence, wording notice) and decides it through the same
/// [ApprovalsController] path. No trust logic of its own, it only lets a
/// single-screen demo approve without switching tabs. Renders nothing when
/// no request is pending (or no ApprovalsController is provided).
class OwnerPhoneCard extends StatelessWidget {
  const OwnerPhoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ApprovalsController approvals;
    try {
      approvals = context.watch<ApprovalsController>();
    } on ProviderNotFoundException {
      return const SizedBox.shrink();
    }
    // Drop requests that lapsed a while ago: the expiry job updates the row
    // server-side but only new requests are pushed to the app.
    final cutoff = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
    final pending = approvals.approvals
        .where(
          (a) =>
              a.status == ApprovalStatus.pending && a.expiresAt.isAfter(cutoff),
        )
        .toList();
    if (pending.isEmpty) return const SizedBox.shrink();
    final a = pending.first;
    Map<int, String> names = const {};
    try {
      final overview = context.watch<HouseholdController>().overview;
      names = {
        for (final m in overview?.members ?? const <Member>[])
          if (m.id != null) m.id!: m.displayName,
      };
    } on ProviderNotFoundException {
      // Names are cosmetic; the card falls back to "unrecognised".
    }
    final c = context.v;
    return Padding(
      key: const Key('owner-phone-card'),
      padding: const EdgeInsets.only(bottom: VSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smartphone, size: VSize.iconSm, color: c.t2),
              const SizedBox(width: VSpace.s2),
              Text(
                "Owner's phone",
                style: VType.label.copyWith(color: c.textPrimary),
              ),
              if (pending.length > 1) ...[
                const SizedBox(width: VSpace.s2),
                Text(
                  '+${pending.length - 1} more in Approvals',
                  style: VType.supporting.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: VSpace.s2),
          ApprovalCard(
            key: ValueKey('inline-approval-${a.id}'),
            approval: a,
            memberName: a.memberId != null ? names[a.memberId] : null,
            confidence: a.speakerConfidence,
            onApprove: () => decideAndReport(context, approvals, a.id!, true),
            onDeny: () => decideAndReport(context, approvals, a.id!, false),
          ),
        ],
      ),
    );
  }
}
