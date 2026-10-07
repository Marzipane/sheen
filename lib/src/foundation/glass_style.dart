import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

/// The three kinds of glass.
///
/// {@category Glass}
enum SheenGlassVariant {
  /// Frosted glass for bars, buttons and controls over the page.
  regular,

  /// Thinner, clearer glass for controls that sit on photos (with a dim behind them).
  clear,

  /// Opaque glass tinted with the accent: the one prominent action of a view.
  prominent,
}

Color _w(double a) => Color.fromRGBO(255, 255, 255, a);
Color _k(double a) => Color.fromRGBO(0, 0, 0, a);

/// One glass recipe: a body gradient over a tint, a backdrop blur with saturation and brightness, a 1 px gradient rim,
/// inner edge lines, a specular highlight and an outer shadow.
///
/// You rarely build one: [SheenGlassStyles] holds the recipes of a theme, and [SheenGlassStyle.copyWith] adjusts one.
///
/// {@category Glass}
@immutable
class SheenGlassStyle with Diagnosticable {
  /// A glass recipe from its parts.
  const SheenGlassStyle({
    required this.tint,
    required this.body,
    required this.bodyStops,
    required this.blur,
    required this.saturation,
    required this.brightness,
    required this.rim,
    required this.rimStops,
    required this.rimAngle,
    required this.innerTop,
    this.innerTopWidth = .5,
    this.innerBottom,
    this.innerRing,
    this.highlight,
    this.highlightCenter = const Alignment(-.44, -1.2),
    this.highlightStop = .58,
    required this.shadows,
  });

  /// A CSS `box-shadow` as a [BoxShadow] with the same Gaussian: CSS takes the blur as 2σ, while Flutter's
  /// `blurRadius` maps to σ = r · 0.57735 + 0.5.
  static BoxShadow cssShadow(double x, double y, double blur, Color color) =>
      BoxShadow(offset: Offset(x, y), blurRadius: blur <= 0 ? 0 : math.max(0, (blur / 2 - .5) / .57735), color: color);

  /// The solid colour under the body gradient (transparent when the gradient is the whole body).
  final Color tint;

  /// The body gradient, top to bottom.
  final List<Color> body;

  /// The stops of [body].
  final List<double> bodyStops;

  /// The backdrop blur σ in logical pixels; 0 means no backdrop filter (the glass is opaque).
  final double blur;

  /// The backdrop's saturation factor (1 leaves it unchanged).
  final double saturation;

  /// The backdrop's brightness factor (1 leaves it unchanged).
  final double brightness;

  /// The 1 px rim gradient.
  final List<Color> rim;

  /// The stops of [rim].
  final List<double> rimStops;

  /// The rim gradient's angle in CSS degrees (180 runs top to bottom).
  final double rimAngle;

  /// The inner top edge, a specular line.
  final Color innerTop;

  /// The width of [innerTop].
  final double innerTopWidth;

  /// An optional inner bottom edge.
  final Color? innerBottom;

  /// An optional hairline ring inside the rim.
  final Color? innerRing;

  /// The peak colour of the radial specular highlight from above the top-left corner.
  final Color? highlight;

  /// Where the highlight is centred.
  final Alignment highlightCenter;

  /// Where the highlight has faded out, as a fraction of its radius.
  final double highlightStop;

  /// The outer shadows.
  final List<BoxShadow> shadows;

  /// A copy with the given parts replaced.
  SheenGlassStyle copyWith({
    Color? tint,
    List<Color>? body,
    List<double>? bodyStops,
    double? blur,
    double? saturation,
    double? brightness,
    List<Color>? rim,
    List<double>? rimStops,
    double? rimAngle,
    Color? innerTop,
    double? innerTopWidth,
    Color? innerBottom,
    Color? innerRing,
    Color? highlight,
    Alignment? highlightCenter,
    double? highlightStop,
    List<BoxShadow>? shadows,
  }) => SheenGlassStyle(
    tint: tint ?? this.tint,
    body: body ?? this.body,
    bodyStops: bodyStops ?? this.bodyStops,
    blur: blur ?? this.blur,
    saturation: saturation ?? this.saturation,
    brightness: brightness ?? this.brightness,
    rim: rim ?? this.rim,
    rimStops: rimStops ?? this.rimStops,
    rimAngle: rimAngle ?? this.rimAngle,
    innerTop: innerTop ?? this.innerTop,
    innerTopWidth: innerTopWidth ?? this.innerTopWidth,
    innerBottom: innerBottom ?? this.innerBottom,
    innerRing: innerRing ?? this.innerRing,
    highlight: highlight ?? this.highlight,
    highlightCenter: highlightCenter ?? this.highlightCenter,
    highlightStop: highlightStop ?? this.highlightStop,
    shadows: shadows ?? this.shadows,
  );

