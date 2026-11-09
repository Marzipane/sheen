import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget _field({TextDirection? textDirection}) => SizedBox(
  width: 340,
  child: SheenTextField(
    label: 'رقم الجوال',
    controller: TextEditingController(text: '50 000 0100'),
    leading: const Text('+971'),
    textDirection: textDirection,
  ),
);

void main() {
  testWidgets('textDirection keeps a number left to right in a right-to-left page, prefix first', (t) async {
    await t.pumpWidget(host(_field(textDirection: TextDirection.ltr), direction: TextDirection.rtl));

    expect(t.getRect(find.text('+971')).right, lessThan(t.getRect(find.byType(EditableText)).left));
    expect(t.widget<EditableText>(find.byType(EditableText)).textDirection, TextDirection.ltr);
    // the prefix itself reads left to right too: "+971", not "971+"
    final prefix = t.renderObject<RenderParagraph>(
      find.descendant(of: find.text('+971'), matching: find.byType(RichText)),
    );
    expect(prefix.textDirection, TextDirection.ltr);
    // the label keeps the page's direction, at the right
    final label = t.getRect(find.text('رقم الجوال'));
    final field = t.getRect(find.byType(SheenTextField));
    expect(label.right, closeTo(field.right, 1));
  });

  testWidgets('without textDirection the field follows the page, prefix at the right in right to left', (t) async {
    await t.pumpWidget(host(_field(), direction: TextDirection.rtl));

    expect(t.getRect(find.text('+971')).left, greaterThan(t.getRect(find.byType(EditableText)).right));
  });
}
