import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// One band of an equaliser: a vertical slider in decibels with its centre at 0 dB, the value above and the band's
/// name below. The fill grows from the centre up (boost) or down (cut). A screen reader moves it 1 dB at a time.
///
/// ```dart
/// Row(children: [
///   for (final b in bands)
///     Expanded(child: SheenBandSlider(label: b.name, value: b.gain, onChanged: (v) => eq.set(b, v))),
/// ])
/// ```
///
/// {@category Music}
class SheenBandSlider extends StatelessWidget {
  /// A band called [label] at [value] dB.
  const SheenBandSlider({
    super.key,
    required this.label,
    required this.value,
    this.min = -12,
    this.max = 12,
    this.onChanged,
    this.onChangeEnd,
  });

  /// The band's name ("Bass").
  final String label;

  /// The gain in dB.
  final double value;

  /// The lowest gain.
  final double min;

  /// The highest gain.
  final double max;

  /// Called while it moves.
  final ValueChanged<double>? onChanged;

  /// Called when a drag ends.
  final ValueChanged<double>? onChangeEnd;

  static String _db(double v) {
    final r = v.round();
    return r > 0 ? '+$r dB' : '$r dB';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final v = value.clamp(min, max);
    double fromDy(double dy, double h) => (max - (dy / h) * (max - min)).clamp(min, max);
    void set(double x) {
      if (x.round() != value.round()) HapticFeedback.selectionClick();
      onChanged?.call(x);
    }

    return Semantics(
      slider: true,
      label: label,
      value: _db(v),
      increasedValue: _db((v + 1).clamp(min, max)),
      decreasedValue: _db((v - 1).clamp(min, max)),
      onIncrease: onChanged == null ? null : () => onChanged!((v.roundToDouble() + 1).clamp(min, max)),
      onDecrease: onChanged == null ? null : () => onChanged!((v.roundToDouble() - 1).clamp(min, max)),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(_db(v), textDirection: TextDirection.ltr, style: t.type.caption.copyWith(color: t.colors.textSecondary, fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(height: SheenSpace.s),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  const knob = 11.0;
                  final h = c.maxHeight - 2 * knob;
                  final zeroY = knob + h * (max / (max - min));
                  final y = knob + h * ((max - v) / (max - min));
                  return GestureDetector(
                    key: const ValueKey('sheen-band-track'),
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: onChanged == null ? null : (d) => set(fromDy(d.localPosition.dy - knob, h)),
                    onVerticalDragEnd: onChangeEnd == null ? null : (_) => onChangeEnd!(value),
                    onTapDown: onChanged == null ? null : (d) => set(fromDy(d.localPosition.dy - knob, h)),
                    child: SizedBox(
                      width: SheenSpace.hit,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(top: knob, bottom: knob, child: Container(width: 6, decoration: BoxDecoration(color: t.colors.track, borderRadius: BorderRadius.circular(3)))),
                          Positioned(
                            top: y < zeroY ? y : zeroY,
                            height: (y - zeroY).abs(),
                            child: Container(width: 6, decoration: BoxDecoration(color: t.colors.accent, borderRadius: BorderRadius.circular(3))),
                          ),
                          Positioned(top: zeroY - .5, child: Container(width: 14, height: 1, color: t.colors.textTertiary)),
                          Positioned(
                            top: y - 11,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: SheenSpace.s),
            Text(label, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
