import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

final boxes = find.byWidgetPredicate(
  (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('sheen-code-box'),
);

void main() {
  group('SheenSearchField', () {
    testWidgets('the clear button shows with text, empties the field, reports it and keeps the keyboard', (t) async {
      final c = TextEditingController();
      final seen = <String>[];
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenSearchField(controller: c, onChanged: seen.add),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Clear'), findsNothing);
      expect(find.text('Search'), findsOneWidget, reason: 'the hint defaults to SheenStrings.search');
      await t.tap(find.byType(EditableText));
      await t.enterText(find.byType(EditableText), 'aurora');
      await t.pump();
      expect(find.bySemanticsLabel('Clear'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Clear'));
      await t.pump();
      expect(c.text, '');
      expect(seen.last, '');
      expect(find.bySemanticsLabel('Clear'), findsNothing);
      expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(), isNotNull);
    });

    testWidgets('text set from outside shows the clear button too', (t) async {
      final c = TextEditingController();
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenSearchField(controller: c, hint: 'Find a hotel'),
          ),
        ),
      );
      c.text = 'sol';
      await t.pump();
      expect(find.bySemanticsLabel('Clear'), findsOneWidget);
    });
  });

  group('SheenCodeField', () {
    testWidgets('one box per digit; digits only; completes once at full length', (t) async {
      final c = TextEditingController();
      final done = <String>[];
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenCodeField(controller: c, length: 6, semanticLabel: 'Enter the code', onCompleted: done.add),
          ),
        ),
      );
      expect(boxes, findsNWidgets(6));
      await t.enterText(find.byType(EditableText), '12a34');
      await t.pump();
      expect(c.text, '1234');
      expect(find.text('3'), findsOneWidget);
      expect(done, isEmpty);
      await t.enterText(find.byType(EditableText), '1234567');
      await t.pump();
      expect(c.text, '123456');
      expect(done, ['123456']);
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pump();
      expect(done, ['123456'], reason: 'a focus change is not a new code');
    });

    testWidgets('six boxes fit a narrow phone', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: SheenCodeField(controller: TextEditingController(), semanticLabel: 'Code'),
          ),
        ),
      );
      expect(t.takeException(), isNull);
      expect(t.getRect(boxes.last).right, lessThanOrEqualTo(300));
    });

    testWidgets('offers one-time-code autofill and reads as one field', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(
        host(
          SheenCodeField(
            controller: TextEditingController(text: '12'),
            length: 4,
            semanticLabel: 'Enter the code',
          ),
        ),
      );
      expect(t.widget<EditableText>(find.byType(EditableText)).autofillHints, contains(AutofillHints.oneTimeCode));
      expect(t.widget<EditableText>(find.byType(EditableText)).keyboardType, TextInputType.number);
      expect(find.bySemanticsLabel('Enter the code'), findsOneWidget);
      handle.dispose();
    });
  });
}
