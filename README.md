# sheen

Frosted glass for Flutter: a design system with one-accent theming, spring motion and 80+ widgets. It is built on
`package:flutter/widgets.dart`, so it works under `MaterialApp`, `CupertinoApp` or a plain `WidgetsApp`.

[![pub package](https://img.shields.io/pub/v/sheen.svg)](https://pub.dev/packages/sheen)
[![pub points](https://img.shields.io/pub/points/sheen)](https://pub.dev/packages/sheen/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/Marzipane/sheen/actions/workflows/ci.yml/badge.svg)](https://github.com/Marzipane/sheen/actions/workflows/ci.yml)

<p align="center">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/01-glass.webp" width="240" alt="Glass toolbar, segmented control, chips, an action bar and the tab bar over a photo">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/05-sheet.webp" width="240" alt="A sheet with switches over a page">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/02-accent-dark.webp" width="240" alt="The same glass in the dark theme with a pink accent">
</p>

**[Live demo](https://marzipane.github.io/sheen/)** ·
**[API docs](https://pub.dev/documentation/sheen/latest/)** ·
**[Example](example/)** ·
**[Changelog](CHANGELOG.md)**

## Why sheen

- **Glass that is cheap to draw.** Every glass surface under a `SheenScope` shares one copy of the backdrop
  (`BackdropGroup`), so a screen full of glass blurs once, not once per button. No shaders, no platform views.
- **Accessible by default.** Reduce Motion turns springs into fades; high contrast and `reduceTransparency` turn glass
  opaque; text grows to 200 % without overflowing; every widget mirrors in right-to-left languages; icon-only buttons
  require a label.
- **One accent recolours everything.** Prominent glass, primary buttons, selection, switches, sliders and links follow
  `SheenThemeData.light(accent: ...)`; in the dark theme, accent text is lifted until it reads on the dark ground.
- **No Material required.** Widgets build on the widgets layer and bring their own theme, strings and routes (sheets,
  menus, alerts). Text inputs use Flutter's `TextField` and work under any app.
- **More than glass.** Pages with large titles, sheets with detents, a date-range picker, one-time-code and password
  fields, toasts, skeletons, empty states, a steps line, rolling digits, and a travel library with hotel cards, prices
  and map pins.

## Install

```bash
flutter pub add sheen
```

## Quick start

Put a `SheenScope` above your screens, then build with `Sheen*` widgets and read the theme with `context.sheen`:

```dart
import 'package:flutter/material.dart';
import 'package:sheen/sheen.dart';

void main() => runApp(
  MaterialApp(
    builder: (context, child) => SheenScope(child: child!),
    home: const HomePage(),
  ),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Hello',
    children: [
      SheenGlass(
        padding: const EdgeInsets.all(16),
        child: Text('Frosted glass', style: context.sheen.type.headline),
      ),
      const SizedBox(height: 16),
      SheenPrimaryButton(label: 'Continue', expand: true, onPressed: () {}),
    ],
  );
}
```

`SheenScope` follows the system's light or dark setting and provides the theme, the fallback words widgets use
(Cancel, Done, Search...), Reduce Motion, the shared backdrop and the status bar style.

## Theming

```dart
SheenScope(
  theme: SheenThemeData.light(accent: const Color(0xFF087F5B)),
  darkTheme: SheenThemeData.dark(accent: const Color(0xFF20C997)),
  strings: const SheenStrings(cancel: 'Annuler', done: 'OK', search: 'Rechercher'),
  reduceTransparency: settings.reduceTransparency,
  child: child,
)
```

- Change single colours with `copyWith`: `SheenThemeData.light().copyWith(colors: SheenColors.light().copyWith(background: ...))`.
- Use your font: `theme.copyWith(type: SheenType.material.withFamily('Inter'))`.
- Give part of a screen another look with a nested `SheenTheme`.
- Flutter has no system "Reduce Transparency" flag yet, so pass your app's setting to `reduceTransparency`; high
  contrast mode turns glass opaque by itself.

## Widgets

| Category | Widgets |
| --- | --- |
| Foundation | `SheenScope`, `SheenTheme`, `SheenThemeData`, `SheenColors`, `SheenType`, `SheenStrings`, `SheenTone`, `SheenIcon` + `SheenIcons` (82 glyphs), spacing, radii and layout widths |
| Glass | `SheenGlass` (regular, clear, prominent), `SheenLens` |
| Motion | `SheenPressable`, `SheenEntrance`, `SheenPhotoHero`, `SheenRollingDigits`, `SheenMotion` springs |
| Buttons | `SheenPrimaryButton`, `SheenSecondaryButton`, `SheenFloatingButton`, `SheenTextLink`, `SheenIconButton`, `SheenButtonGroup` |
| Navigation | `SheenTabBar` (with press-and-slide), `SheenTopTabBar`, `SheenToolbar`, `SheenSearchBar`, `SheenActionBar`, `SheenStepsLine` |
| Inputs | `SheenTextField`, `SheenPasswordField`, `SheenSearchField`, `SheenCodeField`, `SheenSwitch`, `SheenSlider`, `SheenStepper` |
| Selection | `SheenChip`, `SheenChipRow`, `SheenSegmentedControl`, `SheenDateRangePicker`, `SheenDateRangeCalendar`, `SheenRangeHistogram`, `SheenChoiceList`, `showSheenChoiceSheet`, `SheenPullDownLink`, `showSheenMenu` |
| Sheets | `showSheenSheet`, `showSheenCustomSheet`, `SheenSheetBody`, `showSheenDateSheet`, `showSheenDocumentSheet`, `SheenFormSheet` |
| Feedback | `showSheenAlert`, `SheenToast`, `SheenActionBanner`, `SheenStatusPill`, `SheenStatusNotice`, `SheenStatusScreen`, `SheenEmptyState`, `SheenSkeleton`, `SheenProgressBar`, `SheenProgressRing`, `SheenSpinner`, `SheenProgressCapsule`, `SheenCountdownPill`, `SheenBadge`, `SheenSuccessCheck` |
| Content | `SheenCard`, `SheenListGroup`, `SheenListRow`, `SheenAccordion`, `SheenKeyValueCard`, `SheenCardSwiper`, `SheenPhotoPager`, `SheenAvatar`, `SheenStarRating`, `SheenScoreBar` |
| Layout | `SheenPage`, `SheenSectionLabel`, `SheenSectionNote`, `SheenScrollEdge`, `SheenEdgeFade` |
| Travel | `SheenHotelCard`, `SheenPremiumCard`, `SheenCityTile`, `SheenPriceBlock`, `SheenCancellationLine`, `SheenScoreBadge`, `SheenPricePin`, `renderSheenPricePin` (map marker bitmaps) |

Every widget has a page in the [gallery](example/); most have a code example in their API docs.

<p align="center">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/03-inputs.webp" width="180" alt="Text fields, search, one-time code">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/04-selection.webp" width="180" alt="Chips, segmented control and a date range">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/07-feedback.webp" width="180" alt="Progress, skeletons, banners and badges">
  <img src="https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/09-travel.webp" width="180" alt="Hotel card, featured stays and map pins">
</p>

## Travel library

Booking widgets live in a second library so apps that do not need them never see them:

```dart
import 'package:sheen/travel.dart';
```

Prices, dates and labels are always yours, formatted and translated; the widgets only lay them out.

## Platforms

Pure Dart and Flutter, with no platform code: iOS, Android, web, macOS, Windows and Linux (checked on the iOS
simulator and in widget tests). The blur is a `BackdropFilter`, so it costs more on the web (the
[live demo](https://marzipane.github.io/sheen/) shows it honestly) and over platform views such as Google Maps on
Android, where a glass bar over the map makes Flutter compose the map view; keep glass over maps to bars and pins.

## FAQ

**Do I need `MaterialApp`?** No. Any app works; with a plain `WidgetsApp`, add `navigatorObservers: [HeroController()]`
if you use `SheenPhotoHero`.

**Can I mix sheen with Material or Cupertino widgets?** Yes. sheen reads only its own theme.

**How do I translate the built-in words?** Pass `SheenStrings` to `SheenScope`. Every widget that shows text also
takes it as a parameter.

**Which Flutter version?** 3.41 or newer.

## Contributing

Issues and pull requests are welcome. Run `flutter analyze`, `flutter test` and, on macOS, the goldens in
`test/goldens/` before sending a change. Icons are SVG files in `tool/icons/`; `dart run tool/gen_icons.dart`
regenerates `SheenIcons`.

## License

MIT. See [LICENSE](LICENSE).
