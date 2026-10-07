import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The tab bar of a wide window (iPadOS style): the tabs at the top centre, glyph and label side by side on one glass
/// capsule with the selected tab on a lens, and, when [onSearch] is given, search as its own circle at the end.
///
/// Choose between it and [SheenTabBar] with [SheenLayout.isWide].
///
/// {@category Navigation}
class SheenTopTabBar extends StatelessWidget {
  /// A top tab bar showing [items].
  const SheenTopTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    this.onSearch,
    this.searchLabel,
    this.searchActive = false,
  });

  /// The tabs.
  final List<SheenTabItem> items;

  /// The selected tab.
  final int index;

  /// Called with the tapped tab.
  final ValueChanged<int> onSelect;

  /// Shows the search circle and is called when it is tapped.
  final VoidCallback? onSearch;

  /// The search circle's label for screen readers; [SheenStrings.search] when null.
  final String? searchLabel;

  /// Search is the current destination: the search circle carries the lens, no tab does.
  final bool searchActive;

  /// The bar height in points.
  static const double height = 48;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  Widget _build(BuildContext context) {
    final t = context.sheen;
    final reduced = SheenMotion.reduced(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheenGlass(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  SheenPressable(
                    onTap: () {
                      if (i != index) HapticFeedback.selectionClick();
                      onSelect(i);
                    },
                    semanticLabel: items[i].label,
                    selected: i == index && !searchActive,
                    minSize: 0,
                    child: AnimatedContainer(
                      duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
                      curve: SheenMotion.easeOut,
                      height: height - 8,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (i == index && !searchActive) const Positioned.fill(child: SheenLens()),
                          ExcludeSemantics(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SheenIcon(
                                  items[i].icon,
                                  filled: true,
                                  size: 19,
                                  color: i == index && !searchActive ? t.colors.accentText : t.colors.text,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  items[i].label,
                                  maxLines: 1,
                                  style: t.type
                                      .sized(t.type.subhead, 15)
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: i == index && !searchActive ? t.colors.accentText : t.colors.text,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (onSearch != null) ...[
          const SizedBox(width: 10),
          SheenPressable(
            onTap: onSearch,
            semanticLabel: searchLabel ?? SheenStrings.of(context).search,
            selected: searchActive,
            minSize: 0,
            child: SheenGlass(
              shape: const CircleBorder(),
              child: SizedBox.square(
                dimension: height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (searchActive) const Positioned.fill(child: SheenLens(shape: CircleBorder())),
                    SheenIcon(
                      SheenIcons.search,
                      size: 21,
                      stroke: 2.2,
                      color: searchActive ? t.colors.accentText : t.colors.text,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
