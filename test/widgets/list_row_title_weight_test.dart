import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  testWidgets('titleWeight sets the weight of the title, with or without a subtitle', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 360,
          child: SheenListGroup(
            children: [
              SheenListRow(title: 'Alone', titleWeight: FontWeight.w600),
              SheenListRow(title: 'With a line', subtitle: 'Under it', titleWeight: FontWeight.w600),
            ],
          ),
        ),
      ),
    );
    expect(t.widget<Text>(find.text('Alone')).style!.fontWeight, FontWeight.w600);
    expect(t.widget<Text>(find.text('With a line')).style!.fontWeight, FontWeight.w600);
  });

  testWidgets('without titleWeight the title keeps the body weight', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 360,
          child: SheenListGroup(children: [SheenListRow(title: 'Plain')]),
        ),
      ),
    );
    expect(t.widget<Text>(find.text('Plain')).style!.fontWeight, SheenType.standard.body.fontWeight);
  });
}
