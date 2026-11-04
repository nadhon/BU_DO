import 'dart:math';

import 'package:flutter/material.dart';

import '../models/task.dart';

/// Fantasma desenhado em código (CustomPaint), com um visual por humor.
/// Quando tiver os PNG/SVG finais do Figma, troque o CustomPaint por Image.asset.
class Ghost extends StatefulWidget {
  const Ghost({super.key, required this.mood, this.size = 120, this.animate = true});

  final GhostMood mood;
  final double size;
  final bool animate;

  @override
  State<Ghost> createState() => _GhostState();
}

class _GhostState extends State<Ghost> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final degraded = widget.mood == GhostMood.degraded;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value * 2 * pi;
        // Flutua suavemente; o degradado treme.
        final dy = sin(t) * (widget.size * 0.04);
        final dx = degraded ? sin(t * 14) * 2.5 : 0.0;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: CustomPaint(
            size: Size(widget.size, widget.size * 1.05),
            painter: _GhostPainter(widget.mood),
          ),
        );
      },
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter(this.mood);
  final GhostMood mood;

  Path _star(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final a = -pi / 2 + i * pi / 5;
      final pt = Offset(c.dx + cos(a) * rad, c.dy + sin(a) * rad);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = mood == GhostMood.degraded;
    final anxious = mood == GhostMood.anxious;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = dark ? Colors.black : const Color(0xFF1B1B1B);
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..color = const Color(0xFF1B1B1B);

    // Corpo: cúpula + barra ondulada.
    final body = Path()
      ..moveTo(w * 0.08, h * 0.9)
      ..lineTo(w * 0.08, h * 0.42)
      ..cubicTo(w * 0.08, h * 0.02, w * 0.92, h * 0.02, w * 0.92, h * 0.42)
      ..lineTo(w * 0.92, h * 0.9);
    final waveW = (w * 0.84) / 3;
    for (var i = 0; i < 3; i++) {
      final x1 = w * 0.92 - waveW * i;
      body.quadraticBezierTo(x1 - waveW / 2, h * 1.1, x1 - waveW, h * 0.9);
    }
    body.close();

    final fillColor = dark
        ? const Color(0xFF0D0D0D)
        : anxious
            ? const Color(0xFFB9C3C9)
            : const Color(0xFFDCDCDC);
    canvas.drawPath(body, Paint()..color = fillColor);
    canvas.drawPath(body, stroke);

    // Olhos
    final eyeY = h * 0.40;
    final eyeR = w * (anxious || dark ? 0.13 : 0.105);
    for (final cx in [w * 0.36, w * 0.64]) {
      final c = Offset(cx, eyeY);
      if (mood == GhostMood.happy) {
        canvas.drawPath(_star(c, eyeR * 1.35), Paint()..color = const Color(0xFFFFC857));
        canvas.drawPath(_star(c, eyeR * 1.35), thin);
        continue;
      }
      canvas.drawCircle(c, eyeR, Paint()..color = dark ? const Color(0xFFE5202A) : Colors.white);
      canvas.drawCircle(c, eyeR, dark ? (Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2) : thin);
      final off = switch (mood) {
        GhostMood.sad => Offset(0, eyeR * 0.35),
        GhostMood.worried => Offset(eyeR * 0.2, eyeR * 0.2),
        _ => Offset.zero,
      };
      final pr = eyeR * (dark ? 0.28 : anxious ? 0.25 : 0.45);
      canvas.drawCircle(c + off, pr, Paint()..color = dark ? Colors.white : Colors.black);
    }

    // Sobrancelhas (humores tensos)
    if (mood == GhostMood.sad || mood == GhostMood.worried || anxious) {
      canvas.drawLine(Offset(w * 0.26, eyeY - eyeR * 1.6), Offset(w * 0.42, eyeY - eyeR * 2.0), thin);
      canvas.drawLine(Offset(w * 0.58, eyeY - eyeR * 2.0), Offset(w * 0.74, eyeY - eyeR * 1.6), thin);
    }
    if (anxious) {
      // lágrima
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.24, eyeY + eyeR * 1.6), width: w * 0.05, height: w * 0.08),
        Paint()..color = const Color(0xFF6EC1FF),
      );
    }

    // Boca
    final red = Paint()..color = const Color(0xFFD7263D);
    switch (mood) {
      case GhostMood.calm:
        canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.24, height: h * 0.14), 0.2, pi - 0.4, false, thin);
      case GhostMood.happy:
        final m = Path()
          ..moveTo(w * 0.36, h * 0.56)
          ..quadraticBezierTo(w * 0.5, h * 0.84, w * 0.64, h * 0.56)
          ..close();
        canvas.drawPath(m, red);
        canvas.drawPath(m, thin);
      case GhostMood.sad:
        canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.22, height: h * 0.12), pi + 0.2, pi - 0.4, false, thin);
      case GhostMood.worried:
        final m = Path()..moveTo(w * 0.38, h * 0.64);
        for (var i = 1; i <= 4; i++) {
          m.lineTo(w * (0.38 + 0.06 * i), h * (i.isOdd ? 0.61 : 0.65));
        }
        canvas.drawPath(m, thin);
      case GhostMood.anxious:
        final r = Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.16, height: h * 0.14);
        canvas.drawOval(r, Paint()..color = const Color(0xFF7A1020));
        canvas.drawOval(r, thin);
      case GhostMood.degraded:
        final m = Path()..moveTo(w * 0.26, h * 0.6);
        const teeth = 7;
        for (var i = 0; i < teeth; i++) {
          final x = w * (0.26 + 0.48 * (i + 0.5) / teeth);
          m.lineTo(x, h * 0.7);
          m.lineTo(w * (0.26 + 0.48 * (i + 1) / teeth), h * 0.6);
        }
        m.quadraticBezierTo(w * 0.5, h * 0.86, w * 0.26, h * 0.6);
        canvas.drawPath(m, Paint()..color = const Color(0xFFB00020));
        canvas.drawPath(m, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_GhostPainter old) => old.mood != mood;
}
