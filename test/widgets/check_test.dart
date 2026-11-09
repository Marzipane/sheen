import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget _check({bool value = false, ValueChanged<bool>? onChanged, String? detail, String? error}) => SizedBox(
  width: 340,
  child: SheenCheck(value: value, onChanged: onChanged, label: 'I agree to the terms', detail: detail, error: error),
);

BoxDecoration _box(WidgetTester t) =>
    t.widget<AnimatedContainer>(find.byKey(const ValueKey('sheen-check-box'))).decoration! as BoxDecoration;

void main() {
  testWidgets('a tap anywhere on the row asks for the other value', (t) async {
    final changes = <bool>[];
    await t.pumpWidget(host(_check(onChanged: changes.add, detail: 'Required to create an account.')));

    await t.tap(find.text('Required to create an account.'));
    await t.tap(find.byKey(const ValueKey('sheen-check-box')));

    expect(changes, [true, true]);
  });

  testWidgets('ticked, the box fills with the accent; unticked it is only an outline', (t) async {
    await t.pumpWidget(host(_check(value: true, onChanged: (_) {})));
    final colors = SheenThemeData.light().colors;
    expect(_box(t).color, colors.accent);

    await t.pumpWidget(host(_check(onChanged: (_) {})));
    await t.pumpAndSettle();
    expect(_box(t).color, isNull);
    expect(_box(t).border!.top.color, colors.textTertiary);
  });

  testWidgets('an error shows under the label and outlines the box in the danger colour', (t) async {
    await t.pumpWidget(host(_check(onChanged: (_) {}, error: 'Tick the box to agree.')));

    expect(find.text('Tick the box to agree.'), findsOneWidget);
    expect(_box(t).border!.top.color, SheenThemeData.light().colors.danger);
  });

  testWidgets('a screen reader hears one checkbox with its label, detail and state', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(host(_check(value: true, onChanged: (_) {}, detail: 'Required.')));

    expect(
      t.getSemantics(find.byType(SheenCheck)),
      isSemantics(label: 'I agree to the terms\nRequired.', isChecked: true, isEnabled: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('without onChanged it is disabled and does nothing', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(host(_check()));

    await t.tap(find.byType(SheenCheck));
    expect(t.getSemantics(find.byType(SheenCheck)), isSemantics(isEnabled: false, hasTapAction: false));
    semantics.dispose();
  });

  testWidgets('the row is at least the minimum hit height', (t) async {
    await t.pumpWidget(host(_check(onChanged: (_) {})));
    expect(t.getSize(find.byType(SheenCheck)).height, greaterThanOrEqualTo(SheenSpace.hit));
  });

  testWidgets('right to left, the box sits at the start, on the right', (t) async {
    await t.pumpWidget(host(_check(onChanged: (_) {}), direction: TextDirection.rtl));

    final box = t.getRect(find.byKey(const ValueKey('sheen-check-box')));
    final label = t.getRect(find.text('I agree to the terms'));
    expect(box.left, greaterThan(label.right));
  });

  testWidgets('at the largest text the label wraps instead of overflowing', (t) async {
    await t.pumpWidget(host(_check(onChanged: (_) {}, detail: 'Required to create an account.'), textScale: 3.1));
    expect(t.takeException(), isNull);
  });
}
