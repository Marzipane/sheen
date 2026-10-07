import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child, {TextDirection dir = TextDirection.ltr}) => host(
  Center(child: SizedBox(width: 300, child: child)),
  brightness: Brightness.dark,
  direction: dir,
);

class Range {
  SheenRange v = const SheenRange(0, 1000);
  int ends = 0;
}

Widget range(Range r, {TextDirection dir = TextDirection.ltr}) => app(
  StatefulBuilder(
    builder: (context, set) => SheenRangeHistogram(
      bins: const [1, 3, 5, 2, 0, 4, 1, 1, 2, 1],
      min: 0,
      max: 1000,
      values: r.v,
      onChanged: (v) => set(() => r.v = v),
      onChangeEnd: (_) => r.ends++,
      lowLabel: 'Lowest total',
      highLabel: 'Highest total',
      format: (v) => 'USD ${v.round()}',
    ),
  ),
  dir: dir,
);

void main() {
  testWidgets('one bar per bin; the bars inside the range are lit', (t) async {
    final r = Range()..v = const SheenRange(300, 700);
    await t.pumpWidget(range(r));
    expect(find.byKey(const ValueKey('bar-on')), findsNWidgets(4));
    expect(find.byKey(const ValueKey('bar-off')), findsNWidgets(6));
  });

  testWidgets('dragging the high knob lowers the top of the range; it never crosses the low one', (t) async {
    final r = Range();
    await t.pumpWidget(range(r));
    final box = t.getRect(find.byType(SheenRangeHistogram));
    await t.dragFrom(Offset(box.right - 2, box.bottom - 14), const Offset(-150, 0));
    await t.pumpAndSettle();
    expect(r.v.end, closeTo(500, 30));
    expect(r.v.start, 0);
    expect(r.ends, 1);
    // the low knob, in small steps so every move rebuilds the slider
    final g = await t.startGesture(Offset(box.left + 2, box.bottom - 14));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(10, 0));
      await t.pump();
    }
    await g.up();
    await t.pumpAndSettle();
    expect(r.v.start, closeTo(300, 40));
    expect(r.v.end, closeTo(500, 30), reason: 'the high knob stays');
    final g2 = await t.startGesture(Offset(box.left + 2 + 272 * .3 + 4, box.bottom - 14));
    for (var i = 0; i < 20; i++) {
      await g2.moveBy(const Offset(12, 0));
      await t.pump();
    }
    await g2.up();
    await t.pumpAndSettle();
    expect(r.v.start, lessThanOrEqualTo(r.v.end));
    expect(r.v.end, closeTo(500, 30));
  });

  testWidgets('right to left: the low end is on the right', (t) async {
    final r = Range();
    await t.pumpWidget(range(r, dir: TextDirection.rtl));
    final box = t.getRect(find.byType(SheenRangeHistogram));
    await t.dragFrom(Offset(box.right - 2, box.bottom - 14), const Offset(-150, 0));
    await t.pumpAndSettle();
    expect(r.v.start, closeTo(500, 30));
    expect(r.v.end, 1000);
  });

  testWidgets('each knob is an adjustable slider for screen readers, with the amount as its value', (t) async {
    final handle = t.ensureSemantics();
    final r = Range()..v = const SheenRange(200, 800);
    await t.pumpWidget(range(r));
    final low = find.bySemanticsLabel('Lowest total');
    expect(t.getSemantics(low).value, 'USD 200');
    t.semantics.performAction(find.semantics.byLabel('Lowest total'), SemanticsAction.increase);
    await t.pumpAndSettle();
    expect(r.v.start, greaterThan(200));
    handle.dispose();
  });
}
