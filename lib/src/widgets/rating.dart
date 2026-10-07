import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The hotel's star class: [count] filled stars in the star colour, read as one label.
class SheenStarRating extends StatelessWidget {
  const SheenStarRating({super.key, required this.count, required this.semanticLabel, this.size = 12});

  final int count;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.sheen.colors.rating;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 1),
            SheenIcon(SheenIcons.star, size: size, filled: true, color: c),
          ],
        ],
      ),
    );
  }
}

/// A sub-score: label and value on one line, a 6 pt bar below (s3 track, accent value). [fraction] is 0…1.
class SheenScoreBar extends StatelessWidget {
  const SheenScoreBar({super.key, required this.label, required this.value, required this.fraction});

  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.type.footnote.copyWith(color: t.colors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: t.type.footnote.copyWith(
                color: t.colors.text,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: ColoredBox(
              color: t.colors.track,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: fraction.clamp(0, 1),
                child: DecoratedBox(
                  key: const ValueKey('score-bar-fill'),
                  decoration: BoxDecoration(color: t.colors.accentText, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
