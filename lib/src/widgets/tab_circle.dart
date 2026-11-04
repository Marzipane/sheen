import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/src/icons/icon_data.dart';

/// The colour of the glyph on the circle beside the tabs. On prominent glass it is the label colour in both states,
/// because accent ink on accent glass would vanish.
///
/// {@category Navigation}
Color tabCircleInk(SheenColors colors, SheenGlassVariant variant) =>
    variant == SheenGlassVariant.prominent ? colors.onAccent : colors.text;

/// [tabCircleInk] while the circle is the current destination.
///
/// {@category Navigation}
Color tabCircleActiveInk(SheenColors colors, SheenGlassVariant variant) =>
    variant == SheenGlassVariant.prominent ? colors.onAccent : colors.accentText;

/// What marks the circle as the current destination: the lens on regular glass; on prominent glass, where the lens
/// barely shows, a ring in the label colour.
///
/// {@category Navigation}
Widget tabCircleMark(SheenColors colors, SheenGlassVariant variant) {
  if (variant != SheenGlassVariant.prominent) return const SheenLens(shape: CircleBorder());
  return Padding(
    padding: const EdgeInsets.all(SheenSpace.xs),
    child: DecoratedBox(
      key: const ValueKey('tab-circle-ring'),
      decoration: ShapeDecoration(
        shape: CircleBorder(side: BorderSide(color: colors.onAccent, width: 2)),
      ),
    ),
  );
}

bool _filledAllowed(SheenTabItem item, String name) {
  // ignore: deprecated_member_use_from_same_package
  final allowed = item.filled;
  return allowed && sheenFilledIcons.containsKey(name.replaceAll('.fill', ''));
}

/// What a tab draws: a glyph's name and whether it is filled.
///
/// {@category Navigation}
class TabGlyph {
  /// A glyph.
  const TabGlyph({required this.name, required this.filled});

  /// The name ([SheenIcons]).
  final String name;

  /// Drawn filled.
  final bool filled;
}

/// The glyph of a tab that is not selected: filled when it has a filled form, unless the tab has a selected icon.
///
/// {@category Navigation}
TabGlyph tabIdleGlyph(SheenTabItem item) =>
    TabGlyph(name: item.icon, filled: item.selectedIcon == null && _filledAllowed(item, item.icon));

/// The glyph of the selected tab.
///
/// {@category Navigation}
TabGlyph tabSelectedGlyph(SheenTabItem item) {
  final name = item.selectedIcon ?? item.icon;
  return TabGlyph(name: name, filled: _filledAllowed(item, name));
}
