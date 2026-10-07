import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Total for the stay first, per night second (C3 SheenPriceBlock). All strings arrive formatted, in the user's currency.
class SheenPriceBlock extends StatelessWidget {
  const SheenPriceBlock({super.key, required this.total, required this.caption, this.perNight});

  /// "AED 1,448.00": 20/700 tabular.
  final String total;

  /// "Total for 2 nights": 12 ink2 under the total.
  final String caption;

  /// "AED 724.00 a night": 13 ink2 at the end edge; left out when the supplier sends no nightly rate.
  final String? perNight;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(total, style: t.type.sized(t.type.price, 20).copyWith(color: t.colors.text, height: 1.25)),
              Text(caption, style: t.type.caption.copyWith(color: t.colors.textSecondary)),
            ],
          ),
        ),
        if (perNight != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 5),
            child: Text(
              perNight!,
              style: t.type.footnote.copyWith(
                color: t.colors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

/// The cancellation rule in one line (C3 SheenCancellationLine): a green check with the "free until" text, or an x-circle in
/// ink2 with the non-refundable text. The text is the app's own string with the supplier's date.
class SheenCancellationLine extends StatelessWidget {
  const SheenCancellationLine({super.key, required this.text, required this.refundable});

  final String text;
  final bool refundable;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final c = refundable ? t.colors.success : t.colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: refundable
              ? SheenIcon(SheenIcons.check, size: 15, stroke: 2.4, color: c)
              : SheenIcon(SheenIcons.xCircle, size: 15, stroke: 2, color: c),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(text, style: t.type.footnote.copyWith(color: c)),
        ),
      ],
    );
  }
}
