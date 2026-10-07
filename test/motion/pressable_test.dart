import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child) => host(Center(child: child));

double scaleOf(WidgetTester t) {
  final tr = t.widget<Transform>(
    find.descendant(of: find.byType(SheenPressable), matching: find.byType(Transform)).first,
  );
  return tr.transform.storage[0]; // x scale; getMaxScaleOnAxis would include z = 1
}

void main() {
  testWidgets('scales down while held and springs back after release', (t) async {
    await t.pumpWidget(app(SheenPressable(onTap: () {}, child: const SizedBox(width: 100, height: 50))));
    final g = await t.startGesture(t.getCenter(find.byType(SheenPressable)));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    expect(scaleOf(t), lessThan(.99));
    await g.up();
    await t.pumpAndSettle();
    expect(scaleOf(t), closeTo(1, 1e-3));
  });

  testWidgets('with reduced motion it dims instead of scaling', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(app(SheenPressable(onTap: () {}, child: const SizedBox(width: 100, height: 50))));
    final g = await t.startGesture(t.getCenter(find.byType(SheenPressable)));
    await t.pump(const Duration(milliseconds: 200));
    expect(scaleOf(t), closeTo(1, 1e-3));
    final op = t.widget<Opacity>(
      find.descendant(of: find.byType(SheenPressable), matching: find.byType(Opacity)).first,
    );
    expect(op.opacity, lessThan(1));
    await g.up();
    await t.pumpAndSettle();
  });

  testWidgets('hit area is at least 44 pt even for a small child', (t) async {
    await t.pumpWidget(app(SheenPressable(onTap: () {}, child: const SizedBox(width: 20, height: 20))));
    final s = t.getSize(find.byType(SheenPressable));
    expect(s.width, greaterThanOrEqualTo(44));
    expect(s.height, greaterThanOrEqualTo(44));
  });

  testWidgets('taps once, exposes a button label, and does nothing when disabled', (t) async {
    final handle = t.ensureSemantics();
    var n = 0;
    await t.pumpWidget(
      app(SheenPressable(onTap: () => n++, semanticLabel: 'Search', child: const SizedBox(width: 60, height: 44))),
    );
    await t.tap(find.byType(SheenPressable));
    expect(n, 1);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
    await t.pumpWidget(app(const SheenPressable(onTap: null, child: SizedBox(width: 60, height: 44))));
    await t.tap(find.byType(SheenPressable), warnIfMissed: false);
    expect(n, 1);
    handle.dispose();
  });
}

// Rebuild check for the scope: a running app sees Reduce Motion turned on.
