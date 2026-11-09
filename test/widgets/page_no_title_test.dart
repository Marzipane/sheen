import 'dart:ui' show SemanticsFlag;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  List<Widget> rows() => [for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('row $i'))];

  Widget endButton() => SheenIconButton(icon: SheenIcons.globe, semanticLabel: 'Language', onTap: () {});

  for (final direction in TextDirection.values) {
    testWidgets('${direction.name}: without a title the content starts at the top and no title fades in', (t) async {
      await t.pumpWidget(
        host(
          SheenPage(trailing: endButton(), children: rows()),
          direction: direction,
        ),
      );
      expect(find.byKey(const ValueKey('sheen-page-title')), findsNothing);
      // no large-title block: the first row sits right under the top bar
      final page = t.getRect(find.byType(SheenPage));
      expect(t.getRect(find.text('row 0')).top - page.top, lessThan(80));
      await t.drag(find.text('row 3'), const Offset(0, -300));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('sheen-page-title')), findsNothing);
      expect(t.takeException(), isNull);
      // the end control stays at the end edge
      final button = t.getRect(find.byType(SheenIconButton));
      final atEnd = direction == TextDirection.ltr
          ? page.right - button.right < button.left - page.left
          : button.left - page.left < page.right - button.right;
      expect(atEnd, isTrue);
    });

    testWidgets('${direction.name}: with a title the large title sits at the start edge above the content', (t) async {
      await t.pumpWidget(
        host(
          SheenPage(title: 'Settings', children: rows()),
          direction: direction,
        ),
      );
      final page = t.getRect(find.byType(SheenPage));
      final title = t.getRect(find.text('Settings').first);
      expect(title.bottom, lessThan(t.getRect(find.text('row 0')).top));
      final atStart = direction == TextDirection.ltr
          ? title.left - page.left < page.right - title.right
          : page.right - title.right < title.left - page.left;
      expect(atStart, isTrue);
      expect(find.byKey(const ValueKey('sheen-page-title')), findsOneWidget);
    });
  }

  testWidgets('screen readers hear no empty header on a page without a title', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(host(const SheenPage(children: [Text('Row')])));
    expect(find.semantics.byFlag(SemanticsFlag.isHeader), findsNothing);
    semantics.dispose();
  });

  testWidgets('a subtitle without a title still shows at the top', (t) async {
    await t.pumpWidget(host(const SheenPage(subtitle: 'Your account', children: [Text('Row')])));
    expect(t.getRect(find.text('Your account')).bottom, lessThan(t.getRect(find.text('Row')).top));
  });

  testWidgets('a barTitle still shows in its capsule on a page without a title', (t) async {
    await t.pumpWidget(host(const SheenPage(barTitle: 'Profile', children: [Text('Row')])));
    expect(find.text('Profile'), findsOneWidget);
  });
}
