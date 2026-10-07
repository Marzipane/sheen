import 'package:flutter/material.dart';
import 'package:sheen/sheen.dart';

void main() => runApp(
  MaterialApp(
    builder: (context, child) => SheenScope(
      theme: SheenThemeData.light(accent: const Color(0xFF087F5B)),
      darkTheme: SheenThemeData.dark(accent: const Color(0xFF20C997)),
      child: child!,
    ),
    home: const TripPage(),
  ),
);

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  static const _sorts = {'price': 'Lowest price', 'score': 'Best rated'};
  String _sort = 'price';
  int _guests = 2;
  bool _alerts = true;

  Future<void> _pickSort() async {
    final sort = await showSheenChoiceSheet<String>(
      context,
      title: 'Sort by',
      current: _sort,
      choices: [for (final e in _sorts.entries) SheenChoice(value: e.key, title: e.value)],
    );
    if (sort != null) setState(() => _sort = sort);
  }

  Future<void> _book() async {
    final ok = await showSheenAlert(
      context: context,
      title: 'Book Casa do Rio?',
      message: '2 nights for $_guests guests.',
      primaryLabel: 'Book',
      secondaryLabel: 'Not now',
    );
    if (ok == true && mounted) SheenToast.show(context, 'Booked', tone: SheenTone.success);
  }

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Lisbon',
    subtitle: '20–22 Oct',
    bottom: SheenPrimaryButton(label: 'Book', expand: true, onPressed: _book),
    children: [
      SheenListGroup(
        children: [
          SheenListRow(title: 'Sort by', value: _sorts[_sort], onTap: _pickSort),
          SheenListRow(
            title: 'Guests',
            trailing: SheenStepper(
              value: _guests,
              min: 1,
              max: 8,
              decreaseLabel: 'Fewer guests',
              increaseLabel: 'More guests',
              onChanged: (v) => setState(() => _guests = v),
            ),
          ),
          SheenListRow(
            title: 'Price alerts',
            trailing: SheenSwitch(
              value: _alerts,
              semanticLabel: 'Price alerts',
              onChanged: (v) => setState(() => _alerts = v),
            ),
          ),
        ],
      ),
    ],
  );
}
