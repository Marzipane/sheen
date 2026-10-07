import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  group('SheenCardSwiper', () {
    Widget swiper(int index, ValueChanged<int> onChanged, {TextDirection dir = TextDirection.ltr}) => host(
      SizedBox(
        width: 360,
        height: 120,
        child: SheenCardSwiper(
          count: 3,
          index: index,
          onChanged: onChanged,
          itemBuilder: (_, i) => SizedBox(height: 100, child: Text('card $i')),
        ),
      ),
      direction: dir,
    );

    testWidgets('a swipe towards the start brings the next card; past the ends nothing happens', (t) async {
      final seen = <int>[];
      await t.pumpWidget(swiper(0, seen.add));
      await t.fling(find.text('card 0'), const Offset(-200, 0), 1000);
      await t.fling(find.text('card 0'), const Offset(200, 0), 1000);
      expect(seen, [1]);
    });

    testWidgets('right to left, the swipe directions mirror', (t) async {
      final seen = <int>[];
      await t.pumpWidget(swiper(1, seen.add, dir: TextDirection.rtl));
      await t.fling(find.text('card 1'), const Offset(200, 0), 1000);
      expect(seen, [2]);
    });

    testWidgets('screen readers get next and previous actions', (t) async {
      final handle = t.ensureSemantics();
      final seen = <int>[];
      await t.pumpWidget(swiper(1, seen.add));
      final actions = t.getSemantics(find.byType(SheenCardSwiper)).getSemanticsData().customSemanticsActionIds;
      expect(actions, hasLength(2));
      handle.dispose();
    });
  });

  testWidgets('a key-value card: labels and values in rows; a tappable value is in the accent', (t) async {
    var taps = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenKeyValueCard(
            rows: [
              const SheenKeyValue('Reference', 'RT-20418'),
              const SheenKeyValue('Check-in', 'Mon 20 Oct'),
              SheenKeyValue('At the hotel', 'See charges', onTap: () => taps++),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Reference'), findsOneWidget);
    expect(find.text('RT-20418'), findsOneWidget);
    expect(t.widget<Text>(find.text('See charges')).style!.color, SheenColors.light().accentText);
    await t.tap(find.text('See charges'));
    expect(taps, 1);
  });

  testWidgets('a chip row scrolls sideways and fades only the edge where more chips wait', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 300,
          child: SheenChipRow(
            children: [for (var i = 0; i < 10; i++) SheenChip(label: 'Filter $i', selected: false, onTap: () {})],
          ),
        ),
      ),
    );
    // the row learns its extents after its first layout
    await t.pump();
    SheenEdgeFade fade() => t.widget<SheenEdgeFade>(find.byType(SheenEdgeFade));
    expect((fade().start, fade().end), (false, true));
    await t.drag(find.text('Filter 1'), const Offset(-200, 0));
    await t.pumpAndSettle();
    expect((fade().start, fade().end), (true, true));
    await t.drag(find.byType(SheenChipRow), const Offset(-2000, 0));
    await t.pumpAndSettle();
    expect((fade().start, fade().end), (true, false));
  });

  group('SheenDateRangePicker', () {
    test('picking: a first day starts a range, a later one ends it, an earlier one restarts it', () {
      final a = DateTime(2026, 10, 20), b = DateTime(2026, 10, 22), c = DateTime(2026, 10, 18);
      expect(SheenDateRangePicker.pick(null, null, a), (a, null));
      expect(SheenDateRangePicker.pick(a, null, b), (a, b));
      expect(SheenDateRangePicker.pick(a, null, c), (c, null));
      expect(SheenDateRangePicker.pick(a, b, c), (c, null));
      expect(SheenDateRangePicker.pick(a, null, a), (a, null));
    });

    Widget picker({DateTime? start, DateTime? end, void Function(DateTime?, DateTime?)? onChanged}) => host(
      SizedBox(
        width: 360,
        child: SheenDateRangePicker(
          today: DateTime(2026, 10, 7),
          lastDay: DateTime(2027, 1, 31),
          start: start,
          end: end,
          weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          monthLabel: (m) =>
              '${const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m.month - 1]} ${m.year}',
          onChanged: onChanged ?? (_, _) {},
        ),
      ),
    );

    testWidgets('the month header with arrows: no going before this month or past the last day', (t) async {
      await t.pumpWidget(picker());
      expect(find.text('October 2026'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Previous'));
      await t.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        await t.tap(find.bySemanticsLabel('Next'));
        await t.pumpAndSettle();
      }
      expect(find.text('January 2027'), findsOneWidget);
    });

    testWidgets('a swipe changes the month; tapping two days reports the range', (t) async {
      DateTime? s, e;
      await t.pumpWidget(picker(onChanged: (a, b) => (s, e) = (a, b)));
      await t.fling(find.text('15'), const Offset(-250, 0), 1000);
      await t.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      await t.tap(find.text('20'));
      expect((s, e), (DateTime(2026, 11, 20), null));
      await t.pumpWidget(picker(start: s, onChanged: (a, b) => (s, e) = (a, b)));
      await t.pumpAndSettle();
      await t.tap(find.text('23'));
      expect((s, e), (DateTime(2026, 11, 20), DateTime(2026, 11, 23)));
    });
  });
}
