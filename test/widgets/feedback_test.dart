import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget shower(void Function(BuildContext c) show) => host(
  Builder(
    builder: (c) => GestureDetector(onTap: () => show(c), child: const Text('show')),
  ),
);

void main() {
  tearDown(SheenToast.hide);

  test('a toast stays long enough to read: 3 to 7 seconds', () {
    expect(SheenToast.readingTime('Saved'), const Duration(seconds: 3));
    expect(SheenToast.readingTime('x' * 60), const Duration(milliseconds: 4700));
    expect(SheenToast.readingTime('x' * 400), const Duration(seconds: 7));
  });

  testWidgets('a toast shows over the screen, is announced, and leaves after its reading time', (t) async {
    await t.pumpWidget(shower((c) => SheenToast.show(c, 'Saved to your list', tone: SheenTone.success)));
    await t.tap(find.text('show'));
    await t.pump();
    expect(find.text('Saved to your list'), findsOneWidget);
    expect(t.takeAnnouncements().map((a) => a.message), contains('Saved to your list'));
    await t.pump(const Duration(seconds: 3, milliseconds: 100));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved to your list'), findsNothing);
  });

  testWidgets('a new toast replaces the one shown; a tap closes it', (t) async {
    var n = 0;
    await t.pumpWidget(shower((c) => SheenToast.show(c, 'Message ${++n}')));
    await t.tap(find.text('show'));
    await t.pump();
    await t.tap(find.text('show'));
    await t.pump();
    expect(find.text('Message 1'), findsNothing);
    expect(find.text('Message 2'), findsOneWidget);
    await t.tap(find.text('Message 2'));
    await t.pump();
    expect(find.text('Message 2'), findsNothing);
  });

  testWidgets('each tone has its glyph in its colour', (t) async {
    await t.pumpWidget(shower((c) => SheenToast.show(c, 'Could not save', tone: SheenTone.danger)));
    await t.tap(find.text('show'));
    await t.pump();
    final glyph = t.widget<SheenIcon>(
      find.descendant(of: find.byKey(const ValueKey('sheen-toast')), matching: find.byType(SheenIcon)),
    );
    expect(glyph.name, SheenIcons.xCircle);
    expect(glyph.color, SheenColors.light().danger);
    SheenToast.hide();
  });

  testWidgets('an action banner: glyph, title, message and its action', (t) async {
    var acted = 0;
    await t.pumpWidget(
      host(
        SheenActionBanner(
          icon: SheenIcons.refresh,
          tone: SheenTone.warning,
          title: 'Prices changed',
          message: '3 stays are now cheaper.',
          actionLabel: 'Show',
          onAction: () => acted++,
        ),
      ),
    );
    expect(find.text('Prices changed'), findsOneWidget);
    expect(find.text('3 stays are now cheaper.'), findsOneWidget);
    await t.tap(find.text('Show'));
    expect(acted, 1);
  });

  testWidgets('a status pill reads its label in its tone', (t) async {
    await t.pumpWidget(host(const SheenStatusPill(label: 'Confirmed', tone: SheenTone.success)));
    final text = t.widget<Text>(find.text('Confirmed'));
    expect(text.style!.color, SheenColors.light().success);
  });

  testWidgets('the success check celebrates once, with a success haptic; still with Reduce Motion', (t) async {
    final haptics = <String>[];
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}'.split('.').last);
      return null;
    });
    addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await t.pumpWidget(host(const SheenSuccessCheck()));
    await t.pumpAndSettle();
    expect(haptics, ['successNotification']);
    expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.checkCircleFill), findsOneWidget);
  });
}
