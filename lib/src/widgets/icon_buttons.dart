import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A 44-point glass circle with one glyph.
///
/// Use regular glass on bars, clear glass only over photos, and prominent (accent) glass for the one confirming action,
/// such as Done. [semanticLabel] is required: an icon alone says nothing to a screen reader.
/// ```dart
/// SheenIconButton(icon: SheenIcons.share, semanticLabel: 'Share', onTap: share)
/// ```
/// {@category Buttons}
class SheenIconButton extends StatelessWidget {
  /// A glass circle showing [icon].
  const SheenIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.variant = SheenGlassVariant.regular,
    this.size = 44,
    this.iconSize = 21,
    this.stroke = 2,
    this.filled = false,
    this.color,
  });

  /// The glyph ([SheenIcons]).
  final String icon;

  /// What a screen reader says for the button.
  final String semanticLabel;

  /// Called on a tap; null disables the button.
  final VoidCallback? onTap;

  /// The kind of glass.
  final SheenGlassVariant variant;

  /// The diameter in points.
  final double size;

  /// The glyph size in points.
  final double iconSize;

  /// The glyph's stroke width.
  final double stroke;

  /// Draws the filled glyph.
  final bool filled;

  /// The glyph colour; the theme's text colour (or the label colour on prominent glass) when null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final c = color ?? (variant == SheenGlassVariant.regular ? t.colors.text : t.colors.onAccent);
    final button = SheenPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      minSize: 0,
      child: SheenGlass(
        variant: variant,
        shape: const CircleBorder(),
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: SheenIcon(icon, size: iconSize, stroke: stroke, filled: filled, color: c),
          ),
        ),
      ),
    );
    return onTap == null ? Opacity(opacity: .4, child: button) : button;
  }
}

/// One button of a [SheenButtonGroup].
///
/// {@category Buttons}
class SheenButtonGroupItem {
  /// A group button showing [icon].
  const SheenButtonGroupItem({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.filled = false,
    this.color,
  });

  /// The glyph ([SheenIcons]).
  final String icon;

  /// What a screen reader says for the button.
  final String semanticLabel;

  /// Called on a tap; null disables the button.
  final VoidCallback? onTap;

  /// Draws the filled glyph.
  final bool filled;

  /// The glyph colour; the theme's text colour when null.
  final Color? color;
}

/// Related toolbar buttons sharing one glass capsule, such as Share and Save (Apple's guidelines: group related items).
///
/// {@category Buttons}
class SheenButtonGroup extends StatelessWidget {
  /// A capsule holding [items].
  const SheenButtonGroup({super.key, required this.items, this.variant = SheenGlassVariant.regular, this.height = 44});

  /// The buttons, in reading order.
  final List<SheenButtonGroupItem> items;

  /// The kind of glass.
  final SheenGlassVariant variant;

  /// The height in points.
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final def = variant == SheenGlassVariant.regular ? t.colors.text : t.colors.onAccent;
    return SheenGlass(
      variant: variant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in items)
              SheenPressable(
                onTap: i.onTap,
                semanticLabel: i.semanticLabel,
                child: SizedBox.square(
                  dimension: height,
                  child: Center(
                    child: SheenIcon(i.icon, size: 20, stroke: 2, filled: i.filled, color: i.color ?? def),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
