import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Apple's tracking for San Francisco by point size: the iOS table of the Human Interface Guidelines (Typography ›
/// Tracking values, read 2026-10-03).
///
/// UIKit applies it to the system font by itself; Flutter does not, so text without it sets about 4 % wider than
/// native iOS text. Values are 1/1000 em; sizes between rows interpolate, sizes past the table clamp.
///
/// {@category Foundation}
abstract final class SheenTracking {
  static const Map<int, int> _em = {
    6: 41, 7: 34, 8: 26, 9: 19, 10: 12, 11: 6, 12: 0, 13: -6, 14: -11, 15: -16, 16: -20, 17: -26, 18: -25, 19: -24, //
    20: -23, 21: -18, 22: -12, 23: -4, 24: 3, 25: 6, 26: 8, 27: 11, 28: 14, 29: 14, 30: 14, 31: 13, 32: 13, 33: 12, //
    34: 12, 35: 11, 36: 10, 37: 10, 38: 10, 39: 10, 40: 10, 41: 9, 42: 9, 43: 9, 44: 8, 45: 8, 46: 8, 47: 8, 48: 8, //
    49: 7, 50: 7, 51: 7, 52: 6, 53: 6, 54: 6, 56: 6, 58: 5, 60: 4, 62: 4, 64: 4, 66: 3, 68: 2, 70: 2, 72: 2, 76: 1, //
    80: 0,
  };

  /// Tracking in logical points for text of [size] points.
  static double at(double size) {
    final keys = _em.keys.toList();
    if (size <= keys.first) return _em[keys.first]! / 1000 * size;
    if (size >= keys.last) return 0;
    var i = 1;
    while (keys[i] < size) {
      i++;
    }
    final lo = keys[i - 1], hi = keys[i];
    final f = (size - lo) / (hi - lo);
    final em = _em[lo]! + (_em[hi]! - _em[lo]!) * f;
    return em / 1000 * size;
  }
}

/// The type scale of a sheen theme.
///
/// The family is the platform's system font (SF Pro on iOS, Roboto or Noto on Android) unless you set one with
/// [withFamily]. Sizes are logical points and scale with the user's text size through the ambient `TextScaler`.
///
/// Every style pins its letter spacing and line height, so a host theme (for example Material's default text style)
/// cannot leak into them. [standard] carries Apple's tracking ([SheenTracking]) plus the design's own letter spacing;
/// [material] carries only the design's own. For a size other than the token's, use [sized], which keeps the
/// tracking right for the new size.
///
/// {@category Foundation}
@immutable
class SheenType with Diagnosticable {
  /// A type scale from its styles.
  const SheenType({
    required this.largeTitle,
    required this.title,
    required this.headline,
    required this.body,
    required this.subhead,
    required this.footnote,
    required this.caption,
    required this.tabLabel,
    required this.price,
    required this.timer,
    required this.sfTracking,
  });

  /// The large title at the top of a page (34 pt bold).
  final TextStyle largeTitle;

  /// Section and sheet titles (22 pt bold).
  final TextStyle title;

  /// Row titles, button labels, emphasised body text (17 pt semibold).
  final TextStyle headline;

  /// Running text (17 pt).
  final TextStyle body;

  /// Secondary lines and dense lists (15 pt).
  final TextStyle subhead;

  /// Notes under a group or a field (13 pt).
  final TextStyle footnote;

  /// Captions and badges (12 pt).
  final TextStyle caption;

  /// Tab bar labels (10 pt semibold).
  final TextStyle tabLabel;

  /// Amounts and totals: tabular figures, so columns of numbers line up.
  final TextStyle price;

  /// Countdowns: tabular figures, so the digits do not jump while they change.
  final TextStyle timer;

  /// Whether this scale applies [SheenTracking] (Apple platforms).
  final bool sfTracking;

  /// All styles of the scale, largest first.
  List<TextStyle> get styles => [largeTitle, title, headline, body, subhead, footnote, caption, tabLabel, price, timer];

