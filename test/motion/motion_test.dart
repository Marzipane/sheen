import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

double settle(SpringDescription s) {
  final sim = SpringSimulation(s, 0, 1, 0);
  double last = 0;
  for (var t = 0.0; t < 3; t += 0.001) {
    if ((1 - sim.x(t)).abs() > 0.002) last = t;
  }
  return last + 0.001;
}

void main() {
  test('springs settle like the shared design tokens (motion/springs.py)', () {
    expect(settle(SheenMotion.press), closeTo(0.337, 0.003));
    expect(settle(SheenMotion.snappy), closeTo(0.385, 0.003));
    expect(settle(SheenMotion.smooth), closeTo(0.607, 0.003));
    expect(settle(SheenMotion.gentle), closeTo(0.809, 0.003));
    expect(settle(SheenMotion.celebrate), closeTo(0.729, 0.003));
  });

  test('settle constants match the springs', () {
    expect(SheenMotion.settleOf(SheenMotion.smooth).inMilliseconds, closeTo(607, 3));
    expect(SheenMotion.smoothSettle.inMilliseconds, 607);
  });

  test('spring curve starts at 0, ends at 1 and overshoots only with bounce', () {
    final smooth = SheenMotion.curveOf(SheenMotion.smooth);
    final celebrate = SheenMotion.curveOf(SheenMotion.celebrate);
    expect(smooth.transform(0), 0);
    expect(smooth.transform(1), 1);
    double peak(Curve c) => [for (var i = 0; i <= 100; i++) c.transform(i / 100)].reduce((a, b) => a > b ? a : b);
    expect(peak(smooth), lessThanOrEqualTo(1.0001));
    expect(peak(celebrate), greaterThan(1.02));
  });

  testWidgets('reduced: the iOS Reduce Motion flag counts, not only disableAnimations', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    late bool r;
    await t.pumpWidget(
      Builder(
        builder: (c) {
          r = SheenMotion.reduced(c);
          return const SizedBox();
        },
      ),
    );
    expect(r, isTrue);
  });

  testWidgets('reduced: Android remove-animations (disableAnimations) counts too', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    late bool r;
    await t.pumpWidget(
      MediaQuery.fromView(
        view: t.view,
        child: Builder(
          builder: (c) {
            r = SheenMotion.reduced(c);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(r, isTrue);
  });

  testWidgets('reduced is false by default', (t) async {
    late bool r;
    await t.pumpWidget(
      Builder(
        builder: (c) {
          r = SheenMotion.reduced(c);
          return const SizedBox();
        },
      ),
    );
    expect(r, isFalse);
  });

  testWidgets('SheenMotionScope rebuilds dependents when Reduce Motion changes while running', (t) async {
    final seen = <bool>[];
    await t.pumpWidget(
      SheenMotionScope(
        child: Builder(
          builder: (c) {
            seen.add(SheenMotion.reduced(c));
            return const SizedBox();
          },
        ),
      ),
    );
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    t.binding.handleAccessibilityFeaturesChanged();
    await t.pump();
    expect(seen, [false, true]);
  });

  test('stagger delays only the first six items', () {
    expect(SheenMotion.staggerDelay(0), Duration.zero);
    expect(SheenMotion.staggerDelay(2), const Duration(milliseconds: 60));
    expect(SheenMotion.staggerDelay(5), const Duration(milliseconds: 150));
    expect(SheenMotion.staggerDelay(9), const Duration(milliseconds: 150));
  });
}
