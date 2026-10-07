import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  test('light and dark build matching parts from one accent', () {
    const pink = Color(0xFFD6336C);
    final t = SheenThemeData.dark(accent: pink, platform: TargetPlatform.android);
    expect(t.brightness, Brightness.dark);
    expect(t.isDark, isTrue);
    expect(t.colors.accent, pink);
    expect(t.glass.prominent.tint, pink);
    expect(t.type, SheenType.material);
    expect(SheenThemeData.light(platform: TargetPlatform.iOS).type, SheenType.standard);
    expect(SheenThemeData.light(platform: TargetPlatform.iOS).isDark, isFalse);
    expect(
      SheenThemeData.of(Brightness.dark, platform: TargetPlatform.iOS),
      SheenThemeData.dark(platform: TargetPlatform.iOS),
    );
    expect(SheenThemeData.of(Brightness.light, accent: pink).colors.accent, pink);
  });

  test('copyWith, == and lerp', () {
    final a = SheenThemeData.light(platform: TargetPlatform.iOS);
    expect(a, SheenThemeData.light(platform: TargetPlatform.iOS));
    expect(a.hashCode, SheenThemeData.light(platform: TargetPlatform.iOS).hashCode);
    expect(a.copyWith(reduceTransparency: true).reduceTransparency, isTrue);
    expect(a.copyWith(reduceTransparency: true), isNot(a));
    final b = SheenThemeData.dark(platform: TargetPlatform.iOS);
    final mid = SheenThemeData.lerp(a, b, .25);
    expect(mid.brightness, Brightness.light);
    expect(mid.colors.background, Color.lerp(a.colors.background, b.colors.background, .25));
    expect(SheenThemeData.lerp(a, b, .75).glass, b.glass);
    expect(SheenThemeData.lerp(a, b, .75).brightness, Brightness.dark);
  });

  testWidgets('context.sheen reads the nearest SheenTheme, else a default for the platform brightness', (t) async {
    late SheenThemeData seen;
    final probe = Builder(
      builder: (c) {
        seen = c.sheen;
        return const SizedBox();
      },
    );
    await t.pumpWidget(SheenTheme(data: SheenThemeData.dark(), child: probe));
    expect(seen.isDark, isTrue);
    t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(t.platformDispatcher.clearPlatformBrightnessTestValue);
    await t.pumpWidget(MediaQuery.fromView(view: t.view, child: probe));
    expect(seen.isDark, isTrue);
    t.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await t.pumpWidget(MediaQuery.fromView(view: t.view, child: probe));
    expect(seen.isDark, isFalse);
  });

  testWidgets('dependents rebuild when the data changes, not when it is equal', (t) async {
    var builds = 0;
    final probe = Builder(
      builder: (c) {
        c.sheen;
        builds++;
        return const SizedBox();
      },
    );
    await t.pumpWidget(SheenTheme(data: SheenThemeData.light(), child: probe));
    await t.pumpWidget(SheenTheme(data: SheenThemeData.light(), child: probe));
    expect(builds, 1);
    await t.pumpWidget(SheenTheme(data: SheenThemeData.dark(), child: probe));
    expect(builds, 2);
  });
}
