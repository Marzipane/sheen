import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'pages/buttons.dart';
import 'pages/content.dart';
import 'pages/feedback.dart';
import 'pages/foundation.dart';
import 'pages/glass.dart';
import 'pages/inputs.dart';
import 'pages/selection.dart';
import 'pages/sheets.dart';
import 'pages/travel.dart';

/// One page of the gallery.
class PageSpec {
  const PageSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.page,
  });

  /// The page's address: `/inputs`, `--dart-define=PAGE=inputs`, `?page=inputs`.
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color tint;
  final Widget Function() page;
}

final List<PageSpec> catalog = [
  PageSpec(
    id: 'glass',
    title: 'Glass',
    subtitle: 'Surfaces, tab bar, toolbar',
    icon: SheenIcons.layers,
    tint: SheenTint.blue,
    page: () => const GlassShowcase(),
  ),
  PageSpec(
    id: 'buttons',
    title: 'Buttons',
    subtitle: 'Primary, secondary, glass, links',
    icon: SheenIcons.sparkle,
    tint: SheenTint.violet,
    page: () => const ButtonsPage(),
  ),
  PageSpec(
    id: 'inputs',
    title: 'Inputs',
    subtitle: 'Fields, code, switch, slider, stepper',
    icon: SheenIcons.compose,
    tint: SheenTint.teal,
    page: () => const InputsPage(),
  ),
  PageSpec(
    id: 'selection',
    title: 'Selection',
    subtitle: 'Chips, segments, dates, ranges, menus',
    icon: SheenIcons.sliders,
    tint: SheenTint.orange,
    page: () => const SelectionPage(),
  ),
  PageSpec(
    id: 'sheets',
    title: 'Sheets and dialogs',
    subtitle: 'Sheets, choices, dates, alerts, toasts',
    icon: SheenIcons.layers,
    tint: SheenTint.purple,
    page: () => const SheetsPage(),
  ),
  PageSpec(
    id: 'feedback',
    title: 'Feedback',
    subtitle: 'Progress, states, banners, badges',
    icon: SheenIcons.bell,
    tint: SheenTint.red,
    page: () => const FeedbackPage(),
  ),
  PageSpec(
    id: 'content',
    title: 'Content',
    subtitle: 'Cards, lists, accordions, avatars',
    icon: SheenIcons.grid,
    tint: SheenTint.green,
    page: () => const ContentPage(),
  ),
  PageSpec(
    id: 'travel',
    title: 'Travel',
    subtitle: 'Hotel cards, prices, map pins',
    icon: SheenIcons.plane,
    tint: SheenTint.blue,
    page: () => const TravelPage(),
  ),
  PageSpec(
    id: 'foundation',
    title: 'Foundation',
    subtitle: 'Colours, type, icons, motion',
    icon: SheenIcons.globe,
    tint: SheenTint.gray,
    page: () => const FoundationPage(),
  ),
];
