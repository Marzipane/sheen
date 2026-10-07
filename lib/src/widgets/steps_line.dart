import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Room → Guests → Payment (C3 SheenStepsLine). Done = a check on fill; current = its number on fill; next = its number
/// on s3 with a muted label. Joining lines are 2 pt, accent once the step before is done.
///
/// When the labels do not fit (large Dynamic Type, narrow phones) only the current step keeps its label.
class SheenStepsLine extends StatelessWidget {
  const SheenStepsLine({super.key, required this.steps, required this.current});

  final List<String> steps;
  final int current;

  static const double _dot = 20, _dotGap = 6, _gap = 8, _minLine = 12;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final label = t.type.footnote.copyWith(fontWeight: FontWeight.w600, height: 1.2);
    final scaler = MediaQuery.textScalerOf(context);
    final dir = Directionality.of(context);
    final inherited = DefaultTextStyle.of(context).style;
    return LayoutBuilder(
      builder: (context, box) {
        double width(String s) {
          // Measure with the inherited style too (font family), exactly as the Text below will lay out.
          final p = TextPainter(
            text: TextSpan(text: s, style: inherited.merge(label)),
            textDirection: dir,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final w = p.width;
          p.dispose();
          return w;
        }

        final n = steps.length;
        final fixed = n * _dot + (n - 1) * (2 * _gap + _minLine);
        final all = fixed + steps.fold<double>(0, (a, s) => a + _dotGap + width(s));
        final compact = all > box.maxWidth;

        Widget step(int i) {
          final done = i < current, on = i == current;
          final circle = Container(
            width: _dot,
            height: _dot,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done || on ? t.colors.accent : t.colors.track),
            child: done
                ? SheenIcon(SheenIcons.check, size: 12, stroke: 3, color: t.colors.onAccent)
                : Text(
                    '${i + 1}',
                    textScaler: TextScaler.noScaling,
                    style: t.type
                        .sized(label, 11)
                        .copyWith(height: 1, color: on ? t.colors.onAccent : t.colors.textSecondary),
                  ),
          );
          final showLabel = !compact || on;
          final text = Text(
            steps[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: label.copyWith(color: i <= current ? t.colors.text : t.colors.textSecondary),
          );
          return Semantics(
            container: true,
            selected: on,
            label: showLabel ? null : steps[i],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(child: circle),
                if (showLabel) ...[
                  const SizedBox(width: _dotGap),
                  if (compact)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: (box.maxWidth - fixed - _dotGap).clamp(0, double.infinity)),
                      child: text,
                    )
                  else
                    text,
                ],
              ],
            ),
          );
        }

        Widget line(int i) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: _gap),
            // the line into the current step is lit too (boards D10, D11)
            decoration: BoxDecoration(
              color: i <= current ? t.colors.accentText : t.colors.track,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );

        return Row(
          children: [
            for (var i = 0; i < n; i++) ...[if (i > 0) line(i), step(i)],
          ],
        );
      },
    );
  }
}
