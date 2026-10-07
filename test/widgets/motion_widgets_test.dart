import 'package:flutter/services.dart';
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
  group('SheenRollingDigits around a currency', () {
    testWidgets('only the number rolls; the currency stays one word', (t) async {
      await t.pumpWidget(app(const SheenRollingDigits('USD 2,770.80', style: TextStyle(fontSize: 18))));
      await t.pumpWidget(app(const SheenRollingDigits('USD 3,055.97', style: TextStyle(fontSize: 18))));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('USD '), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget, reason: 'the old digit leaves while the new one comes');
      await t.pumpAndSettle();
      expect(find.text('2'), findsNothing);
      expect(find.bySemanticsLabel('USD 3,055.97'), findsOneWidget);
    });

    testWidgets('in Arabic the currency sits left of the number, which still reads left to right', (t) async {
      await t.pumpWidget(
        app(const SheenRollingDigits('2,770.80 ر.س', style: TextStyle(fontSize: 18)), dir: TextDirection.rtl),
      );
      final cur = t.getCenter(find.text(' ر.س')).dx;
      final xs = [
        for (final c in ['2', ',', '7', '.']) t.getCenter(find.text(c).first).dx,
      ];
      expect(cur, lessThan(xs.first));
      expect(xs, [...xs]..sort());
    });

    testWidgets('Latin text in a right-to-left screen stays one left-to-right run', (t) async {
      await t.pumpWidget(
        app(const SheenRollingDigits('USD 2,770.80', style: TextStyle(fontSize: 18)), dir: TextDirection.rtl),
      );
      expect(t.getCenter(find.text('USD ')).dx, lessThan(t.getCenter(find.text('2').first).dx));
    });
  });

  testWidgets('a sheet dragged to a detent gives a light tap, not while it opens', (t) async {
    final haptics = <String>[];
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}'.split('.').last);
      return null;
    });
    addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await t.pumpWidget(
      app(
        Builder(
          builder: (c) => GestureDetector(
            onTap: () => showSheenCustomSheet<void>(
              context: c,
              builder: (_, scroll) => ColoredBox(
                color: const Color(0xFF223344),
                child: ListView(
                  controller: scroll,
                  children: [for (var i = 0; i < 40; i++) SizedBox(height: 40, child: Text('row $i'))],
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(haptics, isEmpty);
    // from the large detent (92 %) down past the medium one (55 %): it snaps to medium
    await t.drag(find.text('row 0'), const Offset(0, 220));
    await t.pumpAndSettle();
    expect(haptics, ['lightImpact']);
  });
}
