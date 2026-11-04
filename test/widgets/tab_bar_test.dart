import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget bar({
  List<SheenTabItem>? items,
  String? icon,
  SheenGlassVariant? variant,
  bool minimized = false,
  VoidCallback? onTap,
}) => host(
  SizedBox(
    width: 390,
    child: SheenTabBar(
      items:
          items ??
          const [
            SheenTabItem(icon: SheenIcons.homeFill, label: 'Home'),
            SheenTabItem(icon: SheenIcons.calendar, label: 'Trips', filled: false),
          ],
      index: 0,
      onSelect: (_) {},
      onSearch: onTap ?? () {},
      searchLabel: 'Add',
      searchIcon: icon ?? SheenIcons.search,
      searchVariant: variant ?? SheenGlassVariant.regular,
      minimized: minimized,
    ),
  ),
);

void main() {
  testWidgets('a tab can draw its glyph as an outline, for a glyph with no filled form', (t) async {
    await t.pumpWidget(bar());
    expect(t.takeException(), isNull);
    final calendars = t.widgetList<SheenIcon>(
      find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.calendar),
    );
    expect(calendars, isNotEmpty);
    expect(calendars.every((i) => !i.filled), isTrue);
    final homes = t.widgetList<SheenIcon>(
      find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.homeFill),
    );
    expect(homes.every((i) => i.filled), isTrue);
  });

  testWidgets('the circle can carry another action: its glyph and label replace search', (t) async {
    var taps = 0;
    await t.pumpWidget(bar(icon: SheenIcons.plus, onTap: () => taps++));
    expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.search), findsNothing);
    await t.tap(find.bySemanticsLabel('Add'));
    expect(taps, 1);
  });

  testWidgets('a prominent circle is its own accent glass, on the full and the minimized bar', (t) async {
    bool prominent() =>
        t.widgetList<SheenGlass>(find.byType(SheenGlass)).any((g) => g.variant == SheenGlassVariant.prominent);
    await t.pumpWidget(bar(icon: SheenIcons.plus, variant: SheenGlassVariant.prominent));
    expect(prominent(), isTrue);
    await t.pumpWidget(bar(icon: SheenIcons.plus, variant: SheenGlassVariant.prominent, minimized: true));
    await t.pump(const Duration(seconds: 1));
    expect(prominent(), isTrue);
    expect(t.takeException(), isNull);
  });

  testWidgets('by default nothing changes: filled tabs and a search circle', (t) async {
    await t.pumpWidget(
      bar(
        items: const [SheenTabItem(icon: SheenIcons.homeFill, label: 'Home')],
      ),
    );
    expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.search), findsWidgets);
  });
}
