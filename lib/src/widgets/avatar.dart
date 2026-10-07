import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A person's picture in a circle: the [image] when it loads, else their initials on a tint chosen by their [name]
/// (always the same tint for the same name), else a person glyph.
///
/// ```dart
/// SheenAvatar(name: 'Ada Lovelace', image: NetworkImage(user.photoUrl))
/// ```
///
/// {@category Content}
class SheenAvatar extends StatelessWidget {
  /// An avatar for [name], [size] points across.
  const SheenAvatar({super.key, this.name, this.image, this.size = 40, this.semanticLabel});

  /// The person's name, for the initials, the tint and (by default) screen readers.
  final String? name;

  /// The picture; the initials show while it loads and when it fails.
  final ImageProvider? image;

  /// The diameter.
  final double size;

  /// What a screen reader says; [name] when null.
  final String? semanticLabel;

  /// The first letters of the first two words of [name], in capitals.
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
    return words.map((w) => String.fromCharCode(w.runes.first).toUpperCase()).join();
  }

  /// The tint for [name], from [SheenTint.all] by a stable hash (FNV-1a), the same on every platform.
  static Color tintOf(String name) {
    var h = 0x811c9dc5;
    for (final c in name.trim().toLowerCase().codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
    }
    return SheenTint.all[h % SheenTint.all.length];
  }

  @override
  Widget build(BuildContext context) {
    final n = name?.trim() ?? '';
    final initials = initialsOf(n);
    final fallback = DecoratedBox(
      decoration: BoxDecoration(color: n.isEmpty ? context.sheen.colors.track : tintOf(n)),
      child: Center(
        child: initials.isEmpty
            ? SheenIcon(SheenIcons.userFill, size: size * .55, color: context.sheen.colors.textTertiary)
            : MediaQuery.withNoTextScaling(
                child: Text(
                  initials,
                  style: context.sheen.type.headline.copyWith(
                    fontSize: size * .38,
                    height: 1,
                    letterSpacing: 0,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
      ),
    );
    return Semantics(
      image: true,
      label: semanticLabel ?? (n.isEmpty ? null : n),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: image == null
              ? fallback
              : Image(
                  image: image!,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, sync) => frame == null && !sync ? fallback : child,
                  errorBuilder: (context, error, stack) => fallback,
                ),
        ),
      ),
    );
  }
}
