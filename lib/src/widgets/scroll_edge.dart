import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A soft fade of the page background under a floating bar, where a classic app would draw a bar background (the iOS 26
/// scroll edge effect). Place it in a `Stack` at the top (under a toolbar) or the bottom (under a tab or action bar).
///
/// Only a gradient is drawn, no blur: Flutter cannot feather the edge of a backdrop blur (Impeller draws a hard edge
/// where it ends), so the gradient is a little denser instead, which keeps text scrolled under a title readable.
///
/// {@category Layout}
class SheenScrollEdge extends StatelessWidget {
  /// A fade at the top of a `Stack`, [height] points tall.
  const SheenScrollEdge.top({super.key, required this.height}) : top = true;

  /// A fade at the bottom of a `Stack`, [height] points tall.
  const SheenScrollEdge.bottom({super.key, required this.height}) : top = false;

  /// The height of the fade.
  final double height;

  /// Whether the fade sits at the top.
  final bool top;

  @override
  Widget build(BuildContext context) {
    final bg = context.sheen.colors.background;
    // denser than a blurred edge would need, to stand in for the blur
    final colors = top
        ? [bg.withValues(alpha: .96), bg.withValues(alpha: .86), bg.withValues(alpha: 0)]
        : [bg.withValues(alpha: 0), bg.withValues(alpha: .72), bg.withValues(alpha: .94)];
    final stops = top ? const [0.0, .6, 1.0] : const [0.0, .45, 1.0];
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      height: height,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
                stops: stops,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
