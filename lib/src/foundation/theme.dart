import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'glass_style.dart';
import 'type.dart';

/// The look of every sheen widget below a [SheenTheme]: brightness, colours, type and glass.
///
/// Build one from an accent colour with [SheenThemeData.light] or [SheenThemeData.dark] and change any part with
/// [copyWith]:
///
/// ```dart
/// final theme = SheenThemeData.light(accent: const Color(0xFFD6336C));
/// final calmer = theme.copyWith(colors: theme.colors.copyWith(background: const Color(0xFFF4F1EC)));
/// ```
///
/// Spacing, corner radii, layout widths and motion are fixed constants ([SheenSpace], [SheenRadius], [SheenLayout],
/// [SheenMotion]), not part of the theme.
///
/// {@category Foundation}
@immutable
class SheenThemeData with Diagnosticable {
  /// A theme from its parts. Prefer [SheenThemeData.light] or [SheenThemeData.dark], which keep the parts in step
  /// with one accent.
  const SheenThemeData.raw({
    required this.brightness,
    required this.colors,
    required this.type,
    required this.glass,
    this.reduceTransparency = false,
  });

  /// The light theme.
  ///
  /// [accent] fills prominent glass, primary buttons, selections, the switch and links. [platform] picks the type
  /// scale ([SheenType.forPlatform]); it defaults to the platform the app runs on.
  factory SheenThemeData.light({
    Color accent = SheenColors.defaultLightAccent,
    TargetPlatform? platform,
    bool reduceTransparency = false,
  }) => SheenThemeData.raw(
    brightness: Brightness.light,
    colors: SheenColors.light(accent: accent),
    type: SheenType.forPlatform(platform ?? defaultTargetPlatform),
    glass: SheenGlassStyles.light(accent: accent),
    reduceTransparency: reduceTransparency,
  );

  /// The dark theme; the parameters are those of [SheenThemeData.light].
  factory SheenThemeData.dark({
    Color accent = SheenColors.defaultDarkAccent,
    TargetPlatform? platform,
    bool reduceTransparency = false,
  }) => SheenThemeData.raw(
    brightness: Brightness.dark,
    colors: SheenColors.dark(accent: accent),
    type: SheenType.forPlatform(platform ?? defaultTargetPlatform),
    glass: SheenGlassStyles.dark(accent: accent),
    reduceTransparency: reduceTransparency,
  );

  /// [SheenThemeData.light] or [SheenThemeData.dark] for [brightness]; a null [accent] keeps that theme's default.
  factory SheenThemeData.of(
    Brightness brightness, {
    Color? accent,
    TargetPlatform? platform,
    bool reduceTransparency = false,
  }) => brightness == Brightness.dark
      ? SheenThemeData.dark(
          accent: accent ?? SheenColors.defaultDarkAccent,
          platform: platform,
          reduceTransparency: reduceTransparency,
        )
      : SheenThemeData.light(
          accent: accent ?? SheenColors.defaultLightAccent,
          platform: platform,
          reduceTransparency: reduceTransparency,
        );

  /// Whether the theme is light or dark.
  final Brightness brightness;

  /// The colours.
  final SheenColors colors;

  /// The type scale.
  final SheenType type;

  /// The glass recipes.
  final SheenGlassStyles glass;

  /// Draws glass as opaque surfaces, with the same shape and rim but no blur.
  ///
  /// Flutter exposes no system "Reduce Transparency" setting yet (flutter/flutter#190318), so an app sets this from
  /// its own setting. High-contrast mode (`MediaQuery.highContrastOf`) has the same effect by itself.
  final bool reduceTransparency;

  /// Whether [brightness] is dark.
  bool get isDark => brightness == Brightness.dark;

  /// A copy with the given parts replaced.
  SheenThemeData copyWith({
    Brightness? brightness,
    SheenColors? colors,
    SheenType? type,
    SheenGlassStyles? glass,
    bool? reduceTransparency,
  }) => SheenThemeData.raw(
    brightness: brightness ?? this.brightness,
    colors: colors ?? this.colors,
    type: type ?? this.type,
    glass: glass ?? this.glass,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
  );

  /// Blends [a] and [b] at [t]: colours and type blend; brightness, glass and [reduceTransparency] switch at the
  /// midpoint.
  static SheenThemeData lerp(SheenThemeData a, SheenThemeData b, double t) {
    if (identical(a, b) || t == 0) return a;
    if (t == 1) return b;
    final late = t >= .5;
    return SheenThemeData.raw(
      brightness: late ? b.brightness : a.brightness,
      colors: SheenColors.lerp(a.colors, b.colors, t),
      type: SheenType.lerp(a.type, b.type, t),
      glass: late ? b.glass : a.glass,
      reduceTransparency: late ? b.reduceTransparency : a.reduceTransparency,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SheenThemeData &&
      other.brightness == brightness &&
      other.colors == colors &&
      other.type == type &&
      other.glass == glass &&
      other.reduceTransparency == reduceTransparency;

  @override
  int get hashCode => Object.hash(brightness, colors, type, glass, reduceTransparency);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Brightness>('brightness', brightness))
      ..add(DiagnosticsProperty<SheenColors>('colors', colors))
      ..add(FlagProperty('reduceTransparency', value: reduceTransparency, ifTrue: 'reduce transparency'));
  }
}

/// Provides a [SheenThemeData] to the widgets below it.
///
/// [SheenScope] places one for you, picking the light or dark theme. It is an `InheritedTheme`, so dialogs and sheets
/// opened with `InheritedTheme.capture` (as sheen's own do) keep the theme of the screen that opened them. Use a [SheenTheme] directly to give part of a
/// screen another look, for example a dark card on a light page.
///
/// {@category Foundation}
class SheenTheme extends InheritedTheme {
  /// Provides [data] to [child] and its descendants.
  const SheenTheme({super.key, required this.data, required super.child});

  /// The theme for the subtree.
  final SheenThemeData data;

  /// The nearest theme, or the default theme for the platform brightness when there is none.
  static SheenThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheenTheme>()?.data ??
      SheenThemeData.of(MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light);

  @override
  Widget wrap(BuildContext context, Widget child) => SheenTheme(data: data, child: child);

  @override
  bool updateShouldNotify(SheenTheme oldWidget) => oldWidget.data != data;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheenThemeData>('data', data, showName: false));
  }
}

/// `context.sheen`: shorthand for [SheenTheme.of].
///
/// {@category Foundation}
extension SheenThemeContext on BuildContext {
  /// The nearest [SheenThemeData]; see [SheenTheme.of].
  SheenThemeData get sheen => SheenTheme.of(this);
}
