import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Shared by the bar and the ring: a repeating controller that only runs for an indeterminate indicator without
/// Reduce Motion.
mixin _Indeterminate<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  bool get indeterminate;

  void sync() {
    final run = indeterminate && !SheenMotion.reduced(context);
    if (run && !loop.isAnimating) {
      loop.repeat();
    } else if (!run && loop.isAnimating) {
      loop.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

String _percent(double v) => '${(v.clamp(0.0, 1.0) * 100).round()}%';

/// A thin progress bar: a track filled with the accent up to [value], from the start edge.
///
/// Without a [value] it is indeterminate: a segment sweeps along the track (it holds still with Reduce Motion).
///
/// {@category Feedback}
class SheenProgressBar extends StatefulWidget {
  /// A bar at [value] (0 to 1), or indeterminate when null.
  const SheenProgressBar({super.key, this.value, this.color, this.height = 4, this.semanticLabel});

  /// How far along, from 0 to 1; null for indeterminate.
  final double? value;

  /// The fill colour; [SheenColors.accent] when null.
  final Color? color;

  /// The bar height.
  final double height;

  /// What a screen reader says is in progress.
  final String? semanticLabel;

  @override
  State<SheenProgressBar> createState() => _SheenProgressBarState();
}

class _SheenProgressBarState extends State<SheenProgressBar>
    with SingleTickerProviderStateMixin, _Indeterminate<SheenProgressBar> {
  @override
  bool get indeterminate => widget.value == null;

  @override
  void didUpdateWidget(SheenProgressBar old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final color = widget.color ?? t.colors.accent;
    final v = widget.value;
    Widget fill(double factor) => FractionallySizedBox(
      key: const ValueKey('sheen-progress-fill'),
      widthFactor: factor,
      heightFactor: 1,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: color),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      value: v == null ? null : _percent(v),
      child: SizedBox(
        height: widget.height,
        child: DecoratedBox(
          decoration: ShapeDecoration(shape: const StadiumBorder(), color: t.colors.track),
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            child: v != null
                ? Align(alignment: AlignmentDirectional.centerStart, child: fill(v.clamp(0.0, 1.0)))
                : AnimatedBuilder(
                    animation: loop,
                    builder: (context, _) => Align(
                      // a third of the track sweeping from before the start to past the end
                      alignment: AlignmentDirectional(-1.6 + loop.value * 3.2, 0),
                      child: fill(.35),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// A circular progress indicator: an arc in the accent over a faint ring, filled to [value].
///
/// Without a [value] it is indeterminate: a quarter arc turns (it holds still with Reduce Motion; use [SheenSpinner]
/// for a wait that should always turn).
///
/// {@category Feedback}
class SheenProgressRing extends StatefulWidget {
  /// A ring at [value] (0 to 1), or indeterminate when null.
  const SheenProgressRing({super.key, this.value, this.size = 28, this.stroke = 3, this.color, this.semanticLabel});

  /// How far along, from 0 to 1; null for indeterminate.
  final double? value;

  /// The diameter.
  final double size;

  /// The ring's stroke width.
  final double stroke;

  /// The arc colour; [SheenColors.accent] when null.
  final Color? color;

  /// What a screen reader says is in progress.
  final String? semanticLabel;

  @override
  State<SheenProgressRing> createState() => _SheenProgressRingState();
}

class _SheenProgressRingState extends State<SheenProgressRing>
    with SingleTickerProviderStateMixin, _Indeterminate<SheenProgressRing> {
  @override
  bool get indeterminate => widget.value == null;

  @override
  void didUpdateWidget(SheenProgressRing old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final color = widget.color ?? t.colors.accent;
    final v = widget.value;
    return Semantics(
      label: widget.semanticLabel,
      value: v == null ? null : _percent(v),
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: loop,
          builder: (context, _) => CustomPaint(
            painter: _RingPainter(
              color: color,
              track: t.colors.track,
              stroke: widget.stroke,
              start: v == null ? loop.value * 2 * math.pi : 0,
              sweep: v == null ? math.pi / 2 : v.clamp(0.0, 1.0) * 2 * math.pi,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.track,
    required this.stroke,
    required this.start,
    required this.sweep,
  });

  final Color color, track;
  final double stroke, start, sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawOval(r, p);
    if (sweep <= 0) return;
    canvas.drawArc(
      r,
      -math.pi / 2 + start,
      sweep,
      false,
      p
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.track != track || old.stroke != stroke || old.start != start || old.sweep != sweep;
}
