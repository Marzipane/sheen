import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// A check box with its label beside it, for an agreement or an opt-in in a form: the box fills with the accent when
/// ticked, its tick mirrors right to left, and a tap anywhere on the row asks for the other value.
///
/// [detail] is a line under the label, such as why the box is needed. [error] shows under both in the danger colour,
/// and outlines the box in that colour while it is empty.
///
/// {@category Inputs}
class SheenCheck extends StatelessWidget {
  /// A check box showing [value].
  const SheenCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.detail,
    this.error,
  });

  /// Whether the box is ticked.
  final bool value;

  /// Called with the new value; null disables the box.
  final ValueChanged<bool>? onChanged;

  /// The text beside the box, which a screen reader also says.
  final String label;

  /// A line under [label].
  final String? detail;

  /// A message under the label in the danger colour, such as a required box left empty.
  final String? error;

  void _toggle() {
    HapticFeedback.selectionClick();
    onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final c = t.colors;
    final duration = SheenMotion.reduced(context) ? Duration.zero : SheenMotion.snappySettle;
    final outline = error != null && !value ? c.danger : c.textTertiary;
    final enabled = onChanged != null;
    return Semantics(
      container: true,
      checked: value,
      enabled: enabled,
      label: [label, ?detail, ?error].join('\n'),
      onTap: enabled ? _toggle : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: Opacity(
            opacity: enabled ? 1 : .5,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SheenSpace.hit),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: SheenSpace.s),
                    child: AnimatedContainer(
                      key: const ValueKey('sheen-check-box'),
                      duration: duration,
                      width: SheenControlSize.check,
                      height: SheenControlSize.check,
                      decoration: BoxDecoration(
                        color: value ? c.accent : null,
                        borderRadius: BorderRadius.circular(SheenRadius.check),
                        border: value ? null : Border.all(color: outline, width: SheenControlSize.checkOutline),
                      ),
                      child: value ? CustomPaint(painter: _Tick(c.onAccent, Directionality.of(context))) : null,
                    ),
                  ),
                  const SizedBox(width: SheenSpace.m),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: SheenSpace.s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: c.text),
                          ),
                          if (detail case final String d)
                            Text(d, style: t.type.footnote.copyWith(color: c.textSecondary)),
                          if (error case final String e) Text(e, style: t.type.footnote.copyWith(color: c.danger)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The tick, its short arm at the start, mirrored right to left.
class _Tick extends CustomPainter {
  const _Tick(this.color, this.direction);

  final Color color;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (direction == TextDirection.rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final path = Path()
      ..moveTo(size.width * .27, size.height * .52)
      ..lineTo(size.width * .44, size.height * .68)
      ..lineTo(size.width * .74, size.height * .34);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = SheenControlSize.checkMark
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Tick old) => old.color != color || old.direction != direction;
}
