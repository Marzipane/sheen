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

  testWidgets('a weight token reaches the title style', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 360,
          child: SheenListGroup(
            children: [
              SheenListRow(title: 'Semibold', titleWeight: SheenWeight.semibold),
              SheenListRow(title: 'Bold', subtitle: 'Under it', titleWeight: SheenWeight.bold),
            ],
          ),
        ),
      ),
    );
    expect(t.widget<Text>(find.text('Semibold')).style!.fontWeight, SheenWeight.semibold);
    expect(t.widget<Text>(find.text('Bold')).style!.fontWeight, SheenWeight.bold);
  });

  test('the weight tokens are the type scale\'s own weights', () {
    for (final type in [SheenType.standard, SheenType.material]) {
      expect(type.body.fontWeight, SheenWeight.regular);
      expect(type.headline.fontWeight, SheenWeight.semibold);
      expect(type.title.fontWeight, SheenWeight.bold);
    }
  });
}
