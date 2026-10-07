import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The one prominent action of a view: glass tinted with the fill colour, white label (C2 SheenPrimaryButton).
/// States: default, pressed (darker), loading (spinner before the label, taps ignored), disabled (40 %).
class SheenPrimaryButton extends StatelessWidget {
  const SheenPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subLabel,
    this.loading = false,
    this.height = 50,
    this.expand = false,
    this.icon,
  });

  final String label;
  final String? subLabel;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final bool expand;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final enabled = onPressed != null && !loading;
    final text = t.type.headline.copyWith(color: t.colors.onAccent);
    Widget content(bool pressed) {
      final labelWidget = subLabel == null
          ? Text(label, style: text, maxLines: 1, overflow: TextOverflow.ellipsis)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: text, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  subLabel!,
                  style: t.type.caption.copyWith(
                    color: t.colors.onAccent.withValues(alpha: .85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
      return Stack(
        children: [
          SheenGlass(
            variant: SheenGlassVariant.prominent,
            // [height] is the minimum: with a large text size the button grows instead of clipping its label.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height, minWidth: expand ? double.infinity : 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loading) ...[const SheenSpinner(), const SizedBox(width: 8)],
                    if (icon != null && !loading) ...[
                      SheenIcon(icon!, size: 19, stroke: 2, color: t.colors.onAccent),
                      const SizedBox(width: 8),
                    ],
                    Flexible(child: labelWidget),
                  ],
                ),
              ),
            ),
          ),
          // Pressed: CSS filter brightness(.82) on the fill.
          if (pressed)
            Positioned.fill(
              child: DecoratedBox(
                decoration: ShapeDecoration(shape: const StadiumBorder(), color: Color.fromRGBO(0, 0, 0, .18)),
              ),
            ),
        ],
      );
    }

    return Opacity(
      opacity: onPressed == null ? .4 : 1,
      child: SheenPressable(
        onTap: enabled ? onPressed : null,
        semanticLabel: label,
        minSize: 0,
        builder: (c, pressed) => content(pressed && enabled),
      ),
    );
  }
}

/// A second choice next to a primary action: tonal (white 8 % on dark, the s2 surface on light), 48 high (more with a
/// large text size).
class SheenSecondaryButton extends StatelessWidget {
  const SheenSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.filledIcon = false,
  });

  final String label;
  final String? icon;
  final bool filledIcon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onPressed,
      semanticLabel: label,
      minSize: 0,
      child: Container(
        constraints: BoxConstraints(minHeight: 48, minWidth: expand ? double.infinity : 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: t.isDark ? Color.fromRGBO(255, 255, 255, .08) : t.colors.surfaceMuted,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              SheenIcon(icon!, size: 20, stroke: 1.9, filled: filledIcon, color: t.colors.text),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: t.type.sized(t.type.headline, 16).copyWith(color: t.colors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glass capsule floating over content (the Map button over results).
class SheenFloatingButton extends StatelessWidget {
  const SheenFloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filledIcon = true,
  });

  final String label;
  final String? icon;
  final bool filledIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onPressed,
      semanticLabel: label,
      minSize: 0,
      child: SheenGlass(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  SheenIcon(icon!, size: 18, filled: filledIcon, color: t.colors.text),
                  const SizedBox(width: 8),
                ],
                Text(label, style: t.type.sized(t.type.headline, 16).copyWith(color: t.colors.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Accent text for a light action ("See all 9").
class SheenTextLink extends StatelessWidget {
  const SheenTextLink({super.key, required this.label, required this.onPressed, this.size = 16});

  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onPressed,
      semanticLabel: label,
      child: Text(label, style: t.type.sized(t.type.headline, size).copyWith(color: t.colors.accentText)),
    );
  }
}
