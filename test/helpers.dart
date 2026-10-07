import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// Hosts [child] the way an app without Material would: a plain WidgetsApp under a SheenScope, on the theme's
/// background.
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  SheenThemeData? theme,
  double textScale = 1,
  SheenStrings strings = const SheenStrings(),
}) => WidgetsApp(
  color: const Color(0xFF000000),
  debugShowCheckedModeBanner: false,
  // WidgetsApp, unlike MaterialApp and CupertinoApp, adds no HeroController.
  navigatorObservers: [HeroController()],
  pageRouteBuilder: <T>(settings, builder) =>
      PageRouteBuilder<T>(settings: settings, pageBuilder: (context, _, _) => builder(context)),
  home: SheenScope(
    brightness: brightness,
    theme: theme,
    darkTheme: theme,
    strings: strings,
    child: Builder(
      builder: (c) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: direction,
          child: ColoredBox(color: c.sheen.colors.background, child: child),
        ),
      ),
    ),
  ),
);
