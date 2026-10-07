import 'dart:ui' show Tristate;

import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget opener(void Function(BuildContext c) open) => host(
  Builder(
    builder: (c) => GestureDetector(onTap: () => open(c), child: const Text('open')),
  ),
);

void main() {
  group('date wheel sheet', () {
    testWidgets('Done returns the date shown; Cancel returns null', (t) async {
      Future<DateTime?>? result;
      await t.pumpWidget(
        opener(
          (c) => result = showSheenDateSheet(
            context: c,
            title: 'Date of birth',
            first: DateTime(1920),
            last: DateTime(2026, 10, 7),
            initial: DateTime(1990, 5, 17),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('May'), findsWidgets);
      await t.tap(find.bySemanticsLabel('Done'));
      await t.pumpAndSettle();
      expect(await result, DateTime(1990, 5, 17));

      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('Cancel').last);
      await t.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('turning the month wheel changes the month; a day past the month end is clamped', (t) async {
      Future<DateTime?>? result;
      await t.pumpWidget(
        opener(
          (c) => result = showSheenDateSheet(
            context: c,
            title: 'Date',
            first: DateTime(2000),
            last: DateTime(2030),
            initial: DateTime(2026, 1, 31),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      // one row down on the month wheel: February, and 31 becomes 28
      await t.drag(find.byKey(const ValueKey('sheen-date-month')), const Offset(0, -40));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('Done'));
      await t.pumpAndSettle();
      expect(await result, DateTime(2026, 2, 28));
    });

    testWidgets('an initial date outside first..last is kept inside', (t) async {
      Future<DateTime?>? result;
      await t.pumpWidget(
        opener(
          (c) => result = showSheenDateSheet(
            context: c,
            title: 'Date',
            first: DateTime(2020),
            last: DateTime(2026, 10, 7),
            initial: DateTime(2030),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('Done'));
      await t.pumpAndSettle();
      expect(await result, DateTime(2026, 10, 7));
    });
  });

  testWidgets(
    'a sheet may hold the app\'s own Material widgets: it gives them a Material, as Flutter\'s bottom sheet does, '
    'and its text keeps sheen\'s style',
    (t) async {
      late BuildContext inside;
      await t.pumpWidget(
        opener(
          (c) => showSheenCustomSheet<void>(
            context: c,
            builder: (sheet, scroll) => SheenSheetBody(
              title: 'Guest',
              onCancel: () => Navigator.of(sheet).pop(),
              child: ListView(
                controller: scroll,
                children: [
                  const m.TextField(key: ValueKey('name')),
                  m.Slider(value: .5, onChanged: (_) {}),
                  Builder(
                    builder: (b) {
                      inside = b;
                      return const Text('note');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.enterText(find.byKey(const ValueKey('name')), 'Lina');
      await t.pump();
      expect(find.text('Lina'), findsOneWidget);
      final style = DefaultTextStyle.of(inside).style;
      expect((style.fontSize, style.color), (inside.sheen.type.body.fontSize, inside.sheen.colors.text));
    },
  );

  testWidgets('a document sheet shows its long text and closes', (t) async {
    await t.pumpWidget(opener((c) => showSheenDocumentSheet(c, title: 'Terms', text: 'You agree to everything.')));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('You agree to everything.'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Close').last);
    await t.pumpAndSettle();
    expect(find.text('Terms'), findsNothing);
  });

  testWidgets('a form sheet is the page itself on a phone and a centred card on a tablet', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(host(const SheenFormSheet(child: SizedBox.expand(key: ValueKey('page')))));
    expect(t.getSize(find.byKey(const ValueKey('page'))), const Size(390, 844));

    t.view.physicalSize = const Size(2360, 1640);
    t.view.devicePixelRatio = 2;
    await t.pumpWidget(host(const SheenFormSheet(child: SizedBox.expand(key: ValueKey('page')))));
    final r = t.getRect(find.byKey(const ValueKey('page')));
    expect(r.width, SheenLayout.sheet);
    expect(r.center.dx, 590);
  });

  testWidgets('an accordion opens to its content, says it is expanded, and closes', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(host(const SheenAccordion(title: 'Can I cancel?', child: Text('Yes, until the day before.'))));
    expect(find.text('Yes, until the day before.'), findsNothing);
    expect(t.getSemantics(find.bySemanticsLabel('Can I cancel?')).flagsCollection.isExpanded, Tristate.isFalse);
    await t.tap(find.text('Can I cancel?'));
    await t.pumpAndSettle();
    expect(find.text('Yes, until the day before.'), findsOneWidget);
    expect(t.getSemantics(find.bySemanticsLabel('Can I cancel?')).flagsCollection.isExpanded, Tristate.isTrue);
    await t.tap(find.text('Can I cancel?'));
    await t.pumpAndSettle();
    expect(find.text('Yes, until the day before.'), findsNothing);
    handle.dispose();
  });
}
