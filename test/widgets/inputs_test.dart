import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  testWidgets('a text field works under CupertinoApp: no Material ancestor, no MaterialLocalizations', (t) async {
    final c = TextEditingController();
    await t.pumpWidget(
      CupertinoApp(
        home: SheenScope(
          child: Center(
            child: SheenTextField(label: 'Name', controller: c),
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    await t.enterText(find.byType(EditableText), 'Ada');
    expect(c.text, 'Ada');
  });

  testWidgets('a search bar works under a plain WidgetsApp', (t) async {
    final c = TextEditingController();
    await t.pumpWidget(
      host(
        SizedBox(
          width: 358,
          child: SheenSearchBar(
            leadingIcon: SheenIcons.homeFill,
            leadingLabel: 'Home',
            onLeading: () {},
            controller: c,
            placeholder: 'Search',
            clearLabel: 'Clear',
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    await t.enterText(find.byType(EditableText), 'Lisbon');
    expect(c.text, 'Lisbon');
  });

  testWidgets('the text field keyboard follows the theme brightness', (t) async {
    await t.pumpWidget(host(const SheenTextField(label: 'Name'), brightness: Brightness.dark));
    expect(t.widget<EditableText>(find.byType(EditableText)).keyboardAppearance, Brightness.dark);
  });

  group('the calendar week', () {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    Widget month(int first) => host(
      SizedBox(
        width: 350,
        child: SheenDateRangeCalendar(
          month: DateTime(2026, 10),
          today: DateTime(2026, 10, 1),
          weekdayLabels: labels,
          firstDayOfWeek: first,
          onDay: (_) {},
        ),
      ),
    );

    testWidgets('starts on Monday by default', (t) async {
      await t.pumpWidget(month(DateTime.monday));
      expect(t.getTopLeft(find.text('Mo')).dx, lessThan(t.getTopLeft(find.text('Su')).dx));
      // 1 October 2026 is a Thursday: the fourth column
      expect(t.getCenter(find.text('1')).dx, closeTo(t.getCenter(find.text('Th')).dx, .5));
    });

    testWidgets('starts on Sunday when asked; the days move with it', (t) async {
      await t.pumpWidget(month(DateTime.sunday));
      expect(t.getTopLeft(find.text('Su')).dx, lessThan(t.getTopLeft(find.text('Mo')).dx));
      expect(t.getCenter(find.text('1')).dx, closeTo(t.getCenter(find.text('Th')).dx, .5));
      expect(t.getCenter(find.text('4')).dx, closeTo(t.getCenter(find.text('Su')).dx, .5));
    });

    test('days in a month', () {
      expect(SheenDateRangeCalendar.daysIn(DateTime(2028, 2)), 29);
      expect(SheenDateRangeCalendar.daysIn(DateTime(2026, 2)), 28);
      expect(SheenDateRangeCalendar.daysIn(DateTime(2026, 12)), 31);
    });
  });

  testWidgets('the switch is on in the accent colour, or the one given', (t) async {
    const pink = Color(0xFFD6336C);
    Color? track() =>
        (t
                    .widget<DecoratedBox>(
                      find.descendant(of: find.byType(SheenSwitch), matching: find.byType(DecoratedBox)).first,
                    )
                    .decoration
                as ShapeDecoration)
            .color;
    await t.pumpWidget(
      host(
        SheenSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Wi-Fi'),
        theme: SheenThemeData.light(accent: pink),
      ),
    );
    expect(track(), pink);
    await t.pumpWidget(
      host(SheenSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Wi-Fi', activeColor: SheenTint.green)),
    );
    await t.pumpAndSettle();
    expect(track(), SheenTint.green);
  });
}
