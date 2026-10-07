import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'catalog.dart';
import 'pages/home.dart';
import 'settings.dart';

void main() => runApp(const SheenGalleryApp());

/// The gallery: a plain [WidgetsApp] (no Material) under a [SheenScope] that follows the gallery's settings.
class SheenGalleryApp extends StatefulWidget {
  const SheenGalleryApp({super.key, this.initial});

  /// Settings to start with; read from the launch (`--dart-define`, or the web address) when null.
  final GallerySettings? initial;

  @override
  State<SheenGalleryApp> createState() => _SheenGalleryAppState();
}

class _SheenGalleryAppState extends State<SheenGalleryApp> {
  late GallerySettings _settings = widget.initial ?? GallerySettings.fromLaunch(Uri.base.queryParameters);

  /// The page to open first: `--dart-define=PAGE=inputs`, or `?page=inputs` on the web.
  static String get _launchPage => Uri.base.queryParameters['page'] ?? const String.fromEnvironment('PAGE');

  @override
  Widget build(BuildContext context) {
    final s = _settings;
    final (light, dark) = GallerySettings.accents[s.accent]!;
    final page = _launchPage;
    return GallerySettingsScope(
      settings: s,
      update: (next) => setState(() => _settings = next),
      child: WidgetsApp(
        title: 'sheen gallery',
        color: SheenColors.defaultLightAccent,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [HeroController()],
        initialRoute: catalog.any((p) => p.id == page) ? '/$page' : '/',
        onGenerateRoute: (settings) {
          final name = settings.name ?? '/';
          final spec = catalog.where((p) => '/${p.id}' == name).firstOrNull;
          return GalleryRoute<void>(settings: settings, builder: (_) => spec == null ? const HomePage() : spec.page());
        },
        builder: (context, navigator) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(s.textScale),
              disableAnimations: s.reduceMotion || mq.disableAnimations,
            ),
            child: Directionality(
              textDirection: s.rtl ? TextDirection.rtl : TextDirection.ltr,
              child: SheenScope(
                brightness: s.brightness,
                theme: light == null ? SheenThemeData.light() : SheenThemeData.light(accent: light),
                darkTheme: dark == null ? SheenThemeData.dark() : SheenThemeData.dark(accent: dark),
                reduceTransparency: s.reduceTransparency,
                child: navigator!,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A page route that slides in from the end of the line, as iOS pushes do; a cross-fade with Reduce Motion.
class GalleryRoute<T> extends PageRoute<T> {
  GalleryRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => SheenMotion.smoothSettle;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (SheenMotion.reduced(context)) return FadeTransition(opacity: animation, child: child);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final curve = SheenMotion.curveOf(SheenMotion.smooth);
    return SlideTransition(
      position: Tween(
        begin: Offset(rtl ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve, reverseCurve: SheenMotion.easeIn)),
      child: SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: Offset(rtl ? .3 : -.3, 0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve)),
        child: child,
      ),
    );
  }
}
