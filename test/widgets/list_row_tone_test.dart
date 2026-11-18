import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget _group(SheenListRow row) => SizedBox(width: 360, child: SheenListGroup(children: [row]));

void main() {
  testWidgets('a danger row has its title in the danger colour and no chevron', (t) async {
    var taps = 0;
    await t.pumpWidget(host(_group(SheenListRow(title: 'Sign out', tone: SheenTone.danger, onTap: () => taps++))));

    expect(t.widget<Text>(find.text('Sign out')).style!.color, SheenThemeData.of(Brightness.light).colors.danger);
    expect(find.byType(SheenIcon), findsNothing);
    await t.tap(find.text('Sign out'));
    expect(taps, 1);
  });

  testWidgets('a danger row is still one button for a screen reader', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(host(_group(SheenListRow(title: 'Sign out', tone: SheenTone.danger, onTap: () {}))));

    expect(
      t.getSemantics(find.byType(SheenPressable)),
      isSemantics(label: 'Sign out', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('without a tone the title keeps the text colour and the chevron', (t) async {
    await t.pumpWidget(host(_group(SheenListRow(title: 'Language', onTap: () {}))));

    expect(t.widget<Text>(find.text('Language')).style!.color, SheenThemeData.of(Brightness.light).colors.text);
    expect(find.byType(SheenIcon), findsOneWidget);
  });
}
