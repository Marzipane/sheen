import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A floating toolbar row: [leading], [center] and [trailing], 10 points apart, with no bar behind them (pair it with
/// [SheenScrollEdge]).
///
/// The centre is usually a [SheenToolbarSummary] or a [SheenToolbarTitle]; the sides hold [SheenIconButton]s, a
/// [SheenButtonGroup] or a [SheenCountdownPill].
/// ```dart
/// SheenToolbar(
///   leading: SheenIconButton(icon: SheenIcons.back, semanticLabel: 'Back', onTap: pop),
///   center: const SheenToolbarTitle('Settings'),
/// )
/// ```
/// {@category Navigation}
class SheenToolbar extends StatelessWidget {
  /// A toolbar row.
  const SheenToolbar({
    super.key,
    this.leading,
    this.center,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// The start-side item.
  final Widget? leading;

  /// The middle item; it takes the remaining width.
  final Widget? center;

  /// The end-side item.
  final Widget? trailing;

  /// Space around the row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (leading != null) leading! else const SizedBox(width: 44),
            const SizedBox(width: 10),
            Expanded(child: Center(child: center ?? const SizedBox())),
            const SizedBox(width: 10),
            if (trailing != null) trailing! else const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}

/// A tappable glass capsule that sums up a search or a filter ("Lisbon" over "20–22 Oct · 2 adults") and opens it for
/// editing.
///
/// {@category Navigation}
class SheenToolbarSummary extends StatelessWidget {
  /// A summary capsule.
  const SheenToolbarSummary({super.key, required this.title, this.subtitle, this.onTap});

  /// The first line.
  final String title;

  /// The second line.
  final String? subtitle;

  /// Called on a tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onTap,
      minSize: 0,
      semanticLabel: subtitle == null ? title : '$title, $subtitle',
      child: SheenGlass(
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: t.colors.text, height: 1.2),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.type.caption.copyWith(color: t.colors.textSecondary, height: 1.2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An inline toolbar title (17 points, semibold).
///
/// {@category Navigation}
class SheenToolbarTitle extends StatelessWidget {
  /// A title showing [text].
  const SheenToolbarTitle(this.text, {super.key});

  /// The title.
  final String text;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    return Semantics(
      header: true,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.type.headline.copyWith(color: t.colors.text),
      ),
    );
  }
}
