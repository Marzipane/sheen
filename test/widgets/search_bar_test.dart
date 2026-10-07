import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child, {TextDirection dir = TextDirection.ltr}) => host(
  Center(child: SizedBox(width: 358, child: child)),
  brightness: Brightness.dark,
  direction: dir,
);

void main() {
  testWidgets('SheenSearchBar: the tab you came from as a circle, the field with its placeholder, 52 high', (t) async {
    var back = 0;
    final text = TextEditingController();
    await t.pumpWidget(
      app(
        SheenSearchBar(
          leadingIcon: 'home',
          leadingLabel: 'Home',
          onLeading: () => back++,
          controller: text,
          placeholder: 'Where to?',
          clearLabel: 'Clear',
        ),
      ),
    );
    expect(t.getSize(find.byType(SheenSearchBar)).height, 52);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.bySemanticsLabel('Clear'), findsNothing);
    await t.tap(find.bySemanticsLabel('Home'));
    expect(back, 1);
  });

  testWidgets('SheenSearchBar: typing shows the clear button, which empties the field', (t) async {
    final text = TextEditingController();
    String? submitted;
    await t.pumpWidget(
      app(
        SheenSearchBar(
          leadingIcon: 'home',
          leadingLabel: 'Home',
          onLeading: () {},
          controller: text,
          placeholder: 'Where to?',
          clearLabel: 'Clear',
          onSubmitted: (v) => submitted = v,
        ),
      ),
    );
    await t.enterText(find.byType(EditableText), 'Dub');
    await t.pump();
    expect(text.text, 'Dub');
    expect(find.bySemanticsLabel('Clear'), findsOneWidget);
    await t.testTextInput.receiveAction(TextInputAction.search);
    expect(submitted, 'Dub');
    await t.tap(find.bySemanticsLabel('Clear'));
    await t.pump();
    expect(text.text, isEmpty);
    expect(find.bySemanticsLabel('Clear'), findsNothing);
  });

  testWidgets('SheenSearchBar keeps its height at 200 % text (a bar)', (t) async {
    await t.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 358,
            child: SheenSearchBar(
              leadingIcon: SheenIcons.homeFill,
              leadingLabel: 'Home',
              onLeading: () {},
              controller: TextEditingController(text: 'Lisbon'),
              placeholder: 'Where to?',
              clearLabel: 'Clear',
            ),
          ),
        ),
        brightness: Brightness.dark,
        textScale: 2,
      ),
    );
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(SheenSearchBar)).height, 52);
  });

  testWidgets('SheenDateRangeCalendar: days after lastDay are off', (t) async {
    final picked = <DateTime>[];
    await t.pumpWidget(
      app(
        SheenDateRangeCalendar(
          month: DateTime(2026, 10),
          today: DateTime(2026, 10, 2),
          lastDay: DateTime(2026, 10, 20),
          weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          onDay: picked.add,
        ),
      ),
    );
    await t.tap(find.text('20'));
    await t.tap(find.text('21'));
    await t.tap(find.text('1'));
    expect(picked, [DateTime(2026, 10, 20)]);
  });
}
