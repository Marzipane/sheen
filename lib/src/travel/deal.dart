import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A deal's mark: a red capsule with its words, such as "−15%", for the corner of a photo or beside a price.
///
/// The fill is the theme's danger colour in light themes and a deeper red in dark ones, so the white words keep their
/// contrast on both.
///
/// {@category Travel}
class SheenDealBadge extends StatelessWidget {
  /// A badge reading [label].
  const SheenDealBadge(this.label, {super.key, this.small = false});

  /// The words, such as "−15%".
  final String label;

  /// The 22-point size for small cards; 28 points otherwise.
  final bool small;

  /// The fill for [theme].
  static Color fillOf(SheenThemeData theme) => theme.isDark ? const Color(0xFFD93036) : theme.colors.danger;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Container(
      constraints: BoxConstraints(minHeight: small ? 22 : 28),
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 10, vertical: 2),
      decoration: BoxDecoration(color: fillOf(t), borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: t.type
            .sized(t.type.footnote, small ? 11 : 12.5)
            .copyWith(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w800, height: 1.2),
      ),
    );
  }
}

/// The price before a deal, struck through in the secondary colour. Show it only next to the price with the deal, and
/// only when it is the same stay without the deal (a like-for-like saving).
///
/// {@category Travel}
class SheenWasPrice extends StatelessWidget {
  /// The struck [price].
  const SheenWasPrice(this.price, {super.key, this.size = 13});

  /// The price, formatted.
  final String price;

  /// The font size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Text(price, maxLines: 1, style: wasStyle(t, size));
  }

  /// The struck style, for a span inside a longer line.
  static TextStyle wasStyle(SheenThemeData t, double size) => t.type
      .sized(t.type.price, size)
      .copyWith(
        color: t.colors.textSecondary,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        decorationColor: t.colors.textSecondary,
        decorationThickness: 1.5,
      );
}
