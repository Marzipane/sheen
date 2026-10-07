import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The one prominent action of a view: a capsule of accent-tinted glass with a [SheenColors.onAccent] label.
///
/// It darkens while pressed. While [loading] it shows a spinner before the label and ignores taps; with [onPressed]
/// null it is disabled (40 % opacity).
/// ```dart
/// SheenPrimaryButton(label: 'Continue', expand: true, onPressed: next)
/// ```
/// {@category Buttons}
class SheenPrimaryButton extends StatelessWidget {
  /// A primary button labelled [label].
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

  /// The label.
  final String label;

  /// A smaller second line under the label, such as a price.
  final String? subLabel;

  /// Called on a tap; null disables the button.
  final VoidCallback? onPressed;

  /// Shows a spinner and ignores taps, for an action in progress.
  final bool loading;

  /// The height in points.
  final double height;

  /// Fills the available width.
  final bool expand;

  /// An icon before the label ([SheenIcons]).
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
            const Positioned.fill(
              child: DecoratedBox(
                decoration: ShapeDecoration(shape: StadiumBorder(), color: Color.fromRGBO(0, 0, 0, .18)),
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

/// A second choice next to a primary action: a tonal capsule ([SheenColors.surfaceMuted] in light, white 8 % in dark),
/// 48 points high, taller at large text sizes.
///
/// {@category Buttons}
class SheenSecondaryButton extends StatelessWidget {
  /// A secondary button labelled [label].
  const SheenSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.filledIcon = false,
  });

  /// The label.
  final String label;

  /// An icon before the label ([SheenIcons]).
  final String? icon;

  /// Draws [icon] as its filled glyph.
  final bool filledIcon;

  /// Called on a tap; null disables the button.
  final VoidCallback? onPressed;

  /// Fills the available width.
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
          color: t.isDark ? const Color.fromRGBO(255, 255, 255, .08) : t.colors.surfaceMuted,
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

/// A glass capsule that floats over content, such as a Map button over a list.
///
/// {@category Buttons}
class SheenFloatingButton extends StatelessWidget {
  /// A floating glass button labelled [label].
  const SheenFloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filledIcon = true,
  });

  /// The label.
  final String label;

  /// An icon before the label ([SheenIcons]).
  final String? icon;

  /// Draws [icon] as its filled glyph.
  final bool filledIcon;

  /// Called on a tap; null disables the button.
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

/// Accent-coloured text for a light action, such as "See all 9".
///
/// {@category Buttons}
class SheenTextLink extends StatelessWidget {
  /// A text link labelled [label].
  const SheenTextLink({super.key, required this.label, required this.onPressed, this.size = 16});

  /// The label.
  final String label;

  /// Called on a tap; null disables the link.
  final VoidCallback? onPressed;

  /// The font size in points.
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
