import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The result card while live prices load (D18): photo block, name and price bars, two text lines.
class SheenHotelCardSkeleton extends StatelessWidget {
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

/// An empty list or a dead end (C3 SheenEmptyState): glass icon circle, title, the app's own message. [compact] is the
/// small form used inside sheets and on the map.

/// A price on the map (C3 SheenPricePin): regular glass 30 high, 13/700; selected is prominent, 34 high, 14/700.
class SheenPricePin extends StatelessWidget {
  const SheenPricePin({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Defaults to [label]; screens pass the hotel name with the price.
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
