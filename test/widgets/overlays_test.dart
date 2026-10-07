import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  Widget opener(void Function(BuildContext c) open) => Builder(
    builder: (c) => GestureDetector(onTap: () => open(c), child: const Text('open')),
  );

  testWidgets('a sheet opens from a WidgetsApp with its title; close returns null', (t) async {
    Future<String?>? result;
    await t.pumpWidget(
      host(
        opener(
          (c) => result = showSheenSheet<String>(
            context: c,
            title: 'Sort by',
            builder: (_, scroll) => ListView(controller: scroll, children: const [Text('Price')]),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Cancel').last);
    await t.pumpAndSettle();
    expect(await result, isNull);
    expect(find.text('Sort by'), findsNothing);
  });

  testWidgets('a sheet returns what it is popped with', (t) async {
    Future<String?>? result;
    await t.pumpWidget(
      host(
        opener(
          (c) => result = showSheenSheet<String>(
            context: c,
            title: 'Sort by',
            builder: (sc, scroll) => ListView(
              controller: scroll,
              children: [GestureDetector(onTap: () => Navigator.pop(sc, 'price'), child: const Text('Price'))],
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('Price'));
    await t.pumpAndSettle();
    expect(await result, 'price');
  });

  testWidgets('dragging the sheet down closes it, and so does a tap on the dim behind it', (t) async {
    await t.pumpWidget(
      host(
        opener(
          (c) => showSheenSheet<void>(
            context: c,
            title: 'Filters',
            startLarge: false,
            builder: (_, scroll) => ListView(
              controller: scroll,
              children: [for (var i = 0; i < 30; i++) SizedBox(height: 44, child: Text('row $i'))],
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.fling(find.text('row 0'), const Offset(0, 500), 2000);
    await t.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);

    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    await t.tapAt(const Offset(20, 20));
    await t.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('a sheet on a wide window keeps a phone-wide column, centred', (t) async {
    t.view.physicalSize = const Size(2360, 1640);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      host(
        opener(
          (c) => showSheenCustomSheet<void>(
            context: c,
            builder: (_, scroll) => ListView(
              controller: scroll,
              children: const [SizedBox(height: 40, key: ValueKey('row'))],
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    final box = t.getRect(find.byKey(const ValueKey('row')));
    expect(box.width, SheenLayout.sheet);
    expect(box.center.dx, 590);
  });

  testWidgets('a sheet keeps the theme of the screen that opened it', (t) async {
    await t.pumpWidget(
      host(
        SheenTheme(
          data: SheenThemeData.dark(),
          child: opener(
            (c) => showSheenSheet<void>(
              context: c,
              title: 'Dark',
              builder: (_, scroll) => ListView(controller: scroll),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(t.element(find.text('Dark')).sheen.isDark, isTrue);
  });

  testWidgets('with Reduce Motion the sheet fades in instead of sliding', (t) async {
    await t.pumpWidget(
      host(
        opener(
          (c) => showSheenSheet<void>(
            context: c,
            title: 'Calm',
            builder: (_, scroll) => ListView(controller: scroll),
          ),
        ),
        reduceMotion: true,
      ),
    );
    await t.tap(find.text('open'));
    await t.pump();
    expect(find.byType(SlideTransition), findsNothing);
    expect(find.ancestor(of: find.text('Calm'), matching: find.byType(FadeTransition)), findsWidgets);
    await t.pumpAndSettle();
  });
}
