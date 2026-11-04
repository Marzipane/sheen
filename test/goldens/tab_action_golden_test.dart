import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'variants.dart';

const _tabs = [
  SheenTabItem(icon: SheenIcons.homeFill, label: 'Home'),
  SheenTabItem(icon: SheenIcons.calendar, label: 'Trips'),
  SheenTabItem(icon: SheenIcons.userFill, label: 'Profile'),
];

Widget _bar({int index = 0, bool active = false, bool minimized = false}) => overPhoto(
  SheenTabBar(
    items: _tabs,
    index: index,
    onSelect: (_) {},
    onSearch: () {},
    searchLabel: 'Add',
    searchIcon: SheenIcons.plus,
    searchVariant: SheenGlassVariant.prominent,
    searchActive: active,
    minimized: minimized,
  ),
);

Widget _topBar({bool active = false}) => overPhoto(
  SheenTopTabBar(
    items: _tabs,
    index: 1,
    onSelect: (_) {},
    onSearch: () {},
    searchLabel: 'Add',
    searchIcon: SheenIcons.plus,
    searchVariant: SheenGlassVariant.prominent,
    searchActive: active,
  ),
);

void main() {
  familyGoldens('tab_action', [
    ('prominent plus, outline tab selected', () => _bar(index: 1)),
    ('prominent plus, active', () => _bar(active: true)),
    ('prominent plus, minimized', () => _bar(minimized: true)),
    ('prominent plus, minimized and active', () => _bar(minimized: true, active: true)),
    (
      'selectedIcon: only the selected tab is filled',
      () => overPhoto(
        SheenTabBar(
          items: const [
            SheenTabItem(icon: SheenIcons.heart, selectedIcon: SheenIcons.heartFill, label: 'Saved'),
            SheenTabItem(icon: SheenIcons.map, selectedIcon: SheenIcons.mapFill, label: 'Map'),
            SheenTabItem(icon: SheenIcons.user, selectedIcon: SheenIcons.userFill, label: 'Profile'),
          ],
          index: 1,
          onSelect: (_) {},
          onSearch: () {},
        ),
      ),
    ),
    (
      'SheenPage with barTitle',
      () => const SizedBox(
        height: 220,
        child: SheenPage(title: 'Choose your language', barTitle: 'Language', children: [SizedBox(height: 20)]),
      ),
    ),
    ('top tab bar, prominent plus', _topBar),
    ('top tab bar, prominent plus, active', () => _topBar(active: true)),
  ]);
}
