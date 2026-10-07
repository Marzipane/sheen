import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The three score badge sizes of C3: small (premium cards), medium (result cards), large (hotel rating).
enum SheenScoreSize { small, medium, large }

/// The guest score on the fill colour, white tabular figures (C3 SheenScoreBadge). The score string comes from the supplier.
/// Text grows with Dynamic Type up to 1.3× so the badge stays a badge.
class SheenScoreBadge extends StatelessWidget {
  const SheenScoreBadge(this.score, {super.key, this.size = SheenScoreSize.medium});

  final String score;
  final SheenScoreSize size;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final (h, minW, font, radius) = switch (size) {
      SheenScoreSize.small => (20.0, 30.0, 12.0, 6.0),
      SheenScoreSize.medium => (24.0, 34.0, 13.0, 8.0),
      SheenScoreSize.large => (40.0, 54.0, 20.0, 12.0),
    };
    return Container(
      constraints: BoxConstraints(minWidth: minW, minHeight: h),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(color: t.colors.accent, borderRadius: BorderRadius.circular(radius)),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          score,
          maxLines: 1,
          textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
          style: t.type.sized(t.type.price, font).copyWith(color: t.colors.onAccent, height: 1),
        ),
      ),
    );
  }
}
