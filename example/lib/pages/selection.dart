import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

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

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final _moreKey = GlobalKey();
  final Set<String> _chips = {'Free cancellation'};
  int _segment = 0;
  DateTime? _start = DateTime.now().add(const Duration(days: 12)), _end = DateTime.now().add(const Duration(days: 15));
  SheenRange _price = const SheenRange(120, 640);
  String _currency = 'EUR';
  String? _menu;

  /// `--dart-define=OPEN=menu` opens the menu at launch, for screenshots.
  static const String _open = String.fromEnvironment('OPEN');

  @override
  void initState() {
    super.initState();
    if (_open == 'menu') WidgetsBinding.instance.addPostFrameCallback((_) => _showMenu());
  }

  Future<void> _showMenu() async {
    final v = await showSheenMenu<String>(
      context,
      anchorKey: _moreKey,
      items: const [
        SheenMenuItem(value: 'Shared', label: 'Share', icon: SheenIcons.share),
        SheenMenuItem(value: 'Copied', label: 'Copy link', icon: SheenIcons.link),
        SheenMenuItem(value: 'Deleted', label: 'Delete', icon: SheenIcons.trash, destructive: true),
      ],
    );
    if (v != null) setState(() => _menu = v);
  }

  static const _bins = [2, 5, 9, 14, 22, 30, 26, 21, 17, 12, 9, 7, 5, 4, 3, 2, 2, 1];

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final today = DateTime.now();
    return SheenPage(
      title: 'Selection',
      trailing: SheenIconButton(key: _moreKey, icon: SheenIcons.more, semanticLabel: 'More', onTap: _showMenu),
      children: [
        Demo(
          title: 'Chips',
          child: SheenChipRow(
            padding: EdgeInsets.zero,
            children: [
              SheenChip(label: 'Lowest price', menu: true, selected: false, onTap: () {}),
              for (final c in ['Free cancellation', 'Breakfast', 'Pool', 'Sea view', 'Parking'])
                SheenChip(
                  label: c,
                  selected: _chips.contains(c),
                  onTap: () => setState(() => _chips.contains(c) ? _chips.remove(c) : _chips.add(c)),
                ),
            ],
          ),
        ),
        Demo(
          title: 'Segmented control',
          child: SheenSegmentedControl(
            segments: const [
              SheenSegment('Visa-free', count: '126'),
              SheenSegment('On arrival', count: '41'),
              SheenSegment('eTA', count: '6'),
            ],
            index: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),
        Demo(
          title: 'Date range',
          note: 'Swipe for another month. The week can start on any day.',
          child: SheenDateRangePicker(
            today: today,
            lastDay: today.add(const Duration(days: 330)),
            start: _start,
            end: _end,
            weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            monthLabel: (m) => '${_months[m.month - 1]} ${m.year}',
            onChanged: (s, e) => setState(() {
              _start = s;
              _end = e;
            }),
          ),
        ),
        Demo(
          title: 'Range over a histogram',
          note: '€ ${_price.start.round()} to € ${_price.end.round()} a night',
          child: SheenRangeHistogram(
            bins: _bins,
            min: 0,
            max: 900,
            values: _price,
            onChanged: (r) => setState(() => _price = r),
            lowLabel: 'Minimum price',
            highLabel: 'Maximum price',
            format: (v) => '€ ${v.round()}',
          ),
        ),
        Demo(
          title: 'Pull-down link',
          child: Row(
            children: [
              Text('Prices in', style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
              SheenPullDownLink(
                label: _currency,
                semanticLabel: 'Prices in $_currency. Change the currency',
                onTap: () async {
                  final c = await showSheenChoiceSheet<String>(
                    context,
                    title: 'Currency',
                    current: _currency,
                    choices: const [
                      SheenChoice(value: 'EUR', title: 'Euro', tag: 'EUR'),
                      SheenChoice(value: 'GBP', title: 'British Pound', tag: 'GBP'),
                      SheenChoice(value: 'USD', title: 'US Dollar', tag: 'USD'),
                    ],
                  );
                  if (c != null) setState(() => _currency = c);
                },
              ),
              const Spacer(),
              if (_menu != null) Text(_menu!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
