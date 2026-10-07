import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

class SheetsPage extends StatefulWidget {
  const SheetsPage({super.key});

  @override
  State<SheetsPage> createState() => _SheetsPageState();
}

class _SheetsPageState extends State<SheetsPage> {
  String _sort = 'price';
  DateTime? _birthday;

  /// `--dart-define=OPEN=filters` (or alert, date, toast) opens that demo at launch, for screenshots.
  static const String _open = String.fromEnvironment('OPEN');

  @override
  void initState() {
    super.initState();
    if (_open.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (_open) {
        case 'filters':
          _filters();
        case 'alert':
          _alert();
        case 'date':
          showSheenDateSheet(
            context: context,
            title: 'Date of birth',
            first: DateTime(1920),
            last: DateTime.now(),
            initial: DateTime(1990, 5, 17),
          );
        case 'toast':
          SheenToast.show(context, 'Saved to your list', tone: SheenTone.success, duration: const Duration(minutes: 1));
      }
    });
  }

  static const _bins = [2, 5, 9, 14, 22, 30, 26, 21, 17, 12, 9, 7, 5, 4, 3, 2, 2, 1];

  Future<void> _filters() {
    var sort = 0;
    var price = const SheenRange(120, 640);
    final on = {'Pool'};
    return showSheenSheet<void>(
      context: context,
      title: 'Filters',
      subtitle: '234 stays',
      doneLabel: 'Done',
      startLarge: false,
      builder: (_, scroll) => StatefulBuilder(
        builder: (context, setSheet) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            SheenSegmentedControl(
              segments: const [SheenSegment('Price'), SheenSegment('Rating'), SheenSegment('Distance')],
              index: sort,
              onChanged: (i) => setSheet(() => sort = i),
            ),
            SheenSectionLabel('Price per night, € ${price.start.round()} to € ${price.end.round()}'),
            SheenRangeHistogram(
              bins: _bins,
              min: 0,
              max: 900,
              values: price,
              onChanged: (r) => setSheet(() => price = r),
              lowLabel: 'Minimum price',
              highLabel: 'Maximum price',
              format: (v) => '€ ${v.round()}',
            ),
            const SheenSectionLabel('Stay'),
            SheenListGroup(
              children: [
                for (final f in ['Free cancellation', 'Breakfast', 'Pool', 'Sea view'])
                  SheenListRow(
                    title: f,
                    trailing: SheenSwitch(
                      value: on.contains(f),
                      semanticLabel: f,
                      onChanged: (v) => setSheet(() => v ? on.add(f) : on.remove(f)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _alert() => showSheenAlert(
    context: context,
    title: 'Time is up',
    message: 'The offer has expired. Start again?',
    primaryLabel: 'Start again',
    secondaryLabel: 'Not now',
  );

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Sheets and dialogs',
    children: [
      Demo(
        title: 'Sheets',
        note: 'Two heights; drag between them, drag down or tap outside to close.',
        child: Gap(
          children: [
            OpenButton(
              'Sort by',
              icon: SheenIcons.sliders,
              onPressed: () async {
                final v = await showSheenChoiceSheet<String>(
                  context,
                  title: 'Sort by',
                  current: _sort,
                  choices: const [
                    SheenChoice(value: 'price', title: 'Lowest price'),
                    SheenChoice(value: 'score', title: 'Best rated'),
                    SheenChoice(value: 'distance', title: 'Closest to the centre'),
                  ],
                );
                if (v != null) setState(() => _sort = v);
              },
            ),
            OpenButton('A sheet with Done', onPressed: _filters),
            OpenButton(
              _birthday == null ? 'Date of birth' : '${_birthday!.day}.${_birthday!.month}.${_birthday!.year}',
              icon: SheenIcons.calendar,
              onPressed: () async {
                final d = await showSheenDateSheet(
                  context: context,
                  title: 'Date of birth',
                  first: DateTime(1920),
                  last: DateTime.now(),
                  initial: _birthday ?? DateTime(1990, 5, 17),
                );
                if (d != null) setState(() => _birthday = d);
              },
            ),
            OpenButton(
              'Terms',
              icon: SheenIcons.document,
              onPressed: () => showSheenDocumentSheet(
                context,
                title: 'Terms of use',
                text:
                    'These terms are an example. A long text scrolls in a large sheet, and the sheet closes with its '
                        'close button, a tap outside or a drag down.\n\n' *
                    6,
              ),
            ),
          ],
        ),
      ),
      Demo(
        title: 'Alert',
        child: Gap(children: [OpenButton('Time is up', onPressed: _alert)]),
      ),
      Demo(
        title: 'Toasts',
        note: 'Above every page and sheet; screen readers hear them.',
        child: Gap(
          children: [
            OpenButton(
              'Saved',
              onPressed: () => SheenToast.show(context, 'Saved to your list', tone: SheenTone.success),
            ),
            OpenButton(
              'Error',
              onPressed: () => SheenToast.show(context, 'Could not save. Try again.', tone: SheenTone.danger),
            ),
            OpenButton('Info', onPressed: () => SheenToast.show(context, 'Prices are in euros')),
          ],
        ),
      ),
    ],
  );
}
