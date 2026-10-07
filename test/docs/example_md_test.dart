// example/example.md is what pub.dev shows on the Example tab; keep it the same as the app it describes.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/travel.dart';

import '../helpers.dart';

void main() {
  test('example.md shows example/lib/minimal.dart as it is', () {
    final page = File('example/example.md').readAsStringSync();
    final app = File('example/lib/minimal.dart').readAsStringSync();
    expect(page, contains('```dart\n$app```'));
  });

  testWidgets('the hotel card snippet in example.md builds', (t) async {
    const photos = <String>[];
    void open() {}
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SheenHotelCard(
            name: 'Hotel Aurora',
            total: '€ 1,448',
            perNight: '€ 724 a night',
            headline: 'Old Town · 0.4 km to the centre',
            score: '9.1',
            cancellation: 'Free cancellation until 12 Oct',
            refundable: true,
            photoCount: photos.length,
            photoBuilder: (context, i) => Image.network(photos[i], fit: BoxFit.cover),
            noPhotoLabel: 'No photo',
            saveLabel: 'Save',
            onTap: open,
          ),
        ),
      ),
    );
    expect(find.text('Hotel Aurora'), findsOneWidget);
    expect(find.text('No photo'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
