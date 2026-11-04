import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Assombra o app inteiro. [intensity] vai de 0 (nada) a 1 (caos total).
/// Em rajadas aleatórias: tremida horizontal, canais de cor trocados,
/// faixas de ruído e vibração do aparelho. Acima de 0 fica uma vinheta roxa;
/// acima de ~0.66 entram scanlines.
class GlitchOverlay extends StatefulWidget {
  const GlitchOverlay({super.key, required this.intensity, required this.child});

  final double intensity;
  final Widget child;

  @override
  State<GlitchOverlay> createState() => _GlitchOverlayState();
}

class _Bar {
  _Bar(this.y, this.h, this.dx, this.color);
  final double y, h, dx; // fração da altura / deslocamento em px
  final Color color;
}

class _GlitchOverlayState extends State<GlitchOverlay> {
  final _rnd = Random();
  Timer? _next, _end;
  bool _burst = false;
  List<_Bar> _bars = [];
  Offset _shift = Offset.zero;

  static const _swapRB = <double>[
    0, 0, 1, 0, 0, //
    0, 1, 0, 0, 0,
    1, 0, 0, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(GlitchOverlay old) {
    super.didUpdateWidget(old);
    if (old.intensity != widget.intensity) _schedule();
  }

  void _schedule() {
    _next?.cancel();
    if (widget.intensity <= 0) {
      if (_burst) setState(() => _burst = false);
      return;
    }
    // Quanto mais atrasado, mais frequentes as rajadas (≈1s a ≈5s).
    final ms = (4000 - 3200 * widget.intensity).round() + _rnd.nextInt(1500);
    _next = Timer(Duration(milliseconds: ms), _fire);
  }

  void _fire() {
    if (!mounted) return;
    final k = widget.intensity;
    final n = 3 + (k * 8).round();
    const colors = [Color(0xFFFF00E6), Color(0xFF00F0FF), Color(0xFFFFFFFF), Color(0xFFFF1A1A)];
    setState(() {
      _burst = true;
      _shift = Offset((_rnd.nextDouble() - 0.5) * 28 * k, 0);
      _bars = List.generate(
        n,
        (_) => _Bar(
          _rnd.nextDouble(),
          0.005 + _rnd.nextDouble() * 0.05,
          (_rnd.nextDouble() - 0.5) * 60,
          colors[_rnd.nextInt(colors.length)],
        ),
      );
    });
    if (k >= 0.66) {
      HapticFeedback.heavyImpact();
    } else if (k >= 0.33) {
      HapticFeedback.lightImpact();
    }
    _end = Timer(Duration(milliseconds: 120 + _rnd.nextInt(200)), () {
      if (!mounted) return;
      setState(() => _burst = false);
      _schedule();
    });
  }

  @override
  void dispose() {
    _next?.cancel();
    _end?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    if (_burst) {
      content = Transform.translate(
        offset: _shift,
        child: ColorFiltered(colorFilter: const ColorFilter.matrix(_swapRB), child: content),
      );
    }
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Positioned.fill(child: content),
        if (widget.intensity > 0)
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _AtmospherePainter(widget.intensity))),
          ),
        if (_burst)
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _BarsPainter(_bars))),
          ),
      ],
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.bars);
  final List<_Bar> bars;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bars) {
      canvas.drawRect(
        Rect.fromLTWH(b.dx, b.y * size.height, size.width, b.h * size.height),
        Paint()..color = b.color.withOpacity(0.35),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => true;
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter(this.k);
  final double k;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, const Color(0xFF2A0A4A).withOpacity(0.45 * k)],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
    if (k >= 0.66) {
      final p = Paint()..color = Colors.black.withOpacity(0.07);
      for (var y = 0.0; y < size.height; y += 4) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) => old.k != k;
}
