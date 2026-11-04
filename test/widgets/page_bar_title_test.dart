import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  testWidgets('barTitle shows in a capsule beside the large title, before any scroll', (t) async {
    await t.pumpWidget(
      host(const SheenPage(title: 'Choose your language', barTitle: 'Language', children: [SizedBox(height: 20)])),
    );
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.ancestor(of: find.text('Language'), matching: find.byType(SheenGlass)), findsOneWidget);
    expect(t.getTopLeft(find.text('Language')).dy, lessThan(t.getTopLeft(find.text('Choose your language')).dy));
  });

  testWidgets('barTitle stays after the page scrolls', (t) async {
    await t.pumpWidget(
      host(const SheenPage(title: 'Choose your language', barTitle: 'Language', children: [SizedBox(height: 3000)])),
    );
    await t.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await t.pumpAndSettle();
    expect(find.ancestor(of: find.text('Language'), matching: find.byType(SheenGlass)), findsOneWidget);
    expect(find.byKey(const ValueKey('sheen-page-title')), findsNothing);
  });

  testWidgets('barTitle sits clear of the back button', (t) async {
    await t.pumpWidget(
      host(SheenPage(title: 'Choose your language', barTitle: 'Language', onBack: () {}, children: const [])),
    );
    final back = t.getRect(find.byType(SheenIconButton));
    expect(t.getRect(find.text('Language')).overlaps(back), isFalse);
  });

  testWidgets('screen readers hear barTitle as a header, and not the faded title', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      host(const SheenPage(title: 'Choose your language', barTitle: 'Language', children: [SizedBox(height: 20)])),
    );
    expect(find.bySemanticsLabel('Language'), findsOneWidget);
    expect(t.getSemantics(find.bySemanticsLabel('Language')).flagsCollection.isHeader, isTrue);
    await t.pumpWidget(host(const SheenPage(title: 'Trips', children: [SizedBox(height: 20)])));
    expect(find.bySemanticsLabel('Trips'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('without barTitle the large title fades into the bar as before', (t) async {
    await t.pumpWidget(host(const SheenPage(title: 'Trips', children: [SizedBox(height: 20)])));
    expect(find.byKey(const ValueKey('sheen-page-title')), findsOneWidget);
  });
}
