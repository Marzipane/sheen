import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

const _tabs = [
  SheenTabItem(icon: SheenIcons.homeFill, label: 'Home'),
  SheenTabItem(icon: SheenIcons.calendar, label: 'Trips'),
];

Widget bar({
  int index = 0,
  String icon = SheenIcons.search,
  SheenGlassVariant variant = SheenGlassVariant.regular,
  bool minimized = false,
  bool active = false,
  VoidCallback? onTap,
  SheenThemeData? theme,
}) => host(
  SizedBox(
    width: 390,
    child: SheenTabBar(
      items: _tabs,
      index: index,
      onSelect: (_) {},
      onSearch: onTap ?? () {},
      searchLabel: 'Add',
      searchIcon: icon,
      searchVariant: variant,
      searchActive: active,
      minimized: minimized,
    ),
  ),
  theme: theme,
);

Widget topBar({
  String icon = SheenIcons.search,
  SheenGlassVariant variant = SheenGlassVariant.regular,
  bool active = false,
}) => host(
  SizedBox(
    width: 700,
    child: SheenTopTabBar(
      items: _tabs,
      index: 0,
      onSelect: (_) {},
      onSearch: () {},
      searchLabel: 'Add',
      searchIcon: icon,
      searchVariant: variant,
      searchActive: active,
    ),
  ),
);

Iterable<SheenIcon> glyphs(WidgetTester t, String name) =>
    t.widgetList<SheenIcon>(find.byWidgetPredicate((w) => w is SheenIcon && w.name == name));

bool prominent(WidgetTester t) =>
    t.widgetList<SheenGlass>(find.byType(SheenGlass)).any((g) => g.variant == SheenGlassVariant.prominent);

