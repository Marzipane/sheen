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

  testWidgets('without barTitle the large title fades into the bar as before', (t) async {
    await t.pumpWidget(host(const SheenPage(title: 'Trips', children: [SizedBox(height: 20)])));
    expect(find.byKey(const ValueKey('sheen-page-title')), findsOneWidget);
  });
}
