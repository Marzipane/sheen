import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  testWidgets('without a value the bar holds only its action, across the bar', (t) async {
    var taps = 0;
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenActionBar(actionLabel: 'Continue', onAction: () => taps++),
        ),
      ),
    );

    expect(find.byType(SheenRollingDigits), findsNothing);
    final bar = t.getRect(find.byType(SheenActionBar));
    final button = t.getRect(find.byType(SheenPrimaryButton));
    expect(button.width, greaterThan(bar.width * .9));
    expect(find.ancestor(of: find.byType(SheenPrimaryButton), matching: find.byType(SheenGlass)), findsOneWidget);

    await t.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('right to left, an action-only bar is laid out the same way', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenActionBar(actionLabel: 'Continue', onAction: () {}),
        ),
        direction: TextDirection.rtl,
      ),
    );
    final bar = t.getRect(find.byType(SheenActionBar));
    final button = t.getRect(find.byType(SheenPrimaryButton));
    expect(button.center.dx, closeTo(bar.center.dx, 1));
  });
}
