import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Entrance: fades in and rises 8px, staggered by [index]. Used once, when
/// content first arrives. It tells you where content came from and then
/// stops moving (motion DR1, DR4). With reduced motion it simply appears.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 8,
    this.duration = VMotion.medium,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  // The stagger lives inside the controller as an Interval rather than a
  // Future.delayed, so no timer outlives the widget.
  late final Duration _delay = VMotion.stagger * math.min(widget.index, 10);
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration + _delay,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(
      _delay.inMicroseconds / (widget.duration + _delay).inMicroseconds,
      1,
      curve: VMotion.standard,
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (VMotion.reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// The one interaction surface for anything tappable that isn't a stock
/// button: hover tint, press tint and a 0.985 press scale on the fast band,
/// plus the Astryx focus ring (2px, 3px offset, keyboard only), in mint.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = VRadius.elementR,
    this.semanticLabel,
    this.scale = true,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;
  final bool scale;
  final bool selected;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _down = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final enabled = widget.onTap != null;
    final overlay = !enabled
        ? Colors.transparent
        : _down
        ? c.overlayPressed
        : _hover
        ? c.overlayHover
        : Colors.transparent;
    final d = VMotion.of(context, VMotion.fast);

    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: enabled ? () => setState(() => _down = false) : null,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                }
              : null,
          child: AnimatedScale(
            scale: widget.scale && _down ? 0.985 : 1,
            duration: d,
            curve: VMotion.standard,
            child: CustomPaint(
              foregroundPainter: _focus
                  ? _FocusRingPainter(
                      color: c.success,
                      radius: widget.borderRadius,
                    )
                  : null,
              child: AnimatedContainer(
                duration: d,
                curve: VMotion.standard,
                foregroundDecoration: BoxDecoration(
                  color: overlay,
                  borderRadius: widget.borderRadius,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    const offset = 3.0;
    final rect = (Offset.zero & size).inflate(offset);
    final rrect = radius
        .copyWith(
          topLeft: radius.topLeft + const Radius.circular(offset),
          topRight: radius.topRight + const Radius.circular(offset),
          bottomLeft: radius.bottomLeft + const Radius.circular(offset),
          bottomRight: radius.bottomRight + const Radius.circular(offset),
        )
        .toRRect(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.color != color || old.radius != radius;
}

/// A status dot. When [live], a soft ring expands from it on the slow band:
/// the hub's heartbeat. Ambient motion is meaningful here because it
/// signals "this is live right now" (DR1). It stays still when reduced.
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    required this.color,
    this.live = false,
    this.size = 8,
  });

  final Color color;
  final bool live;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  void _sync() {
    final run =
        widget.live && VMotion.ambientEnabled && !VMotion.reduced(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    // The halo overflows the dot's box, so the dot lays out at its own size.
    return SizedBox.square(
      dimension: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = VMotion.standard.transform(_c.value);
          return OverflowBox(
            maxWidth: s * 3,
            maxHeight: s * 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_c.isAnimating)
                  Container(
                    width: s + s * 2 * t,
                    height: s + s * 2 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.35 * (1 - t)),
                    ),
                  ),
                Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                    boxShadow: widget.live
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.5),
                              blurRadius: s,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Loading placeholder with a slow sheen. It shows the shape of what's
/// coming instead of a spinner.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = VRadius.inner,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (VMotion.ambientEnabled &&
        !VMotion.reduced(context) &&
        !_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = -1.5 + 3 * _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [
                c.skeleton,
                Color.lerp(c.skeleton, c.textSecondary, 0.12)!,
                c.skeleton,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Concentric rings that ripple outwards while [active]: "Alexa is
/// listening / the guard is deciding". They settle to still rings at rest.
class ListeningRings extends StatefulWidget {
  const ListeningRings({
    super.key,
    required this.active,
    required this.color,
    required this.child,
    this.size = 168,
  });

  final bool active;
  final Color color;
  final Widget child;
  final double size;

  @override
  State<ListeningRings> createState() => _ListeningRingsState();
}

class _ListeningRingsState extends State<ListeningRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  void _sync() {
    final run =
        widget.active && VMotion.ambientEnabled && !VMotion.reduced(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.animateTo(0, duration: VMotion.medium, curve: VMotion.standard);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(ListeningRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) => CustomPaint(
          painter: _RingsPainter(
            progress: _c.value,
            active: widget.active,
            color: widget.color,
            rest: context.v.border,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.active,
    required this.color,
    required this.rest,
  });

  final double progress;
  final bool active;
  final Color color;
  final Color rest;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    const rings = 3;
    for (var i = 0; i < rings; i++) {
      final restR = maxR * (0.56 + 0.22 * i);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      if (active) {
        final p = (progress + i / rings) % 1.0;
        final r = maxR * (0.5 + 0.5 * VMotion.standard.transform(p));
        paint.color = color.withValues(alpha: 0.45 * (1 - p));
        canvas.drawCircle(center, r, paint);
      } else {
        paint.color = rest.withValues(alpha: rest.a * (1 - i * 0.28));
        canvas.drawCircle(center, restR, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.progress != progress || old.active != active || old.color != color;
}

/// Counts up to [value] with tabular figures on the medium band.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: VMotion.of(context, VMotion.slowMin),
      curve: VMotion.standard,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}
