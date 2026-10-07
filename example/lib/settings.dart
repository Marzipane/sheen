import 'package:flutter/widgets.dart';

/// How the gallery looks: the switches on its settings sheet.
@immutable
class GallerySettings {
  const GallerySettings({
    this.brightness,
    this.rtl = false,
    this.textScale = 1,
    this.reduceTransparency = false,
    this.reduceMotion = false,
    this.accent = 'blue',
  });

  /// Null follows the system.
  final Brightness? brightness;
  final bool rtl;
  final double textScale;
  final bool reduceTransparency;
  final bool reduceMotion;

  /// A key of [accents].
  final String accent;

  /// The accent swatches: light and dark accents (null keeps sheen's default).
  static const Map<String, (Color?, Color?)> accents = {
    'blue': (null, null),
    'pink': (Color(0xFFC2255C), Color(0xFFE64980)),
    'green': (Color(0xFF087F5B), Color(0xFF20C997)),
    'orange': (Color(0xFFC2410C), Color(0xFFF76707)),
    'violet': (Color(0xFF6741D9), Color(0xFF845EF7)),
  };

  /// The settings a launch asks for: `--dart-define=DARK=1` and friends, or `?dark=1` on the web.
  static GallerySettings fromLaunch(Map<String, String> query) {
    String? read(String key, String define) => query[key] ?? (define.isEmpty ? null : define);
    final dark = read('dark', const String.fromEnvironment('DARK'));
    return GallerySettings(
      brightness: dark == null ? null : (dark == '1' ? Brightness.dark : Brightness.light),
      rtl: read('rtl', const String.fromEnvironment('RTL')) == '1',
      textScale: double.tryParse(read('scale', const String.fromEnvironment('SCALE')) ?? '') ?? 1,
      accent: accents.containsKey(read('accent', const String.fromEnvironment('ACCENT')))
          ? read('accent', const String.fromEnvironment('ACCENT'))!
          : 'blue',
    );
  }

  GallerySettings copyWith({
    Brightness? Function()? brightness,
    bool? rtl,
    double? textScale,
    bool? reduceTransparency,
    bool? reduceMotion,
    String? accent,
  }) => GallerySettings(
    brightness: brightness == null ? this.brightness : brightness(),
    rtl: rtl ?? this.rtl,
    textScale: textScale ?? this.textScale,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    accent: accent ?? this.accent,
  );
}

/// Gives every page the settings and a way to change them.
class GallerySettingsScope extends InheritedWidget {
  const GallerySettingsScope({super.key, required this.settings, required this.update, required super.child});

  final GallerySettings settings;
  final ValueChanged<GallerySettings> update;

  static GallerySettingsScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GallerySettingsScope>()!;

  @override
  bool updateShouldNotify(GallerySettingsScope old) => old.settings != settings;
}
