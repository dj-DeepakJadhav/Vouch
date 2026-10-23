import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design.dart';

/// An Echo-style light ring: a cyan/blue arc that sweeps round the device
/// while Alexa+ is deciding, and rests as a faint steady blue ring.
class EchoRing extends StatefulWidget {
  const EchoRing({super.key, required this.active, this.size = 120});

  final bool active;
  final double size;

  static const Color cyan = Color(0xFF00CAFF);
  static const Color blue = Color(0xFF1E4DFF);

  @override
  State<EchoRing> createState() => _EchoRingState();
}

class _EchoRingState extends State<EchoRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  void _sync() {
    final run =
        widget.active && VMotion.ambientEnabled && !VMotion.reduced(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(EchoRing old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.active ? 'Alexa is thinking' : 'Alexa is ready',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _EchoPainter(
              angle: _c.value * 2 * math.pi,
              active: widget.active,
            ),
          ),
        ),
      ),
    );
  }
}

class _EchoPainter extends CustomPainter {
  _EchoPainter({required this.angle, required this.active});

  final double angle;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final ringR = r * 0.78;
    final stroke = size.width * 0.075;

    // The dark Echo body.
    canvas.drawCircle(
      center,
      r * 0.7,
      Paint()..color = const Color(0xFF0B1220),
    );

    final rect = Rect.fromCircle(center: center, radius: ringR);
    if (!active) {
      canvas.drawCircle(
        center,
        ringR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 0.6
          ..color = EchoRing.cyan.withValues(alpha: 0.55),
      );
      return;
    }
    final shader = SweepGradient(
      colors: [
        EchoRing.blue.withValues(alpha: 0),
        EchoRing.blue,
        EchoRing.cyan,
        EchoRing.blue.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.45, 0.8, 1.0],
      transform: GradientRotation(angle),
    ).createShader(rect);
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.6
        ..shader = shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke),
    );
    canvas.drawCircle(
      center,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_EchoPainter old) =>
      old.angle != angle || old.active != active;
}
