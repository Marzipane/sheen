import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

/// A screen reader says a button's label once: the visible text under it is not read a second time.
void main() {
  Future<String> spoken(WidgetTester t, Widget button, Type type) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(host(Center(child: button)));
    // the node the button's own Semantics makes, around its tap target
    final label = t
        .getSemantics(find.descendant(of: find.byType(type), matching: find.byType(GestureDetector)).first)
        .label;
    handle.dispose();
    return label;
  }

  testWidgets('a primary button is read once', (t) async {
    expect(await spoken(t, SheenPrimaryButton(label: 'Send code', onPressed: () {}), SheenPrimaryButton), 'Send code');
  });

  testWidgets('a primary button with a second line reads both, once each', (t) async {
    expect(
      await spoken(t, SheenPrimaryButton(label: 'Pay', subLabel: 'AED 120', onPressed: () {}), SheenPrimaryButton),
      'Pay, AED 120',
    );
  });

  testWidgets('a secondary button is read once', (t) async {
    expect(await spoken(t, SheenSecondaryButton(label: 'Later', onPressed: () {}), SheenSecondaryButton), 'Later');
  });

  testWidgets('a floating button is read once', (t) async {
    expect(await spoken(t, SheenFloatingButton(label: 'Map', onPressed: () {}), SheenFloatingButton), 'Map');
  });

  testWidgets('a text link is read once', (t) async {
    expect(await spoken(t, SheenTextLink(label: 'Terms', onPressed: () {}), SheenTextLink), 'Terms');
  });

  testWidgets('an alert action is read once', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(
      host(SheenAlert(title: 'Time over', message: 'Choose again.', primaryLabel: 'Book again', onPrimary: () {})),
    );
    expect(find.bySemanticsLabel('Book again'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Book again.*Book again', dotAll: true)), findsNothing);
    handle.dispose();
  });
}
