import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

final all = [
  for (final (code, name) in [
    ('AFN', 'Afghan Afghani'),
    ('ALL', 'Albanian Lek'),
    ('EUR', 'Euro'),
    ('GBP', 'British Pound'),
    ('INR', 'Indian Rupee'),
    ('JPY', 'Japanese Yen'),
    ('NOK', 'Norwegian Krone'),
    ('SAR', 'Saudi Riyal'),
    ('TRY', 'Turkish Lira'),
    ('USD', 'US Dollar'),
    ('XOF', 'West African CFA Franc'),
    ('ZAR', 'South African Rand'),
    ('ZMW', 'Zambian Kwacha'),
  ])
    SheenChoice(value: code, title: name, tag: code),
];

Widget sheetHost(Widget child) => host(SizedBox(height: 600, child: child));

void main() {
  testWidgets('suggested first, then the whole list under its heading, the current one ticked; the note at the end', (
    t,
  ) async {
    await t.pumpWidget(
      sheetHost(
        SheenChoiceList<String>(
          choices: all,
          current: 'USD',
          suggested: const ['USD', 'EUR'],
          suggestedLabel: 'Suggested',
          allLabel: 'All currencies',
          note: 'Prices are converted at today\'s rate.',
          onPick: (_) {},
        ),
      ),
    );
    expect(find.text('Suggested'), findsOneWidget);
    expect(find.text('All currencies'), findsOneWidget);
    expect(t.getTopLeft(find.text('US Dollar').first).dy, lessThan(t.getTopLeft(find.text('All currencies')).dy));
    expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.check), findsOneWidget);
    await t.scrollUntilVisible(
      find.text('Prices are converted at today\'s rate.'),
      300,
      scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first,
    );
    expect(find.text('Zambian Kwacha'), findsOneWidget);
  });

  testWidgets('typing filters one flat list by title or tag; clear empties it and keeps the keyboard', (t) async {
    String? picked;
    await t.pumpWidget(
      sheetHost(
        SheenChoiceList<String>(
          choices: all,
          current: 'USD',
          suggested: const ['USD'],
          suggestedLabel: 'Suggested',
          allLabel: 'All currencies',
          onPick: (v) => picked = v,
        ),
      ),
    );
    final field = find.byType(EditableText);
    await t.tap(field);
    await t.enterText(field, 'lira');
    await t.pump();
    expect(find.text('Suggested'), findsNothing);
    expect(find.text('Turkish Lira'), findsOneWidget);
    expect(find.text('US Dollar'), findsNothing);
    await t.enterText(field, 'nok');
    await t.pump();
    expect(find.text('Norwegian Krone'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Clear'));
    await t.pump();
    expect(find.text('Suggested'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(), isNotNull);
    await t.tap(find.text('Euro'));
    expect(picked, 'EUR');
  });

  testWidgets('a short list has no filter field', (t) async {
    await t.pumpWidget(
      sheetHost(SheenChoiceList<String>(choices: all.take(3).toList(), current: 'EUR', onPick: (_) {})),
    );
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('the sheet returns the pick, or null when closed', (t) async {
    Future<String?>? result;
    await t.pumpWidget(
      host(
        Builder(
          builder: (c) => GestureDetector(
            onTap: () => result = showSheenChoiceSheet<String>(
              c,
              title: 'Currency',
              choices: all.take(4).toList(),
              current: 'EUR',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('British Pound'));
    await t.pumpAndSettle();
    expect(await result, 'GBP');
  });

  testWidgets('a pull-down link: the label with a chevron, a finger-sized target, a spoken label', (t) async {
    var taps = 0;
    await t.pumpWidget(
      host(SheenPullDownLink(label: 'USD', semanticLabel: 'Prices in USD. Change the currency', onTap: () => taps++)),
    );
    expect(find.text('USD'), findsOneWidget);
    expect(find.bySemanticsLabel('Prices in USD. Change the currency'), findsOneWidget);
    expect(t.getSize(find.byType(SheenPullDownLink)).height, greaterThanOrEqualTo(44));
    await t.tap(find.text('USD'));
    expect(taps, 1);
  });
}
