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

void main() {
  testWidgets('a price pin as a PNG: a capsule wider than tall, at the pixel ratio; the selected one is bigger', (
    t,
  ) async {
    await t.runAsync(() async {
      final plain = await decode(
        await renderSheenPricePin('1,422', selected: false, theme: SheenThemeData.dark(), pixelRatio: 3),
      );
      final chosen = await decode(
        await renderSheenPricePin('1,422', selected: true, theme: SheenThemeData.dark(), pixelRatio: 3),
      );
      expect(plain.width, greaterThan(plain.height));
      // 30 pt capsule plus 6 pt of shadow room each side, at 3x
      expect(plain.height, (30 + 12) * 3);
      expect(chosen.height, (34 + 12) * 3);
      expect(chosen.width, greaterThan(plain.width));
      final longer = await decode(
        await renderSheenPricePin('14,967', selected: false, theme: SheenThemeData.dark(), pixelRatio: 3),
      );
      expect(longer.width, greaterThan(plain.width));
    });
  });

  testWidgets('the picked place as a PNG: its name over a red dot, anchored on the dot; a long name is cut', (
    t,
  ) async {
    await t.runAsync(() async {
      final pin = await renderSheenPickedPlacePin('Central Station', theme: SheenThemeData.dark(), pixelRatio: 3);
      final img = await decode(pin.png);
      // 30 pt capsule, 6 pt gap, a 16 pt dot in a 3 pt ring, 6 pt of shadow room above and below, at 3x
      expect(img.height, (30 + 6 + 16 + 6 + 12) * 3);
      expect(pin.anchor.dx, .5);
      expect(pin.anchor.dy, closeTo((6 + 30 + 6 + 3 + 8) / 70, .001));
      final rgba = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      Color at(Offset f) {
        final i = ((f.dy * img.height).floor() * img.width + (f.dx * img.width).floor()) * 4;
        return Color.fromARGB(rgba.getUint8(i + 3), rgba.getUint8(i), rgba.getUint8(i + 1), rgba.getUint8(i + 2));
      }

      expect(at(pin.anchor), SheenThemeData.dark().colors.danger, reason: 'the anchor is the red dot');
      final long = await decode(
        (await renderSheenPickedPlacePin(
          'Lisbon Humberto Delgado Airport Terminal 1 Arrivals Hall Concourse B',
          theme: SheenThemeData.dark(),
        )).png,
      );
      expect(long.width, lessThanOrEqualTo((220 + 24 + 12) * 3));
    });
  });
}
