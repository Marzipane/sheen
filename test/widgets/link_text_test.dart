import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

const _note = 'To keep your account safe we record sign-ins. Details are in the {privacy}.';

Widget _text({required VoidCallback onPrivacy, String? semanticLabel}) => SizedBox(
  width: 340,
  child: SheenLinkText(
    _note,
    links: {'privacy': SheenLink('Privacy policy', onTap: onPrivacy, semanticLabel: semanticLabel)},
  ),
);

/// The centre of the link's last line box, in global coordinates.
Offset _linkCentre(WidgetTester t, String link) {
  final paragraph = t.renderObject<RenderParagraph>(find.byType(RichText));
  final text = paragraph.text.toPlainText();
  final start = text.indexOf(link);
  final boxes = paragraph.getBoxesForSelection(TextSelection(baseOffset: start, extentOffset: start + link.length));
  return paragraph.localToGlobal(boxes.last.toRect().center);
}

void main() {
  testWidgets('the text reads with the link in its place', (t) async {
    await t.pumpWidget(host(_text(onPrivacy: () {})));
    expect(
      find.text('To keep your account safe we record sign-ins. Details are in the Privacy policy.', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a tap on the link opens it; a tap on the plain text does nothing', (t) async {
    var opened = 0;
    await t.pumpWidget(host(_text(onPrivacy: () => opened++)));

    await t.tapAt(_linkCentre(t, 'Privacy policy'));
    expect(opened, 1);
    await t.tapAt(t.getTopLeft(find.byType(RichText)) + const Offset(4, 4));
    expect(opened, 1);
  });

  testWidgets('the link takes taps at least 44 points tall around it, also on the last line', (t) async {
    var opened = 0;
    await t.pumpWidget(
      host(
        Padding(
          padding: const EdgeInsets.all(40),
          child: _text(onPrivacy: () => opened++),
        ),
      ),
    );

    final centre = _linkCentre(t, 'Privacy policy');
    await t.tapAt(centre + const Offset(0, SheenSpace.hit / 2 - 1));
    await t.tapAt(centre - const Offset(0, SheenSpace.hit / 2 - 1));
    expect(opened, 2);
    await t.tapAt(centre + const Offset(0, SheenSpace.hit / 2 + 4));
    expect(opened, 2);
  });

  testWidgets('right to left, the link opens where it is drawn', (t) async {
    var opened = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 340,
          child: SheenLinkText(
            'التفاصيل في {privacy}.',
            links: {'privacy': SheenLink('سياسة الخصوصية', onTap: () => opened++)},
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );

    final centre = _linkCentre(t, 'سياسة الخصوصية');
    expect(centre.dx, greaterThan(t.getCenter(find.byType(RichText)).dx));
    await t.tapAt(centre);
    expect(opened, 1);
  });

  testWidgets('the link is in the accent text colour', (t) async {
    await t.pumpWidget(host(_text(onPrivacy: () {})));

    final paragraph = t.renderObject<RenderParagraph>(find.byType(RichText));
    TextStyle? linkStyle;
    paragraph.text.visitChildren((span) {
      if (span is TextSpan && span.text == 'Privacy policy') linkStyle = span.style;
      return true;
    });
    expect(linkStyle!.color, SheenThemeData.of(Brightness.light).colors.accentText);
  });

  testWidgets('a screen reader hears the link as a link with its label and can open it', (t) async {
    final semantics = t.ensureSemantics();
    var opened = 0;
    await t.pumpWidget(host(_text(onPrivacy: () => opened++, semanticLabel: 'Privacy policy, opens in the browser')));

    final link = find.semantics.byLabel('Privacy policy, opens in the browser');
    expect(link, findsOneWidget);
    expect(link.evaluate().single, isSemantics(isLink: true, hasTapAction: true));
    t.semantics.tap(link);
    expect(opened, 1);
    semantics.dispose();
  });
}
