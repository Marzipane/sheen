import 'package:flutter/material.dart' show TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Finder get _box => find.byWidgetPredicate((w) => w is Container && w.decoration is ShapeDecoration);

Widget _field({String? hint, String? error}) => SizedBox(
  width: 360,
  child: SheenTextField(label: 'Email', hint: hint, error: error),
);

void main() {
  testWidgets('the hint sits inside the box, under the text', (t) async {
    await t.pumpWidget(host(_field(hint: 'For receipts and invoices.')));

    final box = t.getRect(_box);
    final hint = t.getRect(find.text('For receipts and invoices.'));
    final input = t.getRect(find.byType(TextField));
    expect(box.contains(hint.topLeft) && box.contains(hint.bottomRight), isTrue);
    expect(hint.top, greaterThanOrEqualTo(input.bottom));
  });

  testWidgets('the hint is in the secondary text colour at the footnote size', (t) async {
    await t.pumpWidget(host(_field(hint: 'For receipts and invoices.')));

    final style = t.widget<Text>(find.text('For receipts and invoices.')).style!;
    final theme = SheenThemeData.of(Brightness.light);
    expect(style.color, theme.colors.textSecondary);
    expect(style.fontSize, theme.type.footnote.fontSize);
  });

  testWidgets('right to left, the hint starts at the right', (t) async {
    await t.pumpWidget(host(_field(hint: 'For receipts'), direction: TextDirection.rtl));

    final box = t.getRect(_box);
    final hint = t.getRect(find.text('For receipts'));
    expect(box.right - hint.right, lessThan(hint.left - box.left));
  });

  testWidgets('an error still shows under the box with a hint inside it', (t) async {
    await t.pumpWidget(host(_field(hint: 'For receipts', error: 'Enter a valid email')));

    expect(t.getRect(find.text('Enter a valid email')).top, greaterThanOrEqualTo(t.getRect(_box).bottom));
  });

  testWidgets('without a hint the box keeps its height', (t) async {
    await t.pumpWidget(host(_field()));
    expect(t.getSize(_box).height, 50);
  });
}
