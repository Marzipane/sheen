import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// One look of a family: theme and reading direction.
enum Look {
  dark(Brightness.dark, TextDirection.ltr),
  light(Brightness.light, TextDirection.ltr),
  rtl(Brightness.dark, TextDirection.rtl);

  const Look(this.brightness, this.direction);
  final Brightness brightness;
  final TextDirection direction;
}

/// A photo-like backdrop so glass has something to refract.
Widget overPhoto(Widget child) => DecoratedBox(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D3B5C), Color(0xFF6A4C7A), Color(0xFFC9845C)],
    ),
  ),
  child: Padding(padding: const EdgeInsets.all(12), child: child),
);

/// A stand-in photo for cards: a fixed gradient, so the golden does not depend on image decoding.
Widget fakePhoto(BuildContext context, int i) => DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF2E5C8A), Color.lerp(const Color(0xFF7FA35A), const Color(0xFFB0703C), i / 4)!],
    ),
  ),
);

/// One golden per look for a family: each scenario in the look's tokens, direction and background, with tickers
/// stopped so spinners and shimmers hold still.
void familyGoldens(String family, List<(String, Widget Function())> scenarios) {
  for (final look in Look.values) {
    goldenTest(
      '$family (${look.name})',
      fileName: '${family}_${look.name}',
      builder: () {
        // the goldens draw text in the Roboto that ships with Flutter (see flutter_test_config.dart)
        final theme = SheenThemeData.of(look.brightness).copyWith(type: SheenType.material.withFamily('Roboto'));
        return SheenScope(
          brightness: look.brightness,
          theme: theme,
          darkTheme: theme,
          child: Directionality(
            textDirection: look.direction,
            child: TickerMode(
              enabled: false,
              child: ColoredBox(
                color: theme.colors.background,
                child: GoldenTestGroup(
                  columns: 2,
                  // Fixed columns: an intrinsic-width table would ask LayoutBuilder-based components for intrinsics.
                  columnWidthBuilder: (_) => const FixedColumnWidth(414),
                  scenarioConstraints: const BoxConstraints(maxWidth: 390),
                  children: [
                    for (final (name, build) in scenarios)
                      GoldenTestScenario(
                        name: name,
                        child: Builder(builder: (_) => build()),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
