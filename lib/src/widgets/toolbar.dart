import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A floating toolbar row (C1 SheenToolbar): leading, centre and trailing, 10 pt apart. The centre is a
/// [SheenToolbarSummary] capsule or a [SheenToolbarTitle]; leading and trailing are glass buttons, groups or a hold timer.
class SheenToolbar extends StatelessWidget {
  const SheenToolbar({
    super.key,
    this.leading,
    this.center,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;
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

/// A tappable glass capsule that sums up the search ("Dubai / 20–22 Oct · 2 adults") and opens it for editing.
class SheenToolbarSummary extends StatelessWidget {
  const SheenToolbarSummary({super.key, required this.title, this.subtitle, this.onTap});

  final String title;
  final String? subtitle;
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

/// An inline toolbar title (17/600).
class SheenToolbarTitle extends StatelessWidget {
  const SheenToolbarTitle(this.text, {super.key});
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
