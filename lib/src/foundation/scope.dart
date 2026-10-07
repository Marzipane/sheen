import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'motion.dart';
import 'strings.dart';
import 'theme.dart';

/// The root of a sheen app or screen.
///
/// Put one above your screens (in `MaterialApp.builder`, `CupertinoApp.builder`, or around `home`). It provides:
///
/// * the theme ([SheenTheme]): [theme] or [darkTheme], following the system brightness unless [brightness] is set;
/// * the fallback words ([SheenStrings]);
/// * one shared `BackdropGroup`, so every glass surface on the screen shares one copy of the backdrop instead of
///   taking its own (far less GPU work with many glass surfaces);
/// * the Reduce Motion watcher ([SheenMotionScope]);
/// * a default text style, icon colour and text selection colours from the theme;
/// * the status bar style for the brightness.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => SheenScope(
///     theme: SheenThemeData.light(accent: const Color(0xFF0A7D5A)),
///     darkTheme: SheenThemeData.dark(accent: const Color(0xFF2FB98A)),
///     child: child!,
///   ),
///   home: const HomePage(),
/// )
/// ```
///
/// {@category Foundation}
class SheenScope extends StatelessWidget {
  /// Provides sheen's theme, strings, backdrop group and motion scope to [child].
  const SheenScope({
    super.key,
    this.theme,
    this.darkTheme,
    this.brightness,
    this.strings = const SheenStrings(),
    this.reduceTransparency,
    required this.child,
  });

  /// The light theme; `SheenThemeData.light()` when null.
  final SheenThemeData? theme;

  /// The dark theme; `SheenThemeData.dark()` when null.
  final SheenThemeData? darkTheme;

  /// Forces light or dark; null follows the system setting.
  final Brightness? brightness;

  /// The fallback words of the widgets below.
  final SheenStrings strings;

  /// Overrides the theme's [SheenThemeData.reduceTransparency] when not null (wire it to an in-app setting).
  final bool? reduceTransparency;

  /// The app or screen.
  final Widget child;

  /// The theme this scope gives its subtree in [context].
  SheenThemeData resolve(BuildContext context) {
    final b = brightness ?? MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final data = b == Brightness.dark ? darkTheme ?? SheenThemeData.dark() : theme ?? SheenThemeData.light();
    final reduce = reduceTransparency;
    return reduce == null ? data : data.copyWith(reduceTransparency: reduce);
  }

  @override
  Widget build(BuildContext context) {
    final data = resolve(context);
    final c = data.colors;
    return SheenTheme(
      data: data,
      child: SheenStringsScope(
        strings: strings,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: data.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: SheenMotionScope(
            child: BackdropGroup(
              child: DefaultTextStyle(
                style: data.type.body.copyWith(color: c.text),
                child: IconTheme.merge(
                  data: IconThemeData(color: c.text),
                  child: DefaultSelectionStyle(
                    cursorColor: c.accent,
                    selectionColor: c.accent.withValues(alpha: .3),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
