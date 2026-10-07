import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'variants.dart';

void main() {
  familyGoldens('controls', [
    (
      'Buttons',
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SheenPrimaryButton(label: 'Choose a room', onPressed: () {}),
          SheenPrimaryButton(label: 'Holding…', loading: true, onPressed: () {}),
          const SheenPrimaryButton(label: 'Continue', onPressed: null),
          SheenPrimaryButton(label: 'Pay', subLabel: 'USD 2,770.80', onPressed: () {}),
          SheenSecondaryButton(label: 'Pay with card', icon: 'card', onPressed: () {}),
          SheenFloatingButton(label: 'Map', icon: SheenIcons.mapFill, onPressed: () {}),
          SheenTextLink(label: 'See all 9', onPressed: () {}),
        ],
      ),
    ),
    (
      'SheenChip',
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SheenChip(label: 'Lowest total', selected: true, menu: true, onTap: () {}),
          SheenChip(label: '5 stars', selected: true, onTap: () {}),
          SheenChip(label: 'Free cancellation', selected: false, onTap: () {}),
          SheenChip(label: '3', selected: false, trailingIcon: 'star', onTap: () {}),
        ],
      ),
    ),
    (
      'SheenSegmentedControl',
      () => Column(
        children: [
          SheenSegmentedControl(
            segments: const [SheenSegment('All'), SheenSegment('Room only'), SheenSegment('Breakfast')],
            index: 1,
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          SheenSegmentedControl(
            segments: const [
              SheenSegment('Visa-free', count: '126'),
              SheenSegment('On arrival', count: '41'),
              SheenSegment('eTA', count: '6'),
            ],
            index: 0,
            onChanged: (_) {},
          ),
        ],
      ),
    ),
    (
      'Stepper · Switch · SheenCountdownPill',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SheenStepper(
                value: 2,
                min: 1,
                onChanged: (_) {},
                decreaseLabel: 'Fewer adults',
                increaseLabel: 'More adults',
              ),
              const SizedBox(width: 16),
              SheenSwitch(value: true, onChanged: (_) {}, semanticLabel: 'On'),
              const SizedBox(width: 8),
              SheenSwitch(value: false, onChanged: (_) {}, semanticLabel: 'Off'),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              SheenCountdownPill(remaining: Duration(minutes: 12, seconds: 48), semanticLabel: 'Room held'),
              SheenCountdownPill(remaining: Duration(minutes: 1, seconds: 45), semanticLabel: 'Room held'),
              SheenCountdownPill(remaining: Duration.zero, semanticLabel: 'Room held'),
            ],
          ),
        ],
      ),
    ),
    (
      'SheenTextField',
      () => const Column(
        children: [
          SheenTextField(label: 'First name', placeholder: 'As in the passport'),
          SizedBox(height: 12),
          SheenTextField(label: 'Email', placeholder: 'name@example.com', error: 'Enter a valid email'),
        ],
      ),
    ),
    (
      'SheenDateRangeCalendar',
      () => SheenDateRangeCalendar(
        month: DateTime(2026, 10),
        today: DateTime(2026, 10, 3),
        weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 22),
        onDay: (_) {},
      ),
    ),
  ]);
}
