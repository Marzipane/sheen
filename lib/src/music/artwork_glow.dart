import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/src/glass/color_matrix.dart';

/// The ground of a player or an album page: the cover, blurred and saturated into a soft glow, fading into the page's
/// background, so the glass above takes the song's colours.
///
/// A new [image] cross-fades in. With Reduce Transparency (or high contrast) the glow is a flat [fallback] tint; without
/// an image, only the background shows.
///
/// ```dart
/// SheenArtworkGlow(image: NetworkImage(track.cover), child: playerBody)
/// ```
///
/// {@category Music}
class SheenArtworkGlow extends StatelessWidget {
  /// A glow of [image] behind [child].
  const SheenArtworkGlow({super.key, this.image, this.fallback, this.strength, required this.child});

  /// The cover.
  final ImageProvider? image;

  /// The flat tint used when transparency is reduced; the theme's muted surface by default.
  final Color? fallback;

  /// How strongly the glow shows, from 0 to 1; stronger on dark grounds by default.
  final double? strength;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final dark = t.brightness == Brightness.dark;
    final flat = t.reduceTransparency || (MediaQuery.maybeHighContrastOf(context) ?? false);
    final bg = t.colors.background;
    final Widget glow;
    if (image == null) {
      glow = const SizedBox.expand();
    } else if (flat) {
      glow = ColoredBox(color: fallback ?? t.colors.surfaceMuted);
    } else {
      glow = AnimatedSwitcher(
        duration: SheenMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 600),
        child: SizedBox.expand(
          key: ValueKey(image),
          child: Opacity(
            opacity: strength ?? (dark ? .7 : .45),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.compose(
                outer: ui.ColorFilter.matrix(sheenColorMatrix(saturation: 1.5, brightness: dark ? .85 : 1.05)),
                inner: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60, tileMode: TileMode.mirror),
              ),
              child: Transform.scale(
                scale: 1.4,
                child: Image(image: image!, fit: BoxFit.cover, gaplessPlayback: true, errorBuilder: (_, _, _) => const SizedBox()),
              ),
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(child: ClipRect(child: glow)),
          // Fades the glow into the page towards the foot, where lists and bars sit.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bg.withValues(alpha: 0), bg.withValues(alpha: dark ? .35 : .5), bg.withValues(alpha: .9)],
                  stops: const [0, .6, 1],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
