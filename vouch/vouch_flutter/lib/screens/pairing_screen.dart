import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/shell.dart' show VouchMark;
import '../app/theme.dart';
import '../data/repositories/pairing_repository.dart';
import '../logic/friendly_error.dart';

/// Shown whenever the (anonymously signed-in) app can't resolve a
/// household yet — the app's onboarding screen (anonymous auth + hub pairing,
/// not email). Asks for the 6-digit code printed by `python -m vouch_hub pair`
/// and redeems it.
class PairingScreen extends StatefulWidget {
  const PairingScreen({
    super.key,
    required this.pairingRepository,
    required this.onPaired,
    this.onTryDemo,
  });

  /// Servers with demo mode on (or local dev servers): creates this
  /// session's own demo household (Priya + Ana) and links this device to it, so the simulated Alexa+ can be tried with no hub. Null
  /// hides the button.
  final Future<void> Function()? onTryDemo;

  final PairingRepository pairingRepository;
  final void Function(HouseholdOverview overview) onPaired;

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: VMotion.medium,
  );
  bool _busy = false;
  String? _error;

  Future<void> _tryDemo() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onTryDemo!();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(
          e,
          what: 'start the demo household',
          hint:
              'The demo may be busy (too many new demo households this '
              'hour). Try again in a few minutes.',
        );
        _busy = false;
      });
    }
  }

  bool get _canSubmit =>
      !_busy && RegExp(r'^\d{6}$').hasMatch(_controller.text.trim());

  Future<void> _redeem() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final overview = await widget.pairingRepository.redeem(
        _controller.text.trim(),
      );
      widget.onPaired(overview);
    } catch (e) {
      if (!mounted) return;
      if (!VMotion.reduced(context)) _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
      setState(() {
        _error = pairingErrorMessage(e);
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  /// Pair + demo buttons. With no code typed the demo is the one obvious
  /// thing to press (filled, first); once a code is typed, Pair takes over.
  List<Widget> _actions(VColors c) {
    const tall = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(VSize.elementXl)),
    );
    final demoPrimary = widget.onTryDemo != null && _controller.text.isEmpty;
    final pairChild = _busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: demoPrimary ? c.textDisabled : c.onInverted,
            ),
          )
        : const Text('Pair');
    final pair = FadeSlideIn(
      index: 5,
      child: demoPrimary
          ? OutlinedButton(
              onPressed: _canSubmit ? _redeem : null,
              style: tall,
              child: pairChild,
            )
          : FilledButton(
              onPressed: _canSubmit ? _redeem : null,
              style: tall,
              child: pairChild,
            ),
    );
    if (widget.onTryDemo == null) return [pair];
    final demoLabel = const Text('Try the demo household (no hub)');
    final demo = FadeSlideIn(
      index: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Tooltip(
            message:
                'Demo household: voices are simulated in this browser; real '
                'households verify on the hub',
            child: demoPrimary
                ? FilledButton.icon(
                    key: const Key('try-demo-household'),
                    onPressed: _busy ? null : _tryDemo,
                    style: tall.merge(
                      FilledButton.styleFrom(
                        backgroundColor: c.brand,
                        foregroundColor: c.onBrand,
                        disabledBackgroundColor: c.brand.withValues(alpha: 0.5),
                        disabledForegroundColor: c.onBrand,
                      ),
                    ),
                    icon: const Icon(VIcons.voice, size: VSize.iconSm),
                    label: demoLabel,
                  )
                : OutlinedButton.icon(
                    key: const Key('try-demo-household'),
                    onPressed: _busy ? null : _tryDemo,
                    style: tall,
                    icon: const Icon(VIcons.voice, size: VSize.iconSm),
                    label: demoLabel,
                  ),
          ),
          if (demoPrimary) ...[
            const SizedBox(height: VSpace.s1_5),
            Text(
              'No hardware needed · simulated voices',
              key: const Key('demo-helper'),
              textAlign: TextAlign.center,
              style: VType.supporting.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
    return demoPrimary
        ? [demo, const SizedBox(height: VSpace.s3), pair]
        : [pair, const SizedBox(height: VSpace.s3), demo];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FadeSlideIn(child: Center(child: VouchMark(size: 44))),
                const SizedBox(height: VSpace.s6),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    'Pair with your hub',
                    textAlign: TextAlign.center,
                    style: VType.h1.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: VSpace.s2),
                FadeSlideIn(
                  index: 2,
                  child: Text(
                    "This device isn't linked to a household yet",
                    textAlign: TextAlign.center,
                    style: VType.body.copyWith(color: c.textSecondary),
                  ),
                ),
                const SizedBox(height: VSpace.s8),
                FadeSlideIn(
                  index: 3,
                  child: _Step(
                    n: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'On the hub, run:',
                          style: VType.label.copyWith(color: c.textPrimary),
                        ),
                        const SizedBox(height: VSpace.s2),
                        Container(
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
                            children: [
                              Text(
                                '\$ ',
                                style: VType.code.copyWith(
                                  color: c.textDisabled,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'python -m vouch_hub pair',
                                  style: VType.code.copyWith(
                                    color: c.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Copy',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  Clipboard.setData(
                                    const ClipboardData(
                                      text: 'python -m vouch_hub pair',
                                    ),
                                  );
                                  ScaffoldMessenger.maybeOf(
                                    context,
                                  )?.showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  VIcons.copy,
                                  size: VSize.iconXs + 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: VSpace.s5),
                FadeSlideIn(
                  index: 4,
                  child: _Step(
                    n: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'then enter the 6-digit code it prints before it expires '
                          '(10 minutes).',
                          style: VType.label.copyWith(color: c.textPrimary),
                        ),
                        const SizedBox(height: VSpace.s3),
                        AnimatedBuilder(
                          animation: _shake,
                          builder: (context, child) => Transform.translate(
                            // A damped shake: "that code didn't work".
                            offset: Offset(
                              math.sin(_shake.value * math.pi * 6) *
                                  8 *
                                  (1 - _shake.value),
                              0,
                            ),
                            child: child,
                          ),
                          child: _CodeField(
                            controller: _controller,
                            focusNode: _focus,
                            error: _error != null,
                            onChanged: (_) => setState(() => _error = null),
                            onSubmitted: (_) => _canSubmit ? _redeem() : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: VMotion.of(context, VMotion.fastMax),
                  curve: VMotion.standard,
                  child: _error == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(
                            top: VSpace.s3,
                            left: 36,
                          ),
                          child: VInlineError(_error!),
                        ),
                ),
                const SizedBox(height: VSpace.s6),
                ..._actions(c),
                const SizedBox(height: VSpace.s6),
                const PrivacyChip(prominent: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.child});

  final int n;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.borderEmphasized),
          ),
          child: Text(
            '$n',
            style: VType.codeSm.copyWith(color: c.textSecondary),
          ),
        ),
        const SizedBox(width: VSpace.s3),
        Expanded(child: child),
      ],
    );
  }
}

/// Six digit cells over one real (invisible) text field, so paste, IME and
/// accessibility all work as they would on a normal input.
class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final text = controller.text;
        final focused = focusNode.hasFocus;
        return Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  if (i == 3) const SizedBox(width: VSpace.s3),
                  if (i > 0 && i != 3) const SizedBox(width: VSpace.s1_5),
                  Expanded(
                    child: AnimatedContainer(
                      duration: VMotion.of(context, VMotion.fast),
                      curve: VMotion.standard,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.muted,
                        borderRadius: VRadius.elementR,
                        border: Border.all(
                          width: 1.5,
                          color: error
                              ? c.error
                              : focused &&
                                    (i == text.length ||
                                        (i == 5 && text.length == 6))
                              ? c.brand
                              : i < text.length
                              ? c.borderEmphasized
                              : c.border,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: VMotion.of(context, VMotion.fast),
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.6, end: 1.0).animate(a),
                            child: child,
                          ),
                        ),
                        child: Text(
                          i < text.length ? text[i] : '',
                          key: ValueKey('$i-${i < text.length ? text[i] : ''}'),
                          style: VType.metric.copyWith(color: c.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    filled: false,
                    hintText: '000000',
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