  /// [style] at [size] points, with the tracking for that size plus [extraEm] of the design's own letter spacing.
  TextStyle sized(TextStyle style, double size, {double extraEm = 0}) =>
      style.copyWith(fontSize: size, letterSpacing: (sfTracking ? SheenTracking.at(size) : 0) + extraEm * size);

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// The scale for iOS and macOS: San Francisco tracking plus the design's own letter spacing.
  static const SheenType standard = SheenType(
    largeTitle: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.272, height: 1.1),
    title: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.484, height: 1.2),
    headline: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.442, height: 1.25),
    body: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: -0.442, height: 1.3),
    subhead: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.24, height: 1.3),
    footnote: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.078, height: 1.3),
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.25),
    tabLabel: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.22, height: 1.2),
    price: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.442,
      height: 1.2,
      fontFeatures: _tabular,
    ),
    timer: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.32,
      height: 1.2,
      fontFeatures: _tabular,
    ),
    sfTracking: true,
  );

  /// The scale for Android, the web and desktop: Roboto and Noto set their own spacing, so only the design's own
  /// letter spacing remains.
  static const SheenType material = SheenType(
    largeTitle: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.68, height: 1.1),
    title: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.22, height: 1.2),
    headline: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.25),
    body: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.3),
    subhead: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.3),
    footnote: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.3),
    caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.25),
    tabLabel: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.2),
    price: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.2, fontFeatures: _tabular),
    timer: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0, height: 1.2, fontFeatures: _tabular),
    sfTracking: false,
  );

  /// [standard] on iOS and macOS, [material] everywhere else.
  static SheenType forPlatform(TargetPlatform platform) => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => standard,
    _ => material,
  };

  /// A copy with every style set in [family] (a font your app bundles or a system family name).
  ///
  /// Letter spacing stays as it is; with a family other than San Francisco you may prefer [material] as the base.
  SheenType withFamily(String family, {List<String>? fallback}) {
    TextStyle f(TextStyle s) => s.copyWith(fontFamily: family, fontFamilyFallback: fallback);
    return copyWith(
      largeTitle: f(largeTitle),
      title: f(title),
      headline: f(headline),
      body: f(body),
      subhead: f(subhead),
      footnote: f(footnote),
      caption: f(caption),
      tabLabel: f(tabLabel),
      price: f(price),
      timer: f(timer),
    );
  }

  /// A copy with the given styles replaced.
  SheenType copyWith({
    TextStyle? largeTitle,
    TextStyle? title,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? subhead,
    TextStyle? footnote,
    TextStyle? caption,
    TextStyle? tabLabel,
    TextStyle? price,
    TextStyle? timer,
    bool? sfTracking,
  }) => SheenType(
    largeTitle: largeTitle ?? this.largeTitle,
    title: title ?? this.title,
    headline: headline ?? this.headline,
    body: body ?? this.body,
    subhead: subhead ?? this.subhead,
    footnote: footnote ?? this.footnote,
    caption: caption ?? this.caption,
    tabLabel: tabLabel ?? this.tabLabel,
    price: price ?? this.price,
    timer: timer ?? this.timer,
    sfTracking: sfTracking ?? this.sfTracking,
  );

  /// Blends every style of [a] and [b] at [t]; [sfTracking] switches at the midpoint.
  static SheenType lerp(SheenType a, SheenType b, double t) {
    if (identical(a, b) || t == 0) return a;
    if (t == 1) return b;
    TextStyle l(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return SheenType(
      largeTitle: l(a.largeTitle, b.largeTitle),
      title: l(a.title, b.title),
      headline: l(a.headline, b.headline),
      body: l(a.body, b.body),
      subhead: l(a.subhead, b.subhead),
      footnote: l(a.footnote, b.footnote),
      caption: l(a.caption, b.caption),
      tabLabel: l(a.tabLabel, b.tabLabel),
      price: l(a.price, b.price),
      timer: l(a.timer, b.timer),
      sfTracking: t < .5 ? a.sfTracking : b.sfTracking,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SheenType && other.sfTracking == sfTracking && listEquals(other.styles, styles);

  @override
  int get hashCode => Object.hash(sfTracking, Object.hashAll(styles));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextStyle>('body', body))
      ..add(FlagProperty('sfTracking', value: sfTracking, ifTrue: 'Apple tracking'));
  }
}
