import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

Future<ui.Image> decode(List<int> png) async {
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(png));
  return (await codec.getNextFrame()).image;
}

Future<Color> pixel(ui.Image image, int x, int y) async {
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final i = (y * image.width + x) * 4;
  return Color.fromARGB(bytes.getUint8(i + 3), bytes.getUint8(i), bytes.getUint8(i + 1), bytes.getUint8(i + 2));
}

void main() {
  testWidgets('a place pin as a PNG: a 34 pt fill circle with room for its shadow, a white glyph in the middle', (
    t,
  ) async {
    await t.runAsync(() async {
      final pin = await decode(await renderSheenPlacePin(theme: SheenThemeData.dark(), pixelRatio: 3));
      expect(pin.width, (34 + 12) * 3);
      expect(pin.height, pin.width);
      // inside the circle, beside the glyph: the fill colour
      final ring = await pixel(pin, (6 + 4) * 3, 23 * 3);
      expect(ring.toARGB32(), SheenThemeData.dark().colors.accent.toARGB32());
      // the glyph: somewhere in its 18 pt box there is white
      var white = false;
      for (var y = 14 * 3; y < 32 * 3 && !white; y += 2) {
        for (var x = 14 * 3; x < 32 * 3 && !white; x += 2) {
          final c = await pixel(pin, x, y);
          white = c.r > .95 && c.g > .95 && c.b > .95;
        }
      }
      expect(white, isTrue);
    });
  });
}
