import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'variants.dart';

const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

void main() {
  familyGoldens('patterns', [
    (
      'Fields',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheenSearchField(controller: TextEditingController(text: 'Aurora')),
          const SizedBox(height: 12),
          SheenPasswordField(
            label: 'Password',
            controller: TextEditingController(text: 'secret'),
          ),
          const SizedBox(height: 12),
          SheenCodeField(
            controller: TextEditingController(text: '418'),
            semanticLabel: 'Code',
            autofocus: false,
          ),
        ],
      ),
    ),
    (
      'Sections, banner, pills',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheenSectionLabel('Your booking', top: 0),
          SheenActionBanner(
            icon: SheenIcons.refresh,
            tone: SheenTone.warning,
            title: 'Prices changed',
            message: '3 stays are now cheaper.',
            actionLabel: 'Show',
            onAction: () {},
          ),
          const SheenSectionNote('We hold the price for 15 minutes.'),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SheenStatusPill(label: 'Confirmed', tone: SheenTone.success, icon: SheenIcons.check),
              SheenStatusPill(label: 'Pending', tone: SheenTone.warning),
              SheenStatusPill(label: 'Cancelled', tone: SheenTone.danger),
              SheenStatusPill(label: 'Draft'),
            ],
          ),
        ],
      ),
    ),
    (
      'Choice list · pull-down link',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheenPullDownLink(label: 'EUR', onTap: () {}),
          SizedBox(
            height: 220,
            child: SheenChoiceList<String>(
              choices: const [
                SheenChoice(value: 'EUR', title: 'Euro', tag: 'EUR'),
                SheenChoice(value: 'GBP', title: 'British Pound', tag: 'GBP'),
                SheenChoice(value: 'USD', title: 'US Dollar', tag: 'USD'),
              ],
              current: 'EUR',
              note: 'Prices are converted at today\'s rate.',
              onPick: (_) {},
            ),
          ),
        ],
      ),
    ),
    (
      'Accordion · key-value card',
      () => Column(
        children: [
          const SheenAccordion(title: 'Can I cancel?', initiallyOpen: true, child: Text('Yes, until the day before.')),
          const SheenAccordion(title: 'Is breakfast included?', child: Text('Only where it says so.')),
          SheenKeyValueCard(
            rows: [
              const SheenKeyValue('Reference', 'RT-20418'),
              const SheenKeyValue('Check-in', 'Mon 20 Oct, from 15:00'),
              SheenKeyValue('At the hotel', 'See charges', onTap: () {}),
            ],
          ),
        ],
      ),
    ),
    (
      'Chip row · date wheels',
      () => Column(
        children: [
          SheenChipRow(
            padding: EdgeInsets.zero,
            children: [
              SheenChip(label: 'Price', menu: true, selected: false, onTap: () {}),
              SheenChip(label: 'Free cancellation', selected: true, onTap: () {}),
              SheenChip(label: 'Breakfast', selected: false, onTap: () {}),
              SheenChip(label: 'Pool', selected: false, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          SheenDateWheels(
            first: DateTime(1920),
            last: DateTime(2026, 10, 7),
            initial: DateTime(1990, 5, 17),
            onChanged: (_) {},
          ),
        ],
      ),
    ),
    (
      'Date-range picker',
      () => SheenDateRangePicker(
        today: DateTime(2026, 10, 7),
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 23),
        weekdayLabels: _weekdays,
        monthLabel: (m) => '${_months[m.month - 1]} ${m.year}',
        onChanged: (_, _) {},
      ),
    ),
    (
      'Status screen',
      () => const SizedBox(
        height: 420,
        child: SheenStatusScreen(
          icon: SheenIcons.wrench,
          tone: SheenTone.warning,
          title: 'We are updating',
          message: 'Back in a few minutes. Your bookings are safe.',
          details: [Text('Back around 14:30')],
          primaryLabel: 'Try again',
          secondaryLabel: 'Contact us',
          secondaryIcon: SheenIcons.chat,
        ),
      ),
    ),
  ]);
}
