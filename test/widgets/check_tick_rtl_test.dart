import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

/// The tick as the box paints it, in pixels.
Future<Uint8List> _tick(WidgetTester t, TextDirection direction) async {
  await t.pumpWidget(
    host(
      SheenCheck(value: true, onChanged: (_) {}, label: 'I agree'),
      direction: direction,
    ),
  );
  final paint = t.widget<CustomPaint>(
    find.descendant(of: find.byKey(const ValueKey('sheen-check-box')), matching: find.byType(CustomPaint)),
  );
  const side = SheenControlSize.check;
  final recorder = ui.PictureRecorder();
  paint.painter!.paint(Canvas(recorder), const Size(side, side));
  final bytes = await t.runAsync(() async {
    final image = await recorder.endRecording().toImage(side.toInt(), side.toInt());
    return (await image.toByteData())!.buffer.asUint8List();
  });
  return bytes!;
}

void main() {
  testWidgets('right to left, the tick is the same tick as left to right, not mirrored', (t) async {
    final ltr = await _tick(t, TextDirection.ltr);
    final rtl = await _tick(t, TextDirection.rtl);
    expect(ltr.any((b) => b != 0), isTrue);
    expect(rtl, ltr);
  });
}
