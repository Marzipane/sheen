import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  Future<TextEditingController> field(WidgetTester t) async {
    final c = TextEditingController();
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenCodeField(controller: c, semanticLabel: 'Enter the code'),
        ),
      ),
    );
    return c;
  }

  // the whole code arrives in one edit, as a paste or a one-time-code autofill sends it
  Future<void> paste(WidgetTester t, String code) async {
    await t.showKeyboard(find.byType(EditableText));
    t.testTextInput.updateEditingValue(
      TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      ),
    );
    await t.pump();
  }

  // one digit per edit, as a keyboard sends them
  Future<void> type(WidgetTester t, TextEditingController c, String code) async {
    await t.showKeyboard(find.byType(EditableText));
    for (final digit in code.split('')) {
      final text = c.text + digit;
      t.testTextInput.updateEditingValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
      await t.pump();
    }
  }

  for (final (script, code) in [('Eastern Arabic', '٠١٢٣٤٥'), ('Persian', '۰۱۲۳۴۵')]) {
    testWidgets('a pasted $script code becomes 0-9', (t) async {
      final c = await field(t);
      await paste(t, code);
      expect(c.text, '012345');
    });

    testWidgets('a typed $script code becomes 0-9', (t) async {
      final c = await field(t);
      await type(t, c, code);
      expect(c.text, '012345');
    });
  }

  testWidgets('mixed scripts become 0-9 and other characters still drop', (t) async {
    final c = await field(t);
    await paste(t, '1٢-۳4 ٥۶');
    expect(c.text, '123456');
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('onCompleted gets the 0-9 code', (t) async {
    final c = TextEditingController();
    final done = <String>[];
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenCodeField(controller: c, length: 4, semanticLabel: 'Enter the code', onCompleted: done.add),
        ),
      ),
    );
    await paste(t, '٩٨٧٦');
    expect(done, ['9876']);
  });
}