  @override
  bool operator ==(Object other) =>
      other is SheenGlassStyle &&
      other.tint == tint &&
      listEquals(other.body, body) &&
      listEquals(other.bodyStops, bodyStops) &&
      other.blur == blur &&
      other.saturation == saturation &&
      other.brightness == brightness &&
      listEquals(other.rim, rim) &&
      listEquals(other.rimStops, rimStops) &&
      other.rimAngle == rimAngle &&
      other.innerTop == innerTop &&
      other.innerTopWidth == innerTopWidth &&
      other.innerBottom == innerBottom &&
      other.innerRing == innerRing &&
      other.highlight == highlight &&
      other.highlightCenter == highlightCenter &&
      other.highlightStop == highlightStop &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(
    tint,
    Object.hashAll(body),
    Object.hashAll(bodyStops),
    blur,
    saturation,
    brightness,
    Object.hashAll(rim),
    Object.hashAll(rimStops),
    rimAngle,
    innerTop,
    innerTopWidth,
    innerBottom,
    innerRing,
    highlight,
    highlightCenter,
    highlightStop,
    Object.hashAll(shadows),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('tint', tint))
      ..add(DoubleProperty('blur', blur));
  }
}

/// The lens that marks a selected tab or segment.
///
/// {@category Glass}
@immutable
class SheenLensStyle with Diagnosticable {
  /// A lens from its fill, inner top edge and optional ring.
  const SheenLensStyle({required this.fill, required this.innerTop, this.innerTopWidth = .5, this.ring});

  /// The lens body.
  final Color fill;

  /// The inner top edge.
  final Color innerTop;

  /// The width of [innerTop].
  final double innerTopWidth;

  /// An optional hairline ring.
  final Color? ring;

  @override
  bool operator ==(Object other) =>
      other is SheenLensStyle &&
      other.fill == fill &&
      other.innerTop == innerTop &&
      other.innerTopWidth == innerTopWidth &&
      other.ring == ring;

  @override
  int get hashCode => Object.hash(fill, innerTop, innerTopWidth, ring);
}

/// The glass recipes of a theme: [regular], [clear] and [prominent] glass and the selection [lens].
///
/// [SheenGlassStyles.light] and [SheenGlassStyles.dark] build prominent glass from the theme's accent, so one colour
/// recolours every prominent action.
///
/// {@category Glass}
@immutable
class SheenGlassStyles with Diagnosticable {
  /// Glass recipes from their parts.
  const SheenGlassStyles({required this.regular, required this.clear, required this.prominent, required this.lens});

  /// Light glass: white rims and soft shadows; prominent glass tinted with [accent].
  factory SheenGlassStyles.light({Color accent = SheenColors.defaultLightAccent}) => SheenGlassStyles(
    regular: _regularLight,
    clear: _clearLight,
    prominent: SheenGlassStyle(
      tint: accent,
      body: [_w(.28), _w(0)],
      bodyStops: const [0, .55],
      blur: 0,
      saturation: 1,
      brightness: 1,
      rim: [_w(.7), _w(.15), _w(.08), _w(.35)],
      rimStops: const [0, .4, .62, 1],
      rimAngle: 160,
      innerTop: _w(.6),
      innerTopWidth: 1,
      innerBottom: _k(.18),
      shadows: [SheenGlassStyle.cssShadow(0, 8, 22, accent.withValues(alpha: .3))],
    ),
    lens: _lensLight,
  );

  /// Dark glass: matte, a soft rim, almost no highlight; prominent glass tinted with [accent].
  factory SheenGlassStyles.dark({Color accent = SheenColors.defaultDarkAccent}) => SheenGlassStyles(
    regular: _regularDark,
    clear: _clearDark,
    prominent: SheenGlassStyle(
      tint: accent,
      body: [_w(.1), _w(0)],
      bodyStops: const [0, .6],
      blur: 0,
      saturation: 1,
      brightness: 1,
      rim: [_w(.3), _w(.08), _w(.12)],
      rimStops: const [0, .5, 1],
      rimAngle: 170,
      innerTop: _w(.3),
      shadows: [SheenGlassStyle.cssShadow(0, 6, 16, accent.withValues(alpha: .22))],
    ),
    lens: _lensDark,
  );

  /// Frosted glass for bars, buttons and controls.
  final SheenGlassStyle regular;