void main() {
  final colors = SheenColors.light();

  testWidgets('a glyph with no filled form shows its outline, on the full and the minimized bar', (t) async {
    await t.pumpWidget(bar());
    expect(t.takeException(), isNull);
    expect(glyphs(t, SheenIcons.calendar), isNotEmpty);
    expect(glyphs(t, SheenIcons.calendar).every((i) => !i.filled), isTrue);
    expect(glyphs(t, SheenIcons.homeFill), isNotEmpty);
    expect(glyphs(t, SheenIcons.homeFill).every((i) => i.filled), isTrue);
    await t.pumpWidget(bar(index: 1, minimized: true));
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
    expect(glyphs(t, SheenIcons.calendar), isNotEmpty);
    expect(glyphs(t, SheenIcons.calendar).every((i) => !i.filled), isTrue);
  });

  final lifted = find.byKey(const ValueKey('tab-lens-lifted'));

  Iterable<SheenIcon> onLens(WidgetTester t, String name) => t.widgetList<SheenIcon>(
    find.descendant(of: lifted, matching: find.byWidgetPredicate((w) => w is SheenIcon && w.name == name)),
  );

  testWidgets('a lifted lens shows the outline in the accent ink', (t) async {
    await t.pumpWidget(bar());
    final gesture = await t.startGesture(t.getCenter(find.text('Trips').first));
    await t.pump(); // the spring starts on the next frame
    await t.pump(const Duration(milliseconds: 300));
    expect(lifted, findsOneWidget);
    final calendars = onLens(t, SheenIcons.calendar);
    expect(calendars, isNotEmpty);
    expect(calendars.every((i) => !i.filled), isTrue);
    expect(calendars.any((i) => i.color == colors.accentText), isTrue);
    await gesture.up();
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('a lens slid onto a prominent circle shows its glyph in the accent ink', (t) async {
    await t.pumpWidget(bar(icon: SheenIcons.plus, variant: SheenGlassVariant.prominent));
    final from = t.getCenter(find.text('Trips').first);
    final to = t.getCenter(find.bySemanticsLabel('Add'));
    final gesture = await t.startGesture(from);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    for (var i = 1; i <= 8; i++) {
      await gesture.moveTo(Offset.lerp(from, to, i / 8)!);
      await t.pump(const Duration(milliseconds: 16));
    }
    await t.pump(const Duration(milliseconds: 300));
    expect(onLens(t, SheenIcons.plus).last.color, colors.accentText);
    await gesture.cancel();
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('filled: false keeps the outline of a glyph that has both forms', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 390,
          child: SheenTabBar(
            items: const [
              // ignore: deprecated_member_use_from_same_package
              SheenTabItem(icon: SheenIcons.heart, label: 'Saved', filled: false),
              SheenTabItem(icon: SheenIcons.map, label: 'Map'),
            ],
            index: 0,
            onSelect: (_) {},
            onSearch: () {},
          ),
        ),
      ),
    );
    final hearts = glyphs(t, SheenIcons.heart);
    expect(hearts, isNotEmpty);
    expect(hearts.every((i) => !i.filled), isTrue);
    expect(glyphs(t, SheenIcons.map), isNotEmpty);
    expect(glyphs(t, SheenIcons.map).every((i) => i.filled), isTrue);
  });

  testWidgets('the circle can carry another action: its glyph and label replace search', (t) async {
    var taps = 0;
    await t.pumpWidget(bar(icon: SheenIcons.plus, onTap: () => taps++));
    expect(glyphs(t, SheenIcons.search), isEmpty);
    await t.tap(find.bySemanticsLabel('Add'));
    expect(taps, 1);
  });

  for (final minimized in [false, true]) {
    final form = minimized ? 'minimized' : 'full';

    testWidgets('prominent glass reads on the $form bar, idle and active', (t) async {
      for (final active in [false, true]) {
        await t.pumpWidget(
          bar(icon: SheenIcons.plus, variant: SheenGlassVariant.prominent, minimized: minimized, active: active),
        );
        await t.pump(const Duration(seconds: 1));
        expect(prominent(t), isTrue);
        expect(glyphs(t, SheenIcons.plus).last.color, colors.onAccent);
        expect(find.byKey(const ValueKey('tab-circle-ring')), active ? findsOneWidget : findsNothing);
      }
      expect(t.takeException(), isNull);
    });

    testWidgets('regular glass keeps its ink on the $form bar', (t) async {
      await t.pumpWidget(bar(minimized: minimized));
      await t.pump(const Duration(seconds: 1));
      expect(glyphs(t, SheenIcons.search).last.color, colors.text);
      await t.pumpWidget(bar(minimized: minimized, active: true));
      await t.pump(const Duration(seconds: 1));
      expect(glyphs(t, SheenIcons.search).last.color, colors.accentText);
    });
  }

  testWidgets('by default the circle is search on regular glass', (t) async {
    await t.pumpWidget(bar());
    expect(glyphs(t, SheenIcons.search), isNotEmpty);
    expect(prominent(t), isFalse);
  });

  const paired = [
    SheenTabItem(icon: SheenIcons.heart, selectedIcon: SheenIcons.heartFill, label: 'Saved'),
    SheenTabItem(icon: SheenIcons.map, selectedIcon: SheenIcons.mapFill, label: 'Map'),
  ];

  Widget pairedBar(int index, {bool minimized = false, bool searchActive = false}) => host(
    SizedBox(
      width: 390,
      child: SheenTabBar(
        items: paired,
        index: index,
        onSelect: (_) {},
        onSearch: () {},
        minimized: minimized,
        searchActive: searchActive,
      ),
    ),
  );

  testWidgets('selectedIcon fills only the selected tab', (t) async {
    await t.pumpWidget(pairedBar(0));
    expect(glyphs(t, SheenIcons.heartFill), isNotEmpty);
    expect(glyphs(t, SheenIcons.heart), isEmpty);
    expect(glyphs(t, SheenIcons.map), isNotEmpty);
    expect(glyphs(t, SheenIcons.map).every((i) => !i.filled), isTrue);
    expect(glyphs(t, SheenIcons.mapFill), isEmpty);
  });

  testWidgets('the minimized bar shows the selected glyph', (t) async {
    await t.pumpWidget(pairedBar(1, minimized: true));
    await t.pump(const Duration(seconds: 1));
    expect(glyphs(t, SheenIcons.mapFill), isNotEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('the top bar takes selectedIcon too', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 700,
          child: SheenTopTabBar(items: paired, index: 1, onSelect: (_) {}),
        ),
      ),
    );
    expect(glyphs(t, SheenIcons.mapFill), isNotEmpty);
    expect(glyphs(t, SheenIcons.heart).every((i) => !i.filled), isTrue);
    expect(glyphs(t, SheenIcons.heart), isNotEmpty);
  });

  testWidgets('the selected tab goes back to its outline while search is on', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 700,
          child: SheenTopTabBar(items: paired, index: 1, searchActive: true, onSelect: (_) {}),
        ),
      ),
    );
    expect(glyphs(t, SheenIcons.mapFill), isEmpty);
    expect(glyphs(t, SheenIcons.map).every((i) => !i.filled), isTrue);
    await t.pumpWidget(pairedBar(1, searchActive: true));
    await t.pump(const Duration(seconds: 1));
    expect(glyphs(t, SheenIcons.mapFill), isEmpty);
  });

  testWidgets('the lifted lens shows the selected glyph', (t) async {
    await t.pumpWidget(pairedBar(1));
    await t.pump(const Duration(seconds: 1));
    final press = await t.startGesture(t.getCenter(find.text('Map').first));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    final inLens = find.descendant(of: find.byKey(const ValueKey('tab-lens-lifted')), matching: find.byType(SheenIcon));
    final names = t.widgetList<SheenIcon>(inLens).map((i) => i.name);
    expect(names, contains(SheenIcons.mapFill));
    expect(names, isNot(contains(SheenIcons.map)));
    await press.up();
    await t.pumpAndSettle();
  });

  group('SheenTopTabBar', () {
    testWidgets('takes the same circle as the tab bar', (t) async {
      for (final active in [false, true]) {
        await t.pumpWidget(topBar(icon: SheenIcons.plus, variant: SheenGlassVariant.prominent, active: active));
        expect(prominent(t), isTrue);
        expect(glyphs(t, SheenIcons.search), isEmpty);
        expect(glyphs(t, SheenIcons.plus).single.color, colors.onAccent);
        expect(find.byKey(const ValueKey('tab-circle-ring')), active ? findsOneWidget : findsNothing);
      }
    });

    testWidgets('by default the circle is search on regular glass', (t) async {
      await t.pumpWidget(topBar());
      expect(glyphs(t, SheenIcons.search).single.color, colors.text);
      expect(prominent(t), isFalse);
    });

    testWidgets('a glyph with no filled form shows its outline', (t) async {
      await t.pumpWidget(topBar());
      expect(t.takeException(), isNull);
      expect(glyphs(t, SheenIcons.calendar), isNotEmpty);
      expect(glyphs(t, SheenIcons.calendar).every((i) => !i.filled), isTrue);
    });
  });
}
