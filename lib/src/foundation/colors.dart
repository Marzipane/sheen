import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The colours of a sheen theme, one set per brightness.
///
/// Build a palette with [SheenColors.light] or [SheenColors.dark] and an accent; change single colours with
/// [copyWith]. Every text colour reads at WCAG AA (4.5:1) on [background] and [surface].
///
/// {@category Foundation}
@immutable
class SheenColors with Diagnosticable {
  /// A palette from its parts. Prefer [SheenColors.light] and [SheenColors.dark], which derive the accent colours.
  const SheenColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.track,
    required this.separator,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.success,
    required this.warning,
    required this.danger,
    required this.rating,
    required this.sheet,
  });

  /// The light palette.
  ///
  /// [accent] fills prominent glass, primary buttons, selections, the switch and links. It is also the accent text
  /// colour, so pick one with at least 4.5:1 contrast on white. The label colour on it ([onAccent]) is white or
  /// near-black, whichever reads better.
  factory SheenColors.light({Color accent = defaultLightAccent}) =>
      _light.copyWith(accent: accent, accentText: accent, onAccent: onColorFor(accent));

  /// The dark palette.
  ///
  /// [accent] fills the same surfaces as in [SheenColors.light]. The accent text is the accent lifted towards white
  /// until it reads at 4.5:1 on the dark background.
  factory SheenColors.dark({Color accent = defaultDarkAccent}) => _dark.copyWith(
    accent: accent,
    accentText: accent == defaultDarkAccent ? _dark.accentText : liftedFor(accent, _dark.background),
    onAccent: onColorFor(accent),
  );

  /// The default accent of the light theme, a blue with 5.6:1 contrast on white.
  static const Color defaultLightAccent = Color(0xFF0A5FE0);

  /// The default accent of the dark theme.
  static const Color defaultDarkAccent = Color(0xFF1F6FEB);

  static const SheenColors _dark = SheenColors(
    background: Color(0xFF05070B),
    surface: Color(0xFF0E1219),
    surfaceMuted: Color(0xFF161B24),
    track: Color(0xFF212734),
    separator: Color(0x17FFFFFF),
    text: Color(0xFFF5F6F8),
    textSecondary: Color(0xFFA9B0BD),
    textTertiary: Color(0xFF868E9D),
    accent: defaultDarkAccent,
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFF6AA8FF),
    success: Color(0xFF5EE08F),
    warning: Color(0xFFFFC266),
    danger: Color(0xFFFF7A7A),
    rating: Color(0xFFF5B83D),
    sheet: Color(0xFF10141B),
  );

  static const SheenColors _light = SheenColors(
    background: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF2F2EF),
    track: Color(0xFFE6E6E2),
    separator: Color(0x17101318),
    text: Color(0xFF101318),
    textSecondary: Color(0xFF555B66),
    textTertiary: Color(0xFF6A707B),
    accent: defaultLightAccent,
    onAccent: Color(0xFFFFFFFF),
    accentText: defaultLightAccent,
    success: Color(0xFF0B7A3E),
    warning: Color(0xFF8F5200),
    danger: Color(0xFFC62828),
    rating: Color(0xFFF5B83D),
    sheet: Color(0xFFFFFFFF),
  );

  /// The page ground.
  final Color background;

  /// Cards, lists and grouped rows.
  final Color surface;

  /// Inputs, secondary buttons and surfaces nested in a [surface].
  final Color surfaceMuted;

  /// Tracks of sliders, progress bars and switches; skeleton placeholders.
  final Color track;

  /// Hairline separators.
  final Color separator;

  /// Primary text and icons.
  final Color text;

  /// Secondary text: subtitles, captions, values next to a label.
  final Color textSecondary;

  /// Tertiary text: hints, placeholders, disabled labels.
  final Color textTertiary;

  /// The accent fill: prominent glass, primary buttons, selected states, the switch. Labels on it use [onAccent].
  final Color accent;

  /// Labels and icons drawn on [accent].
  final Color onAccent;

  /// Accent-coloured text and icons on [background] or [surface]: links, selected tab labels. Never put white text on
  /// it.
  final Color accentText;

  /// Positive states: success, available, included, free cancellation.
  final Color success;

  /// Caution states: time running out, conditions apply.
  final Color warning;

  /// Errors, destructive actions and the last moments of a countdown.
  final Color danger;

  /// Star rating glyphs.
  final Color rating;

  /// The background of sheets and dialogs.
  final Color sheet;

  /// White or near-black, whichever reads better on [color].
  static Color onColorFor(Color color) =>
      color.computeLuminance() > .4 ? const Color(0xFF101318) : const Color(0xFFFFFFFF);

  /// [color] mixed with white in 5 % steps until it reaches 4.5:1 contrast on [ground].
  static Color liftedFor(Color color, Color ground) {
    for (var i = 0; i <= 20; i++) {
      final mixed = Color.lerp(color, const Color(0xFFFFFFFF), i / 20)!;
      if (contrastOf(mixed, ground) >= 4.5) return mixed;
    }
    return const Color(0xFFFFFFFF);
  }

  /// The WCAG contrast ratio of two opaque colours, from 1 to 21.
  static double contrastOf(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
  }

  /// A copy with the given colours replaced.
  SheenColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? track,
    Color? separator,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentText,
    Color? success,
    Color? warning,
    Color? danger,
    Color? rating,
    Color? sheet,
  }) => SheenColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    track: track ?? this.track,
    separator: separator ?? this.separator,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentText: accentText ?? this.accentText,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    rating: rating ?? this.rating,
    sheet: sheet ?? this.sheet,
  );

  /// Blends every colour of [a] and [b] at [t] (0 gives [a], 1 gives [b]).
  static SheenColors lerp(SheenColors a, SheenColors b, double t) {
    if (identical(a, b) || t == 0) return a;
    if (t == 1) return b;
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return SheenColors(
      background: l(a.background, b.background),
      surface: l(a.surface, b.surface),
      surfaceMuted: l(a.surfaceMuted, b.surfaceMuted),
      track: l(a.track, b.track),
      separator: l(a.separator, b.separator),
      text: l(a.text, b.text),
      textSecondary: l(a.textSecondary, b.textSecondary),
      textTertiary: l(a.textTertiary, b.textTertiary),
      accent: l(a.accent, b.accent),
      onAccent: l(a.onAccent, b.onAccent),
      accentText: l(a.accentText, b.accentText),
      success: l(a.success, b.success),
      warning: l(a.warning, b.warning),
      danger: l(a.danger, b.danger),
      rating: l(a.rating, b.rating),
      sheet: l(a.sheet, b.sheet),
    );
  }

  List<Color> get _all => [
    background,
    surface,
    surfaceMuted,
    track,
    separator,
    text,
    textSecondary,
    textTertiary,
    accent,
    onAccent,
    accentText,
    success,
    warning,
    danger,
    rating,
    sheet,
  ];

  @override
  bool operator ==(Object other) => other is SheenColors && listEquals(other._all, _all);

  @override
  int get hashCode => Object.hashAll(_all);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('background', background))
      ..add(ColorProperty('text', text))
      ..add(ColorProperty('accent', accent))
      ..add(ColorProperty('accentText', accentText));
  }
}

