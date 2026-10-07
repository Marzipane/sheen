import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A count or a dot at the top-end corner of [child], in red with white figures, as iOS badges are: unread messages,
/// items in a cart.
///
/// A count of 0 hides the badge; past [max] it reads "99+". Screen readers hear [semanticLabel] (the count when null)
/// as the value of [child].
///
/// ```dart
/// SheenBadge(count: unread, child: SheenIconButton(icon: SheenIcons.bell, semanticLabel: 'Notifications', onTap: open))
/// ```
///
/// {@category Feedback}
class SheenBadge extends StatelessWidget {
  /// A count badge on [child].
  const SheenBadge({super.key, required this.child, required this.count, this.max = 99, this.semanticLabel})
    : dot = false;

  /// A dot badge on [child], for "something new" without a number.
  const SheenBadge.dot({super.key, required this.child, this.semanticLabel}) : count = 1, max = 99, dot = true;

  /// What the badge sits on.
  final Widget child;

  /// The number shown; 0 or less hides the badge.
  final int count;

  /// The largest number shown in full; more reads "[max]+".
  final int max;

  /// Whether the badge is a dot without a number.
  final bool dot;

  /// What a screen reader adds to [child]; the count when null.
  final String? semanticLabel;

  /// The badge colour.
  static const Color color = SheenTint.red;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    final t = context.sheen;
    final text = count > max ? '$max+' : '$count';
    final badge = dot
        ? SizedBox.square(
            key: const ValueKey('sheen-badge'),
            dimension: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: t.colors.background, width: 1.5),
              ),
            ),
          )
        : ConstrainedBox(
            key: const ValueKey('sheen-badge'),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18, maxHeight: 18),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: color,
                shape: StadiumBorder(side: BorderSide(color: t.colors.background, width: 1.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Center(
                  widthFactor: 1,
                  child: MediaQuery.withNoTextScaling(
                    child: Text(
                      text,
                      style: t.type.caption.copyWith(
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFFFFF),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
    return Semantics(
      value: semanticLabel ?? (dot ? null : text),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          PositionedDirectional(
            top: dot ? -2 : -6,
            end: dot ? -2 : -8,
            child: ExcludeSemantics(child: badge),
          ),
        ],
      ),
    );
  }
}
