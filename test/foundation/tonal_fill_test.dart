import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  test('the tonal fill is the muted surface in light and white at 8 % in dark', () {
    expect(SheenColors.light().fillTonal, SheenColors.light().surfaceMuted);
    expect(SheenColors.dark().fillTonal, const Color.fromRGBO(255, 255, 255, .08), reason: 'the exact value it replaces');
  });

  test('a palette built from its parts takes the muted surface as its tonal fill unless given one', () {
    final dark = SheenColors.dark();
    final built = SheenColors(
      background: dark.background,
      surface: dark.surface,
      surfaceMuted: const Color(0xFF123456),
      track: dark.track,
      separator: dark.separator,
      text: dark.text,
      textSecondary: dark.textSecondary,
      textTertiary: dark.textTertiary,
      accent: dark.accent,
      onAccent: dark.onAccent,
      accentText: dark.accentText,
      success: dark.success,
      warning: dark.warning,
      danger: dark.danger,
      rating: dark.rating,
      sheet: dark.sheet,
    );
    expect(built.fillTonal, const Color(0xFF123456));
    expect(built.copyWith(fillTonal: const Color(0xFF654321)).fillTonal, const Color(0xFF654321));
    expect(built == built.copyWith(fillTonal: const Color(0xFF654321)), isFalse, reason: 'it takes part in equality');
  });

  test('the capsule buttons keep their padding', () {
    expect(SheenButtonInset.secondary, const EdgeInsets.symmetric(horizontal: 20, vertical: 6));
    expect(SheenButtonInset.floating, const EdgeInsets.symmetric(horizontal: 18, vertical: 6));
  });

  for (final brightness in Brightness.values) {
    testWidgets('a secondary button and an alert\'s second action fill with the tonal fill ($brightness)', (t) async {
      await t.pumpWidget(
        host(
          brightness: brightness,
          Column(
            children: [
              SheenSecondaryButton(label: 'Later', onPressed: () {}),
              SheenAlert(
                title: 'Time over',
                message: 'Choose again.',
                primaryLabel: 'Book again',
                onPrimary: () {},
                secondaryLabel: 'Go back',
                onSecondary: () {},
              ),
            ],
          ),
        ),
      );
      final expected = (brightness == Brightness.dark ? SheenColors.dark() : SheenColors.light()).fillTonal;
      final fills = t
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<ShapeDecoration>()
          .where((d) => d.shape is StadiumBorder)
          .map((d) => d.color)
          .toList();
      final containers = t
          .widgetList<Container>(
            find.descendant(of: find.byType(SheenSecondaryButton), matching: find.byType(Container)),
          )
          .map((c) => c.decoration)
          .whereType<ShapeDecoration>()
          .map((d) => d.color);
      expect(containers, contains(expected), reason: 'secondary button');
      expect(fills, contains(expected), reason: 'alert second action');
    });
  }
}
