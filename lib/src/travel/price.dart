import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A price with the total first and the price per night second. All strings arrive formatted, in the user's currency.
///
/// {@category Travel}
class SheenPriceBlock extends StatelessWidget {
  /// A price block for [total].
  const SheenPriceBlock({super.key, required this.total, required this.caption, this.perNight});

  /// The total, formatted ("€ 1,448").
  final String total;

  /// A line under the total, such as "Total for 2 nights".
  final String caption;

  /// The price per night at the end edge, such as "€ 724 a night".
  final String? perNight;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final totalText = Text(total, style: t.type.sized(t.type.price, 20).copyWith(color: t.colors.text, height: 1.25));
    final captionText = Text(caption, style: t.type.caption.copyWith(color: t.colors.textSecondary));
    final nightText = perNight == null
        ? null
        : Text(
            perNight!,
            style: t.type.footnote.copyWith(
              color: t.colors.textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          );
    // at large text sizes the nightly price goes under the total rather than beside it
    if (MediaQuery.textScalerOf(context).scale(10) > 13) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [totalText, captionText, ?nightText],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [totalText, captionText],
          ),
        ),
        if (nightText != null) Padding(padding: const EdgeInsetsDirectional.only(start: 12, top: 5), child: nightText),
      ],
    );
  }
}

/// The cancellation terms in one line: a check in the success colour with free-cancellation text, or a crossed circle
/// with non-refundable text.
///
/// {@category Travel}
class SheenCancellationLine extends StatelessWidget {
  /// A line showing [text].
  const SheenCancellationLine({super.key, required this.text, required this.refundable});

  /// The terms, such as "Free cancellation until 12 Oct".
  final String text;

  /// Whether the booking can be cancelled for free.
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

/// A price on a map drawn by Flutter: a 30-point glass capsule; selected, a 34-point prominent one. For native map
/// markers, use [renderSheenPricePin].
///
/// {@category Travel}
class SheenPricePin extends StatelessWidget {
  /// A pin showing [label].
  const SheenPricePin({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  /// The price, formatted.
  final String label;

  /// Whether this pin is the selected one.
  final bool selected;

  /// Called when the pin is tapped.
  final VoidCallback onTap;

  /// What a screen reader says; [label] when null (pass the place name with the price).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: selected ? 34 : 30),
        child: SheenGlass(
          variant: selected ? SheenGlassVariant.prominent : SheenGlassVariant.regular,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: selected ? 13 : 11),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5),
                style: t.type
                    .sized(t.type.price, selected ? 14 : 13)
                    .copyWith(height: 1.1, color: selected ? t.colors.onAccent : t.colors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
