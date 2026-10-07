import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// Hosts [child] the way an app without Material would: a plain WidgetsApp with a SheenScope, the text direction,
/// text scale and Reduce Motion set above the navigator (as the platform sets them, so dialogs and sheets get them
/// too), and [child] at the top start of a page on the theme's background.
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  SheenThemeData? theme,
  double textScale = 1,
  bool reduceMotion = false,
  SheenStrings strings = const SheenStrings(),
}) => WidgetsApp(
  color: const Color(0xFF000000),
  debugShowCheckedModeBanner: false,
  // WidgetsApp, unlike MaterialApp and CupertinoApp, adds no HeroController.
  navigatorObservers: [HeroController()],
  pageRouteBuilder: <T>(settings, builder) =>
      PageRouteBuilder<T>(settings: settings, pageBuilder: (context, _, _) => builder(context)),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale), disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: direction,
      child: SheenScope(brightness: brightness, theme: theme, darkTheme: theme, strings: strings, child: navigator!),
    ),
  ),
  home: Builder(
    builder: (c) => ColoredBox(
      color: c.sheen.colors.background,
      child: Align(alignment: AlignmentDirectional.topStart, child: child),
    ),
  ),
);
