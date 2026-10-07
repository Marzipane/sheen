import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/src/glass/color_matrix.dart';

import '../helpers.dart';

Widget app(Widget child, {Brightness b = Brightness.dark, bool highContrast = false}) => host(
  Builder(
    builder: (c) => MediaQuery(
      data: MediaQuery.of(c).copyWith(highContrast: highContrast),
      child: Center(child: child),
    ),
  ),
  brightness: b,
);

void main() {
  group('colour matrix (CSS filter effects)', () {
    test('saturate(1) brightness(1) is the identity', () {
      final m = sheenColorMatrix(saturation: 1, brightness: 1);
      expect(m, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0].map((e) => e.toDouble()).toList());
    });
    test('saturate(0) makes the three colour rows equal (luminance)', () {
      final m = sheenColorMatrix(saturation: 0, brightness: 1);
      expect(m.sublist(0, 3), m.sublist(5, 8));
      expect(m.sublist(0, 3), m.sublist(10, 13));
      expect(m[0], closeTo(.213, 1e-9));
      expect(m[1], closeTo(.715, 1e-9));
      expect(m[2], closeTo(.072, 1e-9));
    });
    test('brightness multiplies the colour rows, not alpha', () {
      final m = sheenColorMatrix(saturation: 1, brightness: 1.08);
      expect(m[0], closeTo(1.08, 1e-9));
      expect(m[6], closeTo(1.08, 1e-9));
      expect(m[18], 1);
    });
  });

  group('styles are the approved CSS values', () {
    test('dark regular is the matte glass', () {
      final g = SheenGlassStyles.dark().regular;
      expect(g.blur, 18);
      expect(g.saturation, 1.6);
      expect(g.brightness, 1.0);
    });
    test('light regular', () {
      final g = SheenGlassStyles.light().regular;
      expect(g.blur, 14);
      expect(g.saturation, 2.0);
      expect(g.brightness, 1.06);
    });
    test('prominent has no backdrop', () {
      expect(SheenGlassStyles.dark().prominent.blur, 0);
      expect(SheenGlassStyles.light().prominent.blur, 0);
    });
    test('css shadow blur is converted to a Flutter blur radius with the same sigma', () {
      final s = SheenGlassStyle.cssShadow(0, 10, 28, const Color(0x6B000000));
      expect(Shadow.convertRadiusToSigma(s.blurRadius), closeTo(14, 1e-6));
      expect(s.offset, const Offset(0, 10));
    });
  });

  group('SheenGlass', () {
    testWidgets('regular and clear blur the backdrop', (t) async {
      for (final v in [SheenGlassVariant.regular, SheenGlassVariant.clear]) {
        await t.pumpWidget(app(SheenGlass(variant: v, child: const SizedBox(width: 100, height: 44))));
        expect(find.byType(BackdropFilter), findsOneWidget, reason: '$v');
      }
    });
    testWidgets('prominent draws no backdrop filter', (t) async {
      await t.pumpWidget(
        app(const SheenGlass(variant: SheenGlassVariant.prominent, child: SizedBox(width: 100, height: 44))),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
    testWidgets('increased contrast turns glass opaque', (t) async {
      await t.pumpWidget(app(const SheenGlass(child: SizedBox(width: 100, height: 44)), highContrast: true));
      expect(find.byType(BackdropFilter), findsNothing);
    });
    testWidgets('light theme builds too, and the child stays tappable', (t) async {
      var taps = 0;
      await t.pumpWidget(
        app(
          SheenGlass(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const SizedBox(width: 100, height: 44),
            ),
          ),
          b: Brightness.light,
        ),
      );
      await t.tap(find.byType(GestureDetector));
      expect(taps, 1);
    });
    testWidgets('lens builds in both brightnesses', (t) async {
      await t.pumpWidget(app(const SheenLens(child: SizedBox(width: 60, height: 54))));
      await t.pumpWidget(app(const SheenLens(child: SizedBox(width: 60, height: 54)), b: Brightness.light));
      expect(find.byType(SheenLens), findsOneWidget);
    });
  });

  testWidgets('reduceTransparency draws an opaque surface with a visible border, in the accent for prominent glass', (
    t,
  ) async {
    final theme = SheenThemeData.light(reduceTransparency: true);
    await t.pumpWidget(
      host(
        const Center(child: SheenGlass(child: SizedBox(width: 80, height: 40))),
        theme: theme,
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    final box = t.widget<DecoratedBox>(
      find.descendant(of: find.byType(SheenGlass), matching: find.byType(DecoratedBox)).first,
    );
    final deco = box.decoration as ShapeDecoration;
    expect(deco.color, theme.colors.surface);
    expect((deco.shape as OutlinedBorder).side.color, theme.colors.textTertiary);
    await t.pumpWidget(
      host(
        const Center(
          child: SheenGlass(variant: SheenGlassVariant.prominent, child: SizedBox(width: 80, height: 40)),
        ),
        theme: theme,
      ),
    );
    final p = t.widget<DecoratedBox>(
      find.descendant(of: find.byType(SheenGlass), matching: find.byType(DecoratedBox)).first,
    );
    expect((p.decoration as ShapeDecoration).color, theme.colors.accent);
  });
}