  /// Clear glass for controls on photos.
  final SheenGlassStyle clear;

  /// Accent-tinted glass for the one prominent action of a view.
  final SheenGlassStyle prominent;

  /// The lens behind a selected tab or segment.
  final SheenLensStyle lens;

  /// The recipe for [variant].
  SheenGlassStyle of(SheenGlassVariant variant) => switch (variant) {
    SheenGlassVariant.regular => regular,
    SheenGlassVariant.clear => clear,
    SheenGlassVariant.prominent => prominent,
  };

  /// A copy with the given recipes replaced.
  SheenGlassStyles copyWith({
    SheenGlassStyle? regular,
    SheenGlassStyle? clear,
    SheenGlassStyle? prominent,
    SheenLensStyle? lens,
  }) => SheenGlassStyles(
    regular: regular ?? this.regular,
    clear: clear ?? this.clear,
    prominent: prominent ?? this.prominent,
    lens: lens ?? this.lens,
  );

  @override
  bool operator ==(Object other) =>
      other is SheenGlassStyles &&
      other.regular == regular &&
      other.clear == clear &&
      other.prominent == prominent &&
      other.lens == lens;

  @override
  int get hashCode => Object.hash(regular, clear, prominent, lens);

  static final SheenGlassStyle _regularDark = SheenGlassStyle(
    tint: const Color.fromRGBO(28, 31, 38, .6),
    body: [_w(.075), _w(.035)],
    bodyStops: const [0, 1],
    blur: 18,
    saturation: 1.6,
    brightness: 1,
    rim: [_w(.2), _w(.07), _w(.05), _w(.1)],
    rimStops: const [0, .45, .75, 1],
    rimAngle: 170,
    innerTop: _w(.18),
    highlight: _w(.05),
    highlightCenter: const Alignment(-.4, -1.4),
    highlightStop: .6,
    shadows: [SheenGlassStyle.cssShadow(0, 10, 28, _k(.42)), SheenGlassStyle.cssShadow(0, 1, 2, _k(.3))],
  );

  static final SheenGlassStyle _regularLight = SheenGlassStyle(
    tint: const Color(0x00FFFFFF),
    body: [_w(.82), _w(.5), _w(.64)],
    bodyStops: const [0, .5, 1],
    blur: 14,
    saturation: 2,
    brightness: 1.06,
    rim: [_w(1), _w(.4), _w(.2), _w(.9)],
    rimStops: const [0, .35, .62, 1],
    rimAngle: 160,
    innerTop: _w(1),
    innerTopWidth: 1,
    innerBottom: _w(.7),
    innerRing: _k(.05),
    highlight: _w(.6),
    highlightStop: .6,
    shadows: [
      SheenGlassStyle.cssShadow(0, 10, 30, const Color.fromRGBO(16, 20, 30, .14)),
      SheenGlassStyle.cssShadow(0, 1, 3, const Color.fromRGBO(16, 20, 30, .08)),
    ],
  );

  static final SheenGlassStyle _clearDark = SheenGlassStyle(
    tint: _k(.28),
    body: [_w(.12), _w(.05)],
    bodyStops: const [0, 1],
    blur: 9,
    saturation: 1.7,
    brightness: 1.04,
    rim: [_w(.38), _w(.12), _w(.08), _w(.2)],
    rimStops: const [0, .45, .75, 1],
    rimAngle: 170,
    innerTop: _w(.3),
    highlight: _w(.16),
    shadows: [SheenGlassStyle.cssShadow(0, 6, 18, _k(.25))],
  );

  static final SheenGlassStyle _clearLight = SheenGlassStyle(
    tint: _k(.2),
    body: [_w(.2), _w(.06), _w(.1)],
    bodyStops: const [0, .5, 1],
    blur: 9,
    saturation: 1.7,
    brightness: 1.04,
    rim: [_w(.8), _w(.2), _w(.1), _w(.45)],
    rimStops: const [0, .35, .62, 1],
    rimAngle: 160,
    innerTop: _w(.62),
    innerTopWidth: 1,
    innerBottom: _w(.18),
    highlight: _w(.16),
    shadows: [SheenGlassStyle.cssShadow(0, 6, 20, _k(.28))],
  );

  static final SheenLensStyle _lensDark = SheenLensStyle(fill: _w(.11), innerTop: _w(.14));

  static final SheenLensStyle _lensLight = SheenLensStyle(
    fill: const Color.fromRGBO(118, 118, 128, .14),
    innerTop: _w(.9),
    innerTopWidth: 1,
    ring: _k(.04),
  );
}
