import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  test('prominent glass takes the accent and casts an accent shadow', () {
    const pink = Color(0xFFD6336C);
    final g = SheenGlassStyles.light(accent: pink);
    expect(g.prominent.tint, pink);
    expect(g.prominent.shadows.first.color, pink.withValues(alpha: .3));
    expect(SheenGlassStyles.dark(accent: pink).prominent.tint, pink);
    expect(SheenGlassStyles.dark(accent: pink).prominent.shadows.first.color, pink.withValues(alpha: .22));
  });

  test('the default recipes keep their values', () {
    expect(SheenGlassStyles.dark().regular.blur, 18);
    expect(SheenGlassStyles.light().regular.blur, 14);
    expect(SheenGlassStyles.light().clear.tint, const Color.fromRGBO(0, 0, 0, .2));
    expect(SheenGlassStyles.light().prominent.tint, SheenColors.defaultLightAccent);
    expect(SheenGlassStyles.dark().prominent.tint, SheenColors.defaultDarkAccent);
    expect(SheenGlassStyles.light().prominent.blur, 0, reason: 'prominent glass is opaque');
  });

  test('of(variant), copyWith and ==', () {
    final g = SheenGlassStyles.light();
    expect(g.of(SheenGlassVariant.regular), same(g.regular));
    expect(g.of(SheenGlassVariant.clear), same(g.clear));
    expect(g.of(SheenGlassVariant.prominent), same(g.prominent));
    expect(SheenGlassStyles.light(), SheenGlassStyles.light());
    expect(SheenGlassStyles.light().hashCode, SheenGlassStyles.light().hashCode);
    expect(SheenGlassStyles.light(), isNot(SheenGlassStyles.dark()));
    expect(g.regular.copyWith(blur: 30).blur, 30);
    expect(g.copyWith(regular: g.clear).regular, same(g.clear));
  });

  test('a CSS shadow maps blur radius 2σ to Flutter\'s blurRadius', () {
    expect(SheenGlassStyle.cssShadow(0, 10, 0, const Color(0xFF000000)).blurRadius, 0);
    expect(SheenGlassStyle.cssShadow(0, 10, 28, const Color(0xFF000000)).blurRadius, closeTo((14 - .5) / .57735, 1e-9));
  });
}
