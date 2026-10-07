import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';

/// A piece that arrives once, when it is first built (a screen's first content, results, a success view): after [delay] it fades in,
/// rises [rise] points into place and grows from [scaleFrom], on [spring]. Only opacity and transform move, so glass
/// keeps its blur. It takes taps, and VoiceOver reads it, from its first frame: an entrance never makes anyone wait.
///
/// With Reduce Motion everything arrives together with a short fade: no delay, no rise, no scale. [play] false shows
/// the child as it is (an item scrolled into view later is not an arrival).
///
/// {@category Motion}
class SheenEntrance extends StatefulWidget {
  /// [child] arriving after [delay].
  const SheenEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.rise = 0,
    this.scaleFrom = 1,
    this.spring,
    this.alignment = Alignment.center,
    this.play = true,
  });

  /// The arriving piece.
  final Widget child;

  /// How long to wait before arriving (see [SheenMotion.staggerDelay] for lists).
  final Duration delay;

  /// Points the piece travels up into place.
  final double rise;

  /// The scale the piece grows from (1 = no growth).
  final double scaleFrom;

  /// The spring the move settles on; [SheenMotion.smooth] when null.
  final SpringDescription? spring;

  /// The origin of the scale.
  final Alignment alignment;

  /// Whether to play the entrance; false shows [child] as it is.
  final bool play;

  @override
  State<SheenEntrance> createState() => _SheenEntranceState();
}

class _SheenEntranceState extends State<SheenEntrance> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  late Animation<double> _move;
  late Animation<double> _fade;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || !widget.play) return;
    if (SheenMotion.reduced(context)) {
      final c = _c = AnimationController(vsync: this, duration: SheenMotion.fadeIn);
      _move = kAlwaysCompleteAnimation;
      _fade = CurvedAnimation(parent: c, curve: SheenMotion.easeOut);
    } else {
      final spring = widget.spring ?? SheenMotion.smooth;
      final settle = SheenMotion.settleOf(spring);
      final total = widget.delay + settle;
      final start = widget.delay.inMicroseconds / total.inMicroseconds;
      final fadeEnd = (widget.delay + SheenMotion.fadeIn).inMicroseconds / total.inMicroseconds;
      final c = _c = AnimationController(vsync: this, duration: total);
      _move = CurvedAnimation(
        parent: c,
        curve: Interval(start, 1, curve: SheenMotion.curveOf(spring)),
      );
      _fade = CurvedAnimation(
        parent: c,
        curve: Interval(start, fadeEnd.clamp(start, 1.0), curve: SheenMotion.easeOut),
      );
    }
    _c!.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      child: widget.child,
      builder: (context, child) {
        final v = _move.value;
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          // there for VoiceOver from the first frame, as it is for taps
          alwaysIncludeSemantics: true,
          child: Transform.translate(
            offset: Offset(0, widget.rise * (1 - v)),
            child: Transform.scale(
              scale: widget.scaleFrom + (1 - widget.scaleFrom) * v,
              alignment: widget.alignment,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
