import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

void main() {
  test('the default palettes keep the approved values', () {
    expect(SheenColors.light().accent, const Color(0xFF0A5FE0));
    expect(SheenColors.dark().accent, const Color(0xFF1F6FEB));
    expect(SheenColors.dark().accentText, const Color(0xFF6AA8FF));
    expect(SheenColors.light().background, const Color(0xFFFAFAF8));
    expect(SheenColors.dark().background, const Color(0xFF05070B));
  });

  test('one accent drives the accent, the accent text and the label on it', () {
    const pink = Color(0xFFD6336C);
    final light = SheenColors.light(accent: pink), dark = SheenColors.dark(accent: pink);
    expect(light.accent, pink);
    expect(light.accentText, pink);
    expect(dark.accent, pink);
    expect(contrast(dark.accentText, dark.background), greaterThanOrEqualTo(4.5));
    expect(light.onAccent, const Color(0xFFFFFFFF));
  });

  test('a light accent gets dark labels', () {
    expect(SheenColors.light(accent: const Color(0xFFFFD43B)).onAccent, const Color(0xFF101318));
  });

  test('text tokens pass WCAG AA on the page and on cards', () {
    for (final c in [SheenColors.light(), SheenColors.dark()]) {
      for (final ink in [c.text, c.textSecondary, c.textTertiary, c.accentText, c.danger, c.success]) {
        expect(contrast(ink, c.background), greaterThanOrEqualTo(4.5), reason: '$ink on ${c.background}');
        expect(contrast(ink, c.surface), greaterThanOrEqualTo(4.5), reason: '$ink on ${c.surface}');
      }
      expect(contrast(c.onAccent, c.accent), greaterThanOrEqualTo(4.5));
    }
  });

  test('copyWith, == and lerp', () {
    final a = SheenColors.light(), b = SheenColors.dark();
    expect(a.copyWith(danger: const Color(0xFF000000)).danger, const Color(0xFF000000));
    expect(a.copyWith(danger: const Color(0xFF000000)), isNot(a));
    expect(SheenColors.light(), SheenColors.light());
    expect(SheenColors.light().hashCode, SheenColors.light().hashCode);
    expect(SheenColors.lerp(a, b, .5).background, Color.lerp(a.background, b.background, .5));
    expect(SheenColors.lerp(a, b, 0), a);
    expect(SheenColors.lerp(a, b, 1), b);
  });
}
