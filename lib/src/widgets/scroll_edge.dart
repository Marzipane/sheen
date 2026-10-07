import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A soft fade under a floating bar instead of a bar background (C1 SheenScrollEdge, iOS 26+). Place it in a Stack
/// at the top (under the toolbar) or the bottom (under the tab or action bar).
///
/// The CSS also blurs the backdrop under a feathered mask. A ShaderMask does not feather a BackdropFilter in
/// Flutter (Impeller draws a hard edge where the blur ends, seen on the iPhone 17 Pro simulator, 3 Oct 2026), so
/// only the tint gradient is drawn, denser than the CSS tint to stand in for the blur: with the CSS's .55 midpoint, text
/// scrolled under a toolbar title stayed readable through it (Home, simulator, 3 Oct 2026).
class SheenScrollEdge extends StatelessWidget {
  const SheenScrollEdge.top({super.key, required this.height}) : top = true;
  const SheenScrollEdge.bottom({super.key, required this.height}) : top = false;

  final double height;
  final bool top;

  @override
  Widget build(BuildContext context) {
    final bg = context.sheen.colors.background;
    // CSS tint (plus a 10/8 px blur): top bg .9 → .55 at 55 % → 0; bottom bg 0 → .6 at 45 % → .85. Without the blur:
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
