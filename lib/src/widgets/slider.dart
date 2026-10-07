import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A slider: a thin track filled with the accent up to a white thumb.
///
/// Tap or drag anywhere on it; with [divisions] it snaps, with a selection tick at each step. It runs from the start
/// edge, so it mirrors in right-to-left text. Screen readers adjust it in steps (a tenth, or one division) and hear
/// its value through [semanticFormatter] (a percentage by default); arrow keys move it too.
///
/// ```dart
/// SheenSlider(value: volume, onChanged: (v) => setState(() => volume = v), semanticLabel: 'Volume')
/// ```
///
/// {@category Inputs}
class SheenSlider extends StatefulWidget {
  /// A slider at [value] within [min]..[max].
  const SheenSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.semanticLabel,
    this.semanticFormatter,
    this.activeColor,
  }) : assert(min < max),
       assert(divisions == null || divisions > 0);

  /// The value, within [min]..[max].
  final double value;

  /// Called as the value changes; null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called when a drag or tap ends.
  final ValueChanged<double>? onChangeEnd;

  /// The lowest value.
  final double min;

  /// The highest value.
  final double max;

  /// Snaps to this many equal steps; null for a continuous slider.
  final int? divisions;

  /// What a screen reader says the slider is for.
  final String? semanticLabel;

  /// How a screen reader reads a value; a percentage of the range when null.
  final String Function(double value)? semanticFormatter;

  /// The fill colour; [SheenColors.accent] when null.
  final Color? activeColor;

  /// The thumb diameter.
  static const double thumb = 28;

  /// The track height.
  static const double track = 4;

  @override
  State<SheenSlider> createState() => _SheenSliderState();
}

class _SheenSliderState extends State<SheenSlider> {
  final FocusNode _focus = FocusNode(debugLabel: 'SheenSlider');

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refocus);
  }

  void _refocus() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  double get _range => widget.max - widget.min;

  double get _step => widget.divisions == null ? _range / 10 : _range / widget.divisions!;

  double _snap(double v) {
    final c = v.clamp(widget.min, widget.max);
    final d = widget.divisions;
    if (d == null) return c;
    return widget.min + ((c - widget.min) / _range * d).round() / d * _range;
  }

  void _set(double v, {bool end = false}) {
    final next = _snap(v);
    if (widget.divisions != null && next != widget.value) HapticFeedback.selectionClick();
    if (next != widget.value) widget.onChanged?.call(next);
    if (end) widget.onChangeEnd?.call(next);
  }

  double _valueAt(double dx, double width) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    var f = ((dx - SheenSlider.thumb / 2) / (width - SheenSlider.thumb)).clamp(0.0, 1.0);
    if (rtl) f = 1 - f;
    return widget.min + f * _range;
  }

  String _read(double v) => widget.semanticFormatter?.call(v) ?? '${((v - widget.min) / _range * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final enabled = widget.onChanged != null;
    final v = widget.value.clamp(widget.min, widget.max);
    final f = (v - widget.min) / _range;
    final up = (v + _step).clamp(widget.min, widget.max), down = (v - _step).clamp(widget.min, widget.max);
    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.semanticLabel,
      value: _read(v),
      increasedValue: _read(up),
      decreasedValue: _read(down),
      onIncrease: enabled && v < widget.max ? () => _set(up, end: true) : null,
      onDecrease: enabled && v > widget.min ? () => _set(down, end: true) : null,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: enabled,
        onKeyEvent: (node, e) {
          if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final k = e.logicalKey;
          final more =
              k == LogicalKeyboardKey.arrowUp ||
              k == (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight);
          final less =
              k == LogicalKeyboardKey.arrowDown ||
              k == (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft);
          if (!more && !less) return KeyEventResult.ignored;
          _set(more ? up : down, end: true);
          return KeyEventResult.handled;
        },
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled ? (d) => _set(_valueAt(d.localPosition.dx, w)) : null,
              onTapUp: enabled ? (_) => widget.onChangeEnd?.call(widget.value) : null,
              onHorizontalDragUpdate: enabled ? (d) => _set(_valueAt(d.localPosition.dx, w)) : null,
              onHorizontalDragEnd: enabled ? (_) => widget.onChangeEnd?.call(widget.value) : null,
              child: SizedBox(
                height: SheenSpace.hit,
                child: Opacity(
                  opacity: enabled ? 1 : .4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PositionedDirectional(
                        start: SheenSlider.thumb / 2,
                        end: SheenSlider.thumb / 2,
                        height: SheenSlider.track,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(shape: const StadiumBorder(), color: t.colors.track),
                          child: FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: f,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: const StadiumBorder(),
                                color: widget.activeColor ?? t.colors.accent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(f * 2 - 1, 0),
                        child: Container(
                          width: SheenSlider.thumb,
                          height: SheenSlider.thumb,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFFFFF),
                            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2))],
                            border: _focus.hasFocus ? Border.all(color: t.colors.accentText, width: 2) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
