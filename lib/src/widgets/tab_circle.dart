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

/// A tab's glyph is filled when it has a filled form and the tab allows it; otherwise its outline shows.
///
/// {@category Navigation}
bool tabGlyphFilled(SheenTabItem item) {
  // ignore: deprecated_member_use_from_same_package
  final allowed = item.filled;
  return allowed && sheenFilledIcons.containsKey(item.icon.replaceAll('.fill', ''));
}
