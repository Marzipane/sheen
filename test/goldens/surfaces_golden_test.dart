import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'variants.dart';

const _tabs = [
  SheenTabItem(icon: 'home', label: 'Home'),
  SheenTabItem(icon: 'map', label: 'Map'),
  SheenTabItem(icon: 'compass', label: 'Explore', badge: '2'),
  SheenTabItem(icon: 'user', label: 'Profile'),
];

void main() {
  familyGoldens('surfaces', [
    (
      'SheenTabBar',
      () => overPhoto(SheenTabBar(items: _tabs, index: 0, onSelect: (_) {}, onSearch: () {}, searchLabel: 'Search')),
    ),
    (
      'SheenTabBar · minimized + accessory',
      () => overPhoto(
        SheenTabBar(
          items: _tabs,
          index: 0,
          onSelect: (_) {},
          onSearch: () {},
          searchLabel: 'Search',
          minimized: true,
          accessory: const SheenTabAccessory(
            title: 'Room held',
            subtitle: 'Hotel Aurora',
            trailing: SheenCountdownPill(remaining: Duration(minutes: 12, seconds: 48), semanticLabel: 'Room held'),
          ),
        ),
      ),
    ),
    (
      'SheenIconButton · group',
      () => overPhoto(
        Row(
          children: [
            SheenIconButton(icon: 'back', semanticLabel: 'Back', onTap: () {}),
            const SizedBox(width: 8),
            SheenIconButton(icon: 'heart', semanticLabel: 'Save', variant: SheenGlassVariant.clear, onTap: () {}),
            const SizedBox(width: 8),
            SheenIconButton(icon: 'check', semanticLabel: 'Done', variant: SheenGlassVariant.prominent, onTap: () {}),
            const SizedBox(width: 8),
            SheenButtonGroup(
              items: [
                SheenButtonGroupItem(icon: 'share', semanticLabel: 'Share', onTap: () {}),
                SheenButtonGroupItem(icon: 'heart', semanticLabel: 'Save', filled: true, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    ),
    (
      'SheenToolbar · summary',
      () => overPhoto(
        SheenToolbar(
          leading: SheenIconButton(icon: 'back', semanticLabel: 'Back', onTap: () {}),
          center: SheenToolbarSummary(title: 'Lisbon', subtitle: '20–22 Oct · 2 adults · 1 room', onTap: () {}),
          trailing: SheenIconButton(icon: 'sliders', semanticLabel: 'Filters', onTap: () {}),
        ),
      ),
    ),
    (
      'SheenActionBar',
      () => overPhoto(
        SheenActionBar(
          value: 'USD 2,770.80',
          caption: 'Total for 2 nights',
          actionLabel: 'Choose a room',
          onAction: () {},
        ),
      ),
    ),
    (
      'SheenSheetBody',
      () => SizedBox(
        height: 160,
        child: SheenSheetBody(
          title: 'Dates & guests',
          cancelLabel: 'Cancel',
          onCancel: () {},
          doneLabel: 'Done',
          onDone: () {},
          child: const SizedBox(height: 40),
        ),
      ),
    ),
    (
      'SheenAlert',
      () => overPhoto(
        SheenAlert(
          title: 'Booking Time Over',
          message: 'The time for booking has expired. Please choose an option to proceed.',
          primaryLabel: 'Book Again',
          onPrimary: () {},
          secondaryLabel: 'Go Back',
          onSecondary: () {},
        ),
      ),
    ),
    ('SheenStatusNotice', () => const SheenStatusNotice(message: 'Payments are temporarily unavailable.')),
  ]);
}
