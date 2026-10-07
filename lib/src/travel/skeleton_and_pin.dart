import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A [SheenHotelCard] while results load: a photo block, name and price bars and two text lines, shimmering (still with
/// Reduce Motion).
///
/// {@category Travel}
class SheenHotelCardSkeleton extends StatelessWidget {
  /// A loading placeholder for a hotel card.
  const SheenHotelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SheenCard(
      child: SizedBox(
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheenSkeleton(height: 196, radius: 0),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: SheenSkeleton(width: 170, height: 18)),
                      SizedBox(width: 12),
                      Flexible(child: SheenSkeleton(width: 110, height: 18)),
                    ],
                  ),
                  SizedBox(height: 10),
                  SheenSkeleton(width: 130, height: 13),
                  SizedBox(height: 12),
                  SheenSkeleton(width: 210, height: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
