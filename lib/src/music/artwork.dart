import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// A song's or album's cover: a square [image] clipped to [radius], or a music glyph on a quiet ground when there is
/// no image or it fails to load. A hairline edge keeps a dark cover apart from a dark page.
///
/// ```dart
/// SheenArtwork(image: NetworkImage(track.cover), size: 48)
/// ```
///
/// {@category Music}
class SheenArtwork extends StatelessWidget {
  /// A cover of [size] with corners of [radius].
  const SheenArtwork({super.key, this.image, this.size = 48, this.radius, this.round = false, this.semanticLabel});

  /// The picture; `null` shows the placeholder.
  final ImageProvider? image;

  /// The side of the square.
  final double size;

  /// The corner radius; a sixth of [size] by default.
  final double? radius;

  /// A circle instead of a rounded square (artists).
  final bool round;

  /// What a screen reader says; the cover is decorative when `null`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final r = round ? size / 2 : (radius ?? size / 6);
    final placeholder = ColoredBox(
      color: t.colors.surfaceMuted,
      child: Center(
        child: SheenIcon(SheenIcons.music, size: size * .42, color: t.colors.textTertiary),
      ),
    );
    final picture = image == null
        ? placeholder
        : Image(
            image: image!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => placeholder,
            frameBuilder: (context, child, frame, sync) => sync || frame != null
                ? child
                : placeholder,
          );
    final body = SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            picture,
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r),
                border: Border.all(color: t.colors.separator, width: .5),
              ),
            ),
          ],
        ),
      ),
    );
    return semanticLabel == null ? ExcludeSemantics(child: body) : Semantics(image: true, label: semanticLabel, child: body);
  }
}
