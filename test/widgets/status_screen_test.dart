import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  test('each tone has its colour', () {
    final c = SheenColors.light();
    expect(SheenTone.info.color(c), c.accentText);
    expect(SheenTone.success.color(c), c.success);
    expect(SheenTone.warning.color(c), c.warning);
    expect(SheenTone.danger.color(c), c.danger);
    expect(SheenTone.neutral.color(c), c.textSecondary);
  });

  testWidgets('a status screen: the glyph in its tone, a header title, the message, details and two actions', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    var retried = 0, contacted = 0;
    await t.pumpWidget(
      host(
        SheenStatusScreen(
          icon: SheenIcons.wrench,
          tone: SheenTone.warning,
          title: 'We are updating',
          message: 'Back in a few minutes.',
          details: const [Text('Back around 14:30')],
          primaryLabel: 'Try again',
          onPrimary: () => retried++,
          secondaryLabel: 'Contact us',
          secondaryIcon: SheenIcons.chat,
          onSecondary: () => contacted++,
        ),
      ),
    );
    expect(t.getSemantics(find.text('We are updating')).flagsCollection.isHeader, isTrue);
    expect(find.text('Back in a few minutes.'), findsOneWidget);
    expect(find.text('Back around 14:30'), findsOneWidget);
    final glyph = t.widget<SheenIcon>(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.wrench));
    expect(glyph.color, SheenColors.light().warning);
    await t.tap(find.text('Try again'));
    await t.tap(find.text('Contact us'));
    expect((retried, contacted), (1, 1));
    handle.dispose();
  });

  testWidgets('without actions it is only the message; at 200 % text it does not overflow', (t) async {
    await t.pumpWidget(
      host(
        const SheenStatusScreen(icon: SheenIcons.wifi, title: 'No connection', message: 'Check your network.'),
        textScale: 2,
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.byType(SheenPrimaryButton), findsNothing);
  });
}
