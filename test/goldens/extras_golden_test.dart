import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'variants.dart';

void main() {
  familyGoldens('extras', [
    (
      'Sliders',
      () => Column(
        children: [
          SheenSlider(value: .3, onChanged: (_) {}, semanticLabel: 'Volume'),
          SheenSlider(value: .75, divisions: 4, onChanged: (_) {}, semanticLabel: 'Steps'),
          const SheenSlider(value: .5, onChanged: null, semanticLabel: 'Off'),
        ],
      ),
    ),
    (
      'Progress',
      () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheenProgressBar(value: .62),
          SizedBox(height: 16),
          Row(
            children: [
              SheenProgressRing(value: .25),
              SizedBox(width: 16),
              SheenProgressRing(value: .7, size: 40, stroke: 4),
              SizedBox(width: 16),
              SheenSpinner(color: Color(0xFF1F6FEB)),
            ],
          ),
        ],
      ),
    ),
    (
      'Badges · avatars',
      () => Row(
        children: [
          SheenBadge(
            count: 3,
            child: SheenIconButton(icon: SheenIcons.bell, semanticLabel: 'Notifications', onTap: () {}),
          ),
          const SizedBox(width: 20),
          SheenBadge(
            count: 120,
            child: SheenIconButton(icon: SheenIcons.chat, semanticLabel: 'Messages', onTap: () {}),
          ),
          const SizedBox(width: 20),
          SheenBadge.dot(
            child: SheenIconButton(icon: SheenIcons.mail, semanticLabel: 'Mail', onTap: () {}),
          ),
          const SizedBox(width: 20),
          const SheenAvatar(name: 'Ada Lovelace'),
          const SizedBox(width: 8),
          const SheenAvatar(name: 'Grace Hopper', size: 32),
          const SizedBox(width: 8),
          const SheenAvatar(),
        ],
      ),
    ),
  ]);
}
