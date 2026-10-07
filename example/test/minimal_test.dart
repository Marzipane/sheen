import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen_gallery/minimal.dart' show TripPage;

void main() {
  Future<void> pumpTrip(WidgetTester t) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => SheenScope(child: child!),
        home: const TripPage(),
      ),
    );
  }

  testWidgets('the example.md app picks a sort order from a sheet', (t) async {
    await pumpTrip(t);
    expect(find.text('Lowest price'), findsOneWidget);
    await t.tap(find.text('Sort by'));
    await t.pumpAndSettle();
    await t.tap(find.text('Best rated'));
    await t.pumpAndSettle();
    expect(find.text('Best rated'), findsOneWidget);
    expect(find.text('Lowest price'), findsNothing);
  });

  testWidgets('the example.md app confirms a booking and shows a toast', (t) async {
    await pumpTrip(t);
    await t.tap(find.text('Book').last);
    await t.pumpAndSettle();
    expect(find.text('Book Casa do Rio?'), findsOneWidget);
    await t.tap(find.text('Book').last);
    await t.pumpAndSettle();
    expect(find.text('Booked'), findsOneWidget);
    SheenToast.hide();
    await t.pumpAndSettle();
  });
}
