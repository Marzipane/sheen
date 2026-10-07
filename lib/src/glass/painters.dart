import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../foundation/glass_style.dart';

/// Paints [shadows] only outside [shape], the way CSS `box-shadow` does. Flutter's `BoxShadow` also paints under the
/// shape, which would darken translucent glass.
class SheenOuterShadowPainter extends CustomPainter {
  /// Paints [shadows] around [shape].
  SheenOuterShadowPainter({required this.shape, required this.shadows, required this.textDirection});

  /// The outline the shadows fall from.
  final ShapeBorder shape;

  /// The shadows, drawn in order.
  final List<BoxShadow> shadows;

  /// Resolves directional shapes.
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;
    final rect = Offset.zero & size;
    final body = shape.getOuterPath(rect, textDirection: textDirection);
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(200))
      ..addPath(body, Offset.zero);
    canvas.save();
    canvas.clipPath(outside);
    for (final s in shadows) {
      final p = Paint()
        ..color = s.color
        ..maskFilter = s.blurRadius > 0 ? MaskFilter.blur(BlurStyle.normal, s.blurSigma) : null;
      canvas.drawPath(
        shape.getOuterPath(rect.shift(s.offset).inflate(s.spreadRadius), textDirection: textDirection),
        p,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SheenOuterShadowPainter old) => old.shape != shape || old.shadows != shadows;
}

/// The glass edges, drawn over the body: the specular highlight, the inner top / bottom lines, a hairline ring and
/// the 1 px gradient rim.
class SheenGlassEdgePainter extends CustomPainter {
  /// Paints the edges of a glass surface in [shape]; see [SheenGlassStyle] for each part.
  SheenGlassEdgePainter({
    required this.shape,
    required this.rim,
    required this.rimStops,
    required this.rimAngle,
    required this.innerTop,
    required this.innerTopWidth,
    this.innerBottom,
    this.innerRing,
    this.highlight,
    this.highlightCenter = const Alignment(-.44, -1.2),
    this.highlightStop = .58,
    this.textDirection,
  });

  /// The outline of the glass.
  final ShapeBorder shape;

  /// See [SheenGlassStyle.rim].
  final List<Color> rim;

  /// See [SheenGlassStyle.rimStops].
  final List<double> rimStops;

  /// See [SheenGlassStyle.rimAngle].
  final double rimAngle;

  /// See [SheenGlassStyle.innerTop].
  final Color innerTop;

  /// See [SheenGlassStyle.innerTopWidth].
  final double innerTopWidth;

  /// See [SheenGlassStyle.innerBottom].
  final Color? innerBottom;

  /// See [SheenGlassStyle.innerRing].
  final Color? innerRing;

  /// See [SheenGlassStyle.highlight].
  final Color? highlight;

  /// See [SheenGlassStyle.highlightCenter].
  final Alignment highlightCenter;

  /// See [SheenGlassStyle.highlightStop].
  final double highlightStop;

  /// Resolves directional shapes.
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final body = shape.getOuterPath(rect, textDirection: textDirection);
    canvas.save();
    canvas.clipPath(body);

    final h = highlight;
    if (h != null && h.a > 0) {
      // radial-gradient(120% 90% at 28% -10%, h, transparent stop): an ellipse 1.2w × 0.9h.
      final rx = 1.2 * size.width, ry = .9 * size.height;
      final c = highlightCenter.alongSize(size);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(rx / ry, 1);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [h, h.withValues(alpha: 0)],
          stops: [0, highlightStop],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: ry));
      canvas.drawCircle(Offset.zero, ry, paint);
      canvas.restore();
    }

    void band(Offset shift, Color color) {
      final band = Path.combine(PathOperation.difference, body, body.shift(shift));
      canvas.drawPath(band, Paint()..color = color);
    }

    band(Offset(0, innerTopWidth), innerTop);
    final ib = innerBottom;
    if (ib != null) band(const Offset(0, -1), ib);
    final ring = innerRing;
    if (ring != null) {
      canvas.drawPath(
        shape.getOuterPath(rect.deflate(.25), textDirection: textDirection),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .5
          ..color = ring,
      );
    }

    // 1 px rim along the inside of the edge. CSS angle 180° = top to bottom; Flutter's gradient runs top to bottom
    // and GradientRotation turns it clockwise, so the rotation is (angle - 180°).
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: rim,
        stops: rimStops,
        transform: GradientRotation((rimAngle - 180) * math.pi / 180),
      ).createShader(rect);
    canvas.drawPath(shape.getOuterPath(rect.deflate(.5), textDirection: textDirection), rimPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SheenGlassEdgePainter old) =>
      old.shape != shape || !listEquals(old.rim, rim) || old.innerTop != innerTop || old.highlight != highlight;
}
