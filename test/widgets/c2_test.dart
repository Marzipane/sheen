import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child, {TextDirection dir = TextDirection.ltr}) => host(
  Center(child: child),
  brightness: Brightness.dark,
  direction: dir,
);

void main() {
  testWidgets('SheenChip: on is inverted, off is glass; tap toggles through the callback', (t) async {
    var n = 0;
    await t.pumpWidget(
      app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenChip(label: 'Lowest total', selected: true, menu: true, onTap: () => n++),
            SheenChip(label: 'Breakfast', selected: false, onTap: () => n++),
          ],
        ),
      ),
    );
    expect(find.byType(SheenGlass), findsOneWidget);
    await t.tap(find.text('Breakfast'));
    expect(n, 1);
    expect(t.getSize(find.byType(SheenChip).first).height, 44);
  });

  testWidgets('SheenChip: a label too long for its room ends in an ellipsis, it does not overflow', (t) async {
    await t.pumpWidget(
      app(
        SizedBox(
          width: 160,
          child: Wrap(
            children: [
              SheenChip(label: 'Datum oder Gäste ändern, bitte', icon: 'calendar', selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    expect(t.widget<Text>(find.text('Datum oder Gäste ändern, bitte')).overflow, TextOverflow.ellipsis);
    expect(t.getSize(find.byType(SheenChip)).width, lessThanOrEqualTo(160));
  });

  testWidgets('SheenSegmentedControl: the lens marks the selection and a tap selects', (t) async {
    int? picked;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 300,
          child: SheenSegmentedControl(
            segments: const [SheenSegment('All'), SheenSegment('Room only'), SheenSegment('Breakfast')],
            index: 0,
            onChanged: (i) => picked = i,
          ),
        ),
      ),
    );
    expect(find.byType(SheenLens), findsOneWidget);
    await t.tap(find.text('Breakfast'));
    expect(picked, 2);
  });

  testWidgets('SheenSegmentedControl with no choice yet: no lens until a segment is picked, then it stands there', (
    t,
  ) async {
    var index = -1;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => SizedBox(
            width: 200,
            child: SheenSegmentedControl(
              segments: const [SheenSegment('Mr.'), SheenSegment('Mrs.')],
              index: index,
              onChanged: (i) => set(() => index = i),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(SheenLens), findsNothing);
    await t.tap(find.text('Mrs.'));
    await t.pump();
    expect(find.byType(SheenLens), findsOneWidget);
    // it appears under Mrs. at once, it does not slide over from Mr.
    expect(t.getCenter(find.byType(SheenLens)).dx, closeTo(t.getCenter(find.text('Mrs.')).dx, 1));
  });

  testWidgets(
    'SheenSegmentedControl with no choice yet leaves the screen cleanly (a guest sheet closed before Mr./Mrs.)',
    (t) async {
      await t.pumpWidget(
        app(
          SizedBox(
            width: 200,
            child: SheenSegmentedControl(
              segments: const [SheenSegment('Mr.'), SheenSegment('Mrs.')],
              index: -1,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await t.pumpWidget(app(const SizedBox()));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('SheenSegmentedControl with counts', (t) async {
    await t.pumpWidget(
      app(
        SizedBox(
          width: 340,
          child: SheenSegmentedControl(
            segments: const [
              SheenSegment('Visa-free', count: '126'),
              SheenSegment('eTA', count: '6'),
            ],
            index: 0,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('126'), findsOneWidget);
    expect(t.getSize(find.byType(SheenSegmentedControl)).height, 48);
  });

  testWidgets('SheenStepper: minus disabled at the minimum, plus disabled at the maximum', (t) async {
    var v = 1;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => SheenStepper(
            value: v,
            min: 1,
            max: 2,
            onChanged: (x) => set(() => v = x),
            decreaseLabel: 'Fewer adults',
            increaseLabel: 'More adults',
          ),
        ),
      ),
    );
    await t.tap(find.bySemanticsLabel('Fewer adults'));
    await t.pump();
    expect(v, 1);
    await t.tap(find.bySemanticsLabel('More adults'));
    await t.pump();
    expect(v, 2);
    await t.tap(find.bySemanticsLabel('More adults'));
    await t.pump();
    expect(v, 2);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('SheenSwitch toggles and reports its state', (t) async {
    var on = false;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) =>
              SheenSwitch(value: on, semanticLabel: 'Free cancellation', onChanged: (x) => set(() => on = x)),
        ),
      ),
    );
    await t.tap(find.byType(SheenSwitch));
    await t.pumpAndSettle();
    expect(on, isTrue);
    expect(t.getSize(find.byType(SheenSwitch)), const Size(51, 31));
  });

  testWidgets('SheenTextField: label, placeholder, error message', (t) async {
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 300,
          child: SheenTextField(label: 'First name', placeholder: 'As in passport', error: 'Please enter first name'),
        ),
      ),
    );
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('As in passport'), findsOneWidget);
    expect(find.text('Please enter first name'), findsOneWidget);
    await t.enterText(find.byType(EditableText), 'Ivan');
    expect(find.text('Ivan'), findsOneWidget);
  });

  testWidgets('SheenTextField: a note at the end of the label line, on the label baseline, at the trailing edge', (
    t,
  ) async {
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 300,
          child: SheenTextField(label: 'Phone', labelTrailing: Text('Optional')),
        ),
      ),
    );
    expect(find.text('Phone'), findsOneWidget);
    expect(t.getTopRight(find.text('Optional')).dx, closeTo(t.getTopRight(find.byType(SheenTextField)).dx, .01));
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 300,
          child: SheenTextField(label: 'Phone', labelTrailing: Text('Optional')),
        ),
        dir: TextDirection.rtl,
      ),
    );
    expect(t.getTopLeft(find.text('Optional')).dx, closeTo(t.getTopLeft(find.byType(SheenTextField)).dx, .01));
  });

  testWidgets('SheenSegmentedControl: glass on the page ground; inside a sheet a grey track and a raised thumb', (
    t,
  ) async {
    Widget seg() => SizedBox(
      width: 160,
      child: SheenSegmentedControl(
        segments: const [SheenSegment('Mr.'), SheenSegment('Mrs.')],
        index: 1,
        onChanged: (_) {},
      ),
    );
    await t.pumpWidget(app(seg()));
    expect(find.descendant(of: find.byType(SheenSegmentedControl), matching: find.byType(SheenGlass)), findsOneWidget);
    await t.pumpWidget(app(SheenNested(child: seg())));
    expect(find.descendant(of: find.byType(SheenSegmentedControl), matching: find.byType(SheenGlass)), findsNothing);
    expect(find.descendant(of: find.byType(SheenSegmentedControl), matching: find.byType(SheenLens)), findsNothing);
    final track = t.widget<DecoratedBox>(
      find.descendant(of: find.byType(SheenSegmentedControl), matching: find.byType(DecoratedBox)).first,
    );
    expect((track.decoration as ShapeDecoration).color, SheenThemeData.dark().colors.surfaceMuted);
  });

  testWidgets('SheenTextField: the field is the surface on the page and the muted surface inside a sheet', (t) async {
    Color ground() =>
        ((t
                    .widget<Container>(
                      find.descendant(of: find.byType(SheenTextField), matching: find.byType(Container)).first,
                    )
                    .decoration
                as ShapeDecoration)
            .color!);
    final colors = SheenThemeData.of(Brightness.dark).colors;
    await t.pumpWidget(app(const SizedBox(width: 300, child: SheenTextField(label: 'First name'))));
    expect(ground(), colors.surface);
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 300,
          child: SheenNested(child: SheenTextField(label: 'First name')),
        ),
      ),
    );
    expect(ground(), colors.surfaceMuted);
    ShapeDecoration deco() =>
        t
                .widget<Container>(
                  find.descendant(of: find.byType(SheenTextField), matching: find.byType(Container)).first,
                )
                .decoration
            as ShapeDecoration;
    expect(
      (deco().shape as RoundedRectangleBorder).side,
      BorderSide.none,
      reason: 'at rest no ring: the surface marks the field',
    );
  });

  testWidgets('SheenTextField: a password hides its text and carries a trailing button', (t) async {
    var shown = 0;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 300,
          child: SheenTextField(
            label: 'Password',
            obscureText: true,
            trailing: GestureDetector(onTap: () => shown++, child: const Text('Show')),
          ),
        ),
      ),
    );
    expect(t.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    await t.tap(find.text('Show'));
    expect(shown, 1);
  });

  testWidgets('SheenTextField: read-only fields open their picker on tap and take no typing', (t) async {
    var taps = 0;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 300,
          child: SheenTextField(label: 'Date of Birth', placeholder: 'Choose', readOnly: true, onTap: () => taps++),
        ),
      ),
    );
    expect(t.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
    await t.tap(find.text('Choose'));
    expect(taps, 1);
  });

  testWidgets('SheenDateRangeCalendar: Monday first; past days are off; check-in and check-out', (t) async {
    final picked = <DateTime>[];
    await t.pumpWidget(
      app(
        SizedBox(
          width: 366,
          child: SheenDateRangeCalendar(
            month: DateTime(2026, 10),
            today: DateTime(2026, 10, 2),
            start: DateTime(2026, 10, 20),
            end: DateTime(2026, 10, 22),
            weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            onDay: picked.add,
          ),
        ),
      ),
    );
    // 1 October 2026 is a Thursday: four labels and three blanks come before it in a Monday-first grid.
    final d1 = t.getTopLeft(find.text('1'));
    final mon5 = t.getTopLeft(find.text('5'));
    expect(d1.dx, greaterThan(mon5.dx));
    await t.tap(find.text('1'), warnIfMissed: false);
    expect(picked, isEmpty);
    await t.tap(find.text('25'));
    expect(picked, [DateTime(2026, 10, 25)]);
  });

  testWidgets('SheenCountdownPill: amber, red in the last two minutes, grey at zero', (t) async {
    // the digits roll one by one (SheenRollingDigits): read the pill's label, and the colour the digits are drawn in
    Color colorOf() => t.widget<SheenRollingDigits>(find.byType(SheenRollingDigits)).style.color!;
    await t.pumpWidget(
      app(const SheenCountdownPill(remaining: Duration(minutes: 12, seconds: 48), semanticLabel: 'Room held')),
    );
    expect(find.bySemanticsLabel('Room held, 12:48'), findsOneWidget);
    expect(colorOf(), SheenColors.dark().warning);
    await t.pumpWidget(
      app(const SheenCountdownPill(remaining: Duration(minutes: 1, seconds: 45), semanticLabel: 'Room held')),
    );
    await t.pumpAndSettle();
    expect(colorOf(), SheenColors.dark().danger);
    await t.pumpWidget(app(const SheenCountdownPill(remaining: Duration.zero, semanticLabel: 'Room held')));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('Room held, 0:00'), findsOneWidget);
    expect(colorOf(), SheenColors.dark().textTertiary);
  });
}
