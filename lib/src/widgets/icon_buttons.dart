import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A 44 pt glass circle with one glyph (C1 SheenIconButton). Regular on bars; clear only over photos; prominent
/// (fill colour) for the one confirming action, such as Done.
class SheenIconButton extends StatelessWidget {
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

  final String icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final SheenGlassVariant variant;
  final double size;
  final double iconSize;
  final double stroke;
  final bool filled;
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

/// One item of a [SheenButtonGroup].
class SheenButtonGroupItem {
  const SheenButtonGroupItem({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.filled = false,
    this.color,
  });
  final String icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool filled;
  final Color? color;
}

/// Related toolbar buttons sharing one glass capsule (HIG: group related items), e.g. Share + Save.
class SheenButtonGroup extends StatelessWidget {
  const SheenButtonGroup({super.key, required this.items, this.variant = SheenGlassVariant.regular, this.height = 44});

  final List<SheenButtonGroupItem> items;
  final SheenGlassVariant variant;
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
