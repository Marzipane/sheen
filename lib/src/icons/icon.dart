import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'icon_data.dart';

/// An icon from sheen's set, drawn from SVG paths on a 24 × 24 grid.
///
/// Name it with a [SheenIcons] constant. Stroke icons draw with [stroke] width and round caps; a name ending in
/// `.fill` (or [filled] true) draws the solid glyph. The colour defaults to the ambient `IconTheme` colour, which
/// [SheenScope] sets to the theme's text colour. Arrows that point along the reading direction (back, chevron)
/// mirror in right-to-left text.
///
/// ```dart
/// const SheenIcon(SheenIcons.search, size: 18)
/// const SheenIcon(SheenIcons.heartFill, color: Color(0xFFE5484D), semanticLabel: 'Saved')
/// ```
///
/// {@category Foundation}
class SheenIcon extends StatelessWidget {
  /// The icon called [name], [size] points square.
  const SheenIcon(
    this.name, {
    super.key,
    this.size = 22,
    this.color,
    this.stroke = 1.8,
    this.filled = false,
    this.semanticLabel,
  });

  /// The icon's name: a [SheenIcons] constant.
  final String name;

  /// The width and height in points.
  final double size;

  /// The colour; the ambient `IconTheme` colour when null.
  final Color? color;

  /// The stroke width of stroke icons, in points on the 24-point grid.
  final double stroke;

  /// Draws the filled glyph of [name] (the same as naming it `name.fill`).
  final bool filled;

  /// What a screen reader says; null hides the icon from screen readers (right for icons next to a label).
  final String? semanticLabel;

  /// The glyphs that point along the reading direction and mirror in right-to-left text.
  static const Set<String> directional = {'back', 'chevron', 'sign-out'};

  bool get _filled => filled || name.endsWith('.fill');

  String get _key => name.endsWith('.fill') ? name.substring(0, name.length - 5) : name;

  /// The SVG document of this glyph, drawn in black; the colour is applied with a colour filter.
  String svg() {
    final inner = _filled ? sheenFilledIcons[_key] : sheenStrokeIcons[_key];
    assert(inner != null, 'Unknown sheen icon "$name"${_filled && !name.endsWith('.fill') ? ' (filled)' : ''}');
    if (inner == null) return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"></svg>';
    return _filled
        ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#000">$inner</svg>'
        : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" '
              'stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    Widget glyph = SvgPicture.string(
      svg(),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
    if (directional.contains(_key) && Directionality.maybeOf(context) == TextDirection.rtl) {
      glyph = Transform.flip(flipX: true, child: glyph);
    }
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: semanticLabel == null ? ExcludeSemantics(child: glyph) : glyph,
      ),
    );
  }
}