/// Text and icons over photos: white with a soft shadow in both themes, because a photo's lower edge is always
/// darkened behind them.
///
/// {@category Foundation}
abstract final class SheenOnPhoto {
  /// Primary text over a photo.
  static const Color text = Color(0xFFFFFFFF);

  /// Secondary text over a photo, such as a credit line.
  static const Color textSecondary = Color(0x9EFFFFFF);

  /// The colour of [textShadow].
  static const Color shadow = Color(0x59000000);

  /// The shadow under text that sits on a photo.
  static const List<Shadow> textShadow = [Shadow(color: shadow, blurRadius: 16, offset: Offset(0, 2))];
}

/// Tile colours behind list-row glyphs, the way iOS Settings marks each kind of row: a white glyph on a colour that
/// names the row's kind. The same in both themes.
///
/// {@category Foundation}
abstract final class SheenTint {
  /// Blue.
  static const Color blue = Color(0xFF1F6FEB);

  /// Red.
  static const Color red = Color(0xFFE5484D);

  /// Green.
  static const Color green = Color(0xFF30A46C);

  /// Orange.
  static const Color orange = Color(0xFFF76B15);

  /// Purple.
  static const Color purple = Color(0xFF6E56CF);

  /// Teal.
  static const Color teal = Color(0xFF0090A8);

  /// Violet.
  static const Color violet = Color(0xFF8E4EC6);

  /// Gray.
  static const Color gray = Color(0xFF6A707B);

  /// All tints, in a stable order (for picking one by a hash, as avatars do).
  static const List<Color> all = [blue, red, green, orange, purple, teal, violet, gray];
}
