import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The sizes of a [SheenScoreBadge].
///
/// {@category Travel}
enum SheenScoreSize {
  /// 20 points high, for featured cards.
  small,

  /// For result cards.
  medium,

  /// For a hotel's page.
  large,
}

/// A guest score on the accent colour in tabular figures, such as "9.1". Its text grows with the user's text size up to
/// 1.3 times, so the badge stays a badge.
///
/// {@category Travel}
class SheenScoreBadge extends StatelessWidget {
  /// A badge showing [score].
  const SheenScoreBadge(this.score, {super.key, this.size = SheenScoreSize.medium});

  /// The score, formatted.
  final String score;

  /// The badge size.
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
