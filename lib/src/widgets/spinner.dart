import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The ring spinner of the boards: a faint track with a bright quarter that turns (keeps turning with reduced
/// motion, like the system spinner).
class SheenSpinner extends StatefulWidget {
  const SheenSpinner({
    super.key,
    this.size = 18,
    this.color = const Color(0xFFFFFFFF),
    this.stroke = 2.5,
    this.trackColor,
  });

  final double size;
  final Color color;
  final double stroke;

  /// The ring under the arc; defaults to [color] at .35.
  final Color? trackColor;

  @override
  State<SheenSpinner> createState() => _SheenSpinnerState();
}

class _SheenSpinnerState extends State<SheenSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size,
    child: RotationTransition(
      turns: _c,
      child: CustomPaint(
        painter: _RingPainter(widget.color, widget.stroke, widget.trackColor ?? widget.color.withValues(alpha: .35)),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.stroke, this.track);
  final Color color;
  final double stroke;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawOval(r, paint);
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi / 2,
      false,
      paint
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color || old.stroke != stroke || old.track != track;
}
