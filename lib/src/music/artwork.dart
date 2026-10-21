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
  const SheenArtwork({
    super.key,
    this.image,
    this.size = 48,
    this.radius,
    this.round = false,
    this.book = false,
    this.semanticLabel,
  });

  /// The picture; `null` shows the placeholder.
  final ImageProvider? image;

  /// The side of the square (the height of a [book]).
  final double size;

  /// The corner radius; a sixth of [size] by default.
  final double? radius;

  /// A circle instead of a rounded square (artists).
  final bool round;

  /// A book cover instead of a square: 3:4, [size] tall, small corners and a shadow along the spine, so books read
  /// as books among songs and albums.
  final bool book;

  /// What a screen reader says; the cover is decorative when `null`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final r = round ? size / 2 : (radius ?? (book ? size / 14 : size / 6));
    final width = book ? size * .75 : size;
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
            width: width,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => placeholder,
            frameBuilder: (context, child, frame, sync) => sync || frame != null ? child : placeholder,
          );
    final body = SizedBox(
      width: width,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            picture,
            if (book)
              const Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: .07,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x55000000), Color(0x00000000)])),
                  ),
                ),
              ),
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
    return semanticLabel == null
        ? ExcludeSemantics(child: body)
        : Semantics(image: true, label: semanticLabel, child: body);
  }
}
