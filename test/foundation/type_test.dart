import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

void main() {
  test('type sizes and tabular figures on number styles', () {
    const t = SheenType.standard;
    expect(t.largeTitle.fontSize, 34);
    expect(t.largeTitle.fontWeight, FontWeight.w700);
    expect(t.title.fontSize, 22);
    expect(t.headline.fontWeight, FontWeight.w600);
    expect(t.tabLabel.fontSize, 10);
    expect(t.price.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(t.timer.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('every style pins letter spacing and line height, so the host theme cannot leak into them', () {
    for (final t in [SheenType.standard, SheenType.material]) {
      for (final s in t.styles) {
        expect(s.letterSpacing, isNotNull, reason: '$s');
        expect(s.height, isNotNull, reason: '$s');
      }
    }
  });

  test('Apple tracking follows the HIG table and interpolates between rows', () {
    expect(SheenTracking.at(17), closeTo(-.442, 1e-9));
    expect(SheenTracking.at(12), 0);
    expect(SheenTracking.at(34), closeTo(.408, 1e-9));
    expect(SheenTracking.at(5), closeTo(.041 * 5, 1e-9));
    expect(SheenTracking.at(120), 0);
    expect(SheenTracking.at(16.5), closeTo(-.023 * 16.5, 1e-9));
  });

  test('the Apple scale is the tracking plus the design\'s own spacing; the Material scale is the design\'s only', () {
    const a = SheenType.standard, m = SheenType.material;
    expect(a.largeTitle.letterSpacing, closeTo(SheenTracking.at(34) - .02 * 34, .001));
    expect(a.title.letterSpacing, closeTo(SheenTracking.at(22) - .01 * 22, .001));
    expect(a.tabLabel.letterSpacing, closeTo(SheenTracking.at(10) + .01 * 10, .001));
    for (final (s, size) in [
      (a.headline, 17.0),
      (a.body, 17.0),
      (a.subhead, 15.0),
      (a.footnote, 13.0),
      (a.caption, 12.0),
      (a.price, 17.0),
      (a.timer, 16.0),
    ]) {
      expect(s.letterSpacing, closeTo(SheenTracking.at(size), .001), reason: '$size');
    }
    expect(m.body.letterSpacing, 0);
    expect(m.largeTitle.letterSpacing, closeTo(-.68, .001));
    expect(a.sized(a.headline, 18, extraEm: -.01).letterSpacing, closeTo(SheenTracking.at(18) - .18, 1e-9));
    expect(a.sized(a.headline, 18).fontSize, 18);
    expect(m.sized(m.subhead, 14).letterSpacing, 0);
  });

  test('the Apple scale on iOS and macOS, the Material one elsewhere', () {
    expect(SheenType.forPlatform(TargetPlatform.iOS), same(SheenType.standard));
    expect(SheenType.forPlatform(TargetPlatform.macOS), same(SheenType.standard));
    expect(SheenType.forPlatform(TargetPlatform.android), same(SheenType.material));
    expect(SheenType.forPlatform(TargetPlatform.windows), same(SheenType.material));
  });

  test('copyWith, lerp and ==', () {
    expect(SheenType.standard, SheenType.standard);
    expect(SheenType.standard, isNot(SheenType.material));
    final mid = SheenType.lerp(SheenType.standard, SheenType.material, .5);
    expect(mid.title.letterSpacing, closeTo((-0.484 + -0.22) / 2, 1e-9));
    expect(SheenType.standard.copyWith(body: const TextStyle(fontSize: 18)).body.fontSize, 18);
  });

  test('a font family applies to every style', () {
    final t = SheenType.standard.withFamily('Inter');
    expect(t.styles.map((s) => s.fontFamily), everyElement('Inter'));
    expect(t.title.letterSpacing, SheenType.standard.title.letterSpacing);
  });
}
