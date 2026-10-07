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
            OpenButton(
              'A sheet with Done',
              onPressed: () => showSheenSheet<void>(
                context: context,
                title: 'Filters',
                subtitle: '234 stays',
                doneLabel: 'Done',
                builder: (_, scroll) => ListView(
                  controller: scroll,
                  padding: const EdgeInsets.all(16),
                  children: [
                    SheenListGroup(
                      children: [
                        for (final f in ['Free cancellation', 'Breakfast', 'Pool', 'Sea view'])
                          SheenListRow(
                            title: f,
                            trailing: SheenSwitch(value: f == 'Pool', semanticLabel: f, onChanged: (_) {}),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
        child: Gap(
          children: [
            OpenButton(
              'Time is up',
              onPressed: () => showSheenAlert(
                context: context,
                title: 'Time is up',
                message: 'The offer has expired. Start again?',
                primaryLabel: 'Start again',
                secondaryLabel: 'Not now',
              ),
            ),
          ],
        ),
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
