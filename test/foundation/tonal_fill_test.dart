import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  test('the tonal fill is the muted surface in light and white at 8 % in dark', () {
    expect(SheenColors.light().fillTonal, SheenColors.light().surfaceMuted);
    expect(
      SheenColors.dark().fillTonal,
      const Color.fromRGBO(255, 255, 255, .08),
      reason: 'the exact value it replaces',
    );
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
    expect(
      built.copyWith(surfaceMuted: const Color(0xFF0F0F0F)).fillTonal,
      const Color(0xFF0F0F0F),
      reason: 'it follows',
    );
    expect(SheenColors.light().copyWith(surfaceMuted: const Color(0xFF0F0F0F)).fillTonal, const Color(0xFF0F0F0F));
    expect(
      SheenColors.dark().copyWith(surfaceMuted: const Color(0xFF0F0F0F)).fillTonal,
      const Color.fromRGBO(255, 255, 255, .08),
      reason: 'a fill set on its own stays',
    );
    expect(built.copyWith(fillTonal: const Color(0xFF654321)).fillTonal, const Color(0xFF654321));
    expect(built == built.copyWith(fillTonal: const Color(0xFF654321)), isFalse, reason: 'it takes part in equality');
  });

  test('the capsule buttons keep their padding', () {
    expect(SheenButtonInset.secondary, const EdgeInsets.symmetric(horizontal: 20, vertical: 6));
    expect(SheenButtonInset.floating, const EdgeInsets.symmetric(horizontal: 18, vertical: 6));
  });

  for (final brightness in Brightness.values) {
    testWidgets('a secondary button and an alert\'s second action fill with the tonal fill ($brightness)', (t) async {
      // a fill unlike the muted surface, so a control that paints surfaceMuted fails here
      const marker = Color(0xFF00FF7F);
      final base = brightness == Brightness.dark ? SheenThemeData.dark() : SheenThemeData.light();
      final theme = base.copyWith(colors: base.colors.copyWith(fillTonal: marker));
      expect(theme.colors.surfaceMuted, isNot(marker));
      await t.pumpWidget(
        host(
          brightness: brightness,
          theme: theme,
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
      const expected = marker;
      final fills = t
          .widgetList<DecoratedBox>(find.descendant(of: find.byType(SheenAlert), matching: find.byType(DecoratedBox)))
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
