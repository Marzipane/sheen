import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child) => host(Center(child: child), brightness: Brightness.dark);

Widget pill(Duration d) => SheenCountdownPill(remaining: d, semanticLabel: 'Room held for');

void main() {
  late List<String> haptics;

  setUp(() => haptics = []);

  void listen(WidgetTester t) {
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}'.split('.').last);
      return null;
    });
    addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
  }

  testWidgets('changed digits roll: the old and the new one overlap mid-way, then only the new one stays', (t) async {
    await t.pumpWidget(app(const SheenRollingDigits('10:00', style: TextStyle(fontSize: 15))));
    await t.pumpWidget(app(const SheenRollingDigits('9:59', style: TextStyle(fontSize: 15))));
    await t.pump(const Duration(milliseconds: 100));
    // the two last digits and the dropped "1" are on their way out, the new ones on their way in
    expect(find.text('9'), findsNWidgets(2));
    expect(find.text('0'), findsNWidgets(3));
    await t.pumpAndSettle();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(find.bySemanticsLabel('9:59'), findsOneWidget);
  });

  testWidgets('with Reduce Motion the text changes in place', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(app(const SheenRollingDigits('2:00', style: TextStyle(fontSize: 15))));
    await t.pumpWidget(app(const SheenRollingDigits('1:59', style: TextStyle(fontSize: 15))));
    await t.pump();
    expect(find.text('2'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('crossing 2:00 warns once with a pulse; running out errs once and shakes', (t) async {
    listen(t);
    await t.pumpWidget(app(pill(const Duration(minutes: 2, seconds: 1))));
    await t.pumpWidget(app(pill(const Duration(minutes: 2))));
    await t.pump(const Duration(milliseconds: 150));
    expect(haptics, ['warningNotification']);
    final scale = t.widget<Transform>(
      find.descendant(of: find.byType(SheenCountdownPill), matching: find.byType(Transform)).at(1),
    );
    expect(scale.transform.getMaxScaleOnAxis(), greaterThan(1.0));
    await t.pumpAndSettle();
    await t.pumpWidget(app(pill(const Duration(seconds: 59))));
    expect(haptics, ['warningNotification'], reason: 'only on the crossing');

    await t.pumpWidget(app(pill(const Duration(seconds: 1))));
    await t.pumpWidget(app(pill(Duration.zero)));
    await t.pump(const Duration(milliseconds: 25));
    expect(haptics, ['warningNotification', 'errorNotification']);
    final shake = t.widget<Transform>(
      find.descendant(of: find.byType(SheenCountdownPill), matching: find.byType(Transform)).first,
    );
    expect(shake.transform.getTranslation().x.abs(), greaterThan(1.0));
    await t.pumpAndSettle();
    final still = t.widget<Transform>(
      find.descendant(of: find.byType(SheenCountdownPill), matching: find.byType(Transform)).first,
    );
    expect(still.transform.getTranslation().x, 0);
  });

  testWidgets('with Reduce Motion the hold still warns and errs, without pulse or shake', (t) async {
    listen(t);
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(app(pill(const Duration(seconds: 1))));
    await t.pumpWidget(app(pill(Duration.zero)));
    await t.pump(const Duration(milliseconds: 25));
    expect(haptics, ['errorNotification']);
    final shake = t.widget<Transform>(
      find.descendant(of: find.byType(SheenCountdownPill), matching: find.byType(Transform)).first,
    );
    expect(shake.transform.getTranslation().x, 0);
  });

  testWidgets('in a right-to-left language the digits keep their order', (t) async {
    await t.pumpWidget(
      host(
        const Center(child: SheenRollingDigits('12:48', style: TextStyle(fontSize: 15))),
        direction: TextDirection.rtl,
      ),
    );
    final xs = [
      for (final c in ['1', '2', ':', '4', '8']) t.getCenter(find.text(c)).dx,
    ];
    expect(xs, [...xs]..sort());
  });
}
