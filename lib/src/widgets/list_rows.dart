import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Inset grouped rows, as in iOS Settings: one rounded group with hairline separators between the rows.
/// ```dart
/// SheenListGroup(children: [
///   SheenListRow(title: 'Notifications', icon: SheenIcons.bell, iconColor: SheenTint.red, onTap: openNotifications),
///   SheenListRow(title: 'Language', value: 'English', onTap: openLanguage),
/// ])
/// ```
/// {@category Content}
class SheenListGroup extends StatelessWidget {
  /// A group of [children].
  const SheenListGroup({super.key, required this.children, this.color});

  /// The rows.
  final List<Widget> children;

  /// The group's ground; by default s1 on the page ground (as cards) and s2 inside a sheet ([SheenNested]).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sep = context.sheen.colors.separator;
    // SheenCard picks the level's surface (s1 on the page, s2 flat inside a sheet)
    return SheenCard(
      color: color,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: .5, child: ColoredBox(color: sep)),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One row of a [SheenListGroup]: an optional 30-point glyph tile in [iconColor], the title with an optional [subtitle]
/// under it, an optional [value], then [trailing] (a switch) or, for a tappable row, a chevron that mirrors in
/// right-to-left text. At least 50 points high.
///
/// {@category Content}
class SheenListRow extends StatelessWidget {
  /// A row titled [title].
  const SheenListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.value,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });

  /// The title.
  final String title;

  /// A second line under the title.
  final String? subtitle;

  /// A glyph on a coloured tile at the start ([SheenIcons]).
  final String? icon;

  /// The tile colour; [SheenTint] has the usual ones.
  final Color? iconColor;

  /// A value before the chevron, such as the current setting.
  final String? value;

  /// A widget at the end, such as a [SheenSwitch]; replaces the chevron.
  final Widget? trailing;

  /// Called when the row is tapped; null makes the row static.
  final VoidCallback? onTap;

  /// What a screen reader says; the title, subtitle and value when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    Widget row(bool pressed) => LayoutBuilder(
      builder: (context, box) {
        final valueMax = box.maxWidth * .45;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: pressed ? t.colors.text.withValues(alpha: .06) : null),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor ?? t.colors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SheenIcon(icon!, size: 18, stroke: 2, color: const Color(0xFFFFFFFF)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: subtitle == null
                    ? Text(title, style: t.type.body.copyWith(color: t.colors.text))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title, style: t.type.body.copyWith(color: t.colors.text)),
                          Text(subtitle!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
                        ],
                      ),
              ),
              if (value != null) ...[
                const SizedBox(width: 12),
                // At most 45 % of the row, so a long value ellipsizes before the title does.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: valueMax),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.type.body.copyWith(color: t.colors.textSecondary),
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: 12),
                SheenIcon(SheenIcons.chevron, size: 16, stroke: 2, color: t.colors.textTertiary),
              ],
            ],
          ),
        );
      },
    );
    if (onTap == null) return row(false);
    return SheenPressable(
      onTap: onTap,
      pressedScale: 1,
      semanticLabel: semanticLabel ?? [title, ?subtitle, ?value].join(', '),
      builder: (context, pressed) => ExcludeSemantics(child: row(pressed)),
    );
  }
}
