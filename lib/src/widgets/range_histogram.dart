import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A range filter over a histogram, such as a price filter: bars show how the items spread over the values, and two
/// knobs on their baseline pick a range; bars inside it are lit.
///
/// The low end is on the leading side, so it mirrors in right-to-left text. Each knob is an adjustable slider for
/// screen readers, its value read through [format].
/// ```dart
/// SheenRangeHistogram(
///   bins: counts,
///   min: 0,
///   max: 1000,
///   values: range,
///   onChanged: (r) => setState(() => range = r),
///   lowLabel: 'Minimum price',
///   highLabel: 'Maximum price',
///   format: (v) => '€ ${v.round()}',
/// )
/// ```
/// {@category Selection}
class SheenRangeHistogram extends StatefulWidget {
  /// A histogram with a range over [min]–[max].
  const SheenRangeHistogram({
    super.key,
    required this.bins,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    required this.lowLabel,
    required this.highLabel,
    required this.format,
    this.onChangeEnd,
  });

  /// Items per equal slice of [min]–[max], low to high.
  final List<int> bins;

  /// The lowest value.
  final double min;

  /// The highest value.
  final double max;

  /// The chosen range.
  final SheenRange values;

  /// Called as a knob moves.
  final ValueChanged<SheenRange> onChanged;

  /// Called when a knob is let go.
  final ValueChanged<SheenRange>? onChangeEnd;

  /// The low knob's label for screen readers.
  final String lowLabel;

  /// The high knob's label for screen readers.
  final String highLabel;

  /// Formats a value for screen readers.
  final String Function(double value) format;

  /// The height of the bars.
  static const double barsHeight = 64;

  /// The knob diameter.
  static const double knob = 28;

  /// The widget height.
  static const double height = barsHeight + knob / 2;

  @override
  State<SheenRangeHistogram> createState() => _SheenRangeHistogramState();
}

class _SheenRangeHistogramState extends State<SheenRangeHistogram> {
  /// The knob being dragged: 1 low, 2 high. Kept across the rebuilds each move causes.
  int _dragging = 0;

  static const double barsHeight = SheenRangeHistogram.barsHeight;
  static const double knob = SheenRangeHistogram.knob;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) => _build(context, box.maxWidth));

  Widget _build(BuildContext context, double width) {
    final w = widget;
    final bins = w.bins,
        min = w.min,
        max = w.max,
        values = w.values,
        onChanged = w.onChanged,
        onChangeEnd = w.onChangeEnd,
        format = w.format;
    final t = context.sheen;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    const pad = knob / 2;
    final span = (width - 2 * pad).clamp(1.0, double.infinity);
    final range = (max - min) <= 0 ? 1.0 : max - min;

    double fracOf(double v) => ((v - min) / range).clamp(0.0, 1.0);
    // from the leading edge: low on the left, or on the right in right to left
    double xOf(double v) => pad + (rtl ? 1 - fracOf(v) : fracOf(v)) * span;
    double valueAt(double x) {
      final f = ((x - pad) / span).clamp(0.0, 1.0);
      return min + (rtl ? 1 - f : f) * range;
    }

    final lo = values.start.clamp(min, max), hi = values.end.clamp(min, max);
    final top = bins.fold<int>(0, (m, b) => b > m ? b : m);
    final binWidth = range / (bins.isEmpty ? 1 : bins.length);

    Widget bar(int i) {
      final center = min + binWidth * (i + .5);
      final on = center >= lo && center <= hi;
      final h = top == 0 ? 2.0 : (bins[i] / top * (barsHeight - 6)).clamp(2.0, barsHeight);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              key: ValueKey(on ? 'bar-on' : 'bar-off'),
              height: h,
              decoration: BoxDecoration(
                color: on ? t.colors.accentText : t.colors.surfaceMuted,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          ),
        ),
      );
    }

    final step = range / 20;
    Widget knobAt(double v, String label, bool low) {
      final next = low ? (v + step).clamp(min, hi) : (v + step).clamp(lo, max);
      final prev = low ? (v - step).clamp(min, hi) : (v - step).clamp(lo, max);
      void set(double to) {
        final r = low ? SheenRange(to, hi) : SheenRange(lo, to);
        onChanged(r);
        onChangeEnd?.call(r);
      }

      return Positioned(
        left: xOf(v) - pad,
        top: barsHeight - pad,
        child: Semantics(
          slider: true,
          label: label,
          value: format(v),
          increasedValue: format(next),
          decreasedValue: format(prev),
          onIncrease: () => set(next),
          onDecrease: () => set(prev),
          child: Container(
            width: knob,
            height: knob,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFFFFF),
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (d) {
        final v = valueAt(d.localPosition.dx);
        if (v <= lo) {
          _dragging = 1;
        } else if (v >= hi) {
          _dragging = 2;
        } else {
          _dragging = (v - lo).abs() <= (hi - v).abs() ? 1 : 2;
        }
        HapticFeedback.selectionClick();
      },
      onHorizontalDragUpdate: (d) {
        final v = valueAt(d.localPosition.dx);
        onChanged(_dragging == 1 ? SheenRange(v < hi ? v : hi, hi) : SheenRange(lo, v > lo ? v : lo));
      },
      onHorizontalDragEnd: (_) {
        _dragging = 0;
        onChangeEnd?.call(widget.values);
      },
      child: SizedBox(
        height: SheenRangeHistogram.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: pad,
              right: pad,
              top: 0,
              height: barsHeight,
              child: ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [for (var i = 0; i < bins.length; i++) bar(i)],
                ),
              ),
            ),
            // the track on the baseline: lit between the knobs
            Positioned(
              left: pad,
              right: pad,
              top: barsHeight - 1.5,
              height: 3,
              child: ColoredBox(color: t.colors.track),
            ),
            Positioned(
              left: (xOf(lo) < xOf(hi) ? xOf(lo) : xOf(hi)),
              width: (xOf(hi) - xOf(lo)).abs(),
              top: barsHeight - 1.5,
              height: 3,
              child: ColoredBox(color: t.colors.accentText),
            ),
            knobAt(lo, w.lowLabel, true),
            knobAt(hi, w.highLabel, false),
          ],
        ),
      ),
    );
  }
}

/// A range of values, from [start] to [end], for [SheenRangeHistogram].
///
/// {@category Selection}
@immutable
class SheenRange {
  /// The range from [start] to [end].
  const SheenRange(this.start, this.end);

  /// The low end.
  final double start;

  /// The high end.
  final double end;

  @override
  bool operator ==(Object other) => other is SheenRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'SheenRange($start, $end)';
}
