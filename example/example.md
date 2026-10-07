# sheen example

A small trip page: a large-title page with a grouped list, a choice sheet, a stepper, a switch, an alert and a toast.
This is [`example/lib/minimal.dart`](lib/minimal.dart); run it with `flutter run -t lib/minimal.dart` from `example/`.

```dart
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
```

## The gallery

`example/lib/main.dart` is a gallery of every widget, in light and dark, left-to-right and right-to-left, at any text
size and with any accent (the settings button on its home page). Run it with `flutter run` from `example/`, or open the
[live demo](https://marzipane.github.io/sheen/).

## Booking widgets

```dart
import 'package:sheen/travel.dart';

SheenHotelCard(
  name: 'Hotel Aurora',
  total: '€ 1,448',
  perNight: '€ 724 a night',
  headline: 'Old Town · 0.4 km to the centre',
  score: '9.1',
  cancellation: 'Free cancellation until 12 Oct',
  refundable: true,
  photoCount: photos.length,
  photoBuilder: (context, i) => Image.network(photos[i], fit: BoxFit.cover),
  noPhotoLabel: 'No photo',
  saveLabel: 'Save',
  onTap: open,
)
```

Prices and words are always yours: format them with `intl` in the reader's language and currency.
