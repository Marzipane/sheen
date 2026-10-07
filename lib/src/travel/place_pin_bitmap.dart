import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sheen/sheen.dart';

/// The place of one hotel on a native map's marker (D08 "Around the hotel"): a 34 pt circle in the fill colour with a
/// white [icon] glyph, a thin rim and a soft shadow around it, as a PNG [pixelRatio] times the logical size. Give the
/// marker the same ratio and anchor it at the centre.
Future<Uint8List> renderSheenPlacePin({
  required SheenThemeData theme,
  String icon = 'bed',
  double pixelRatio = 3,
}) async {
  const d = 34.0, margin = 6.0, glyph = 18.0;
  const side = d + margin * 2;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  const centre = Offset(side / 2, side / 2);
  canvas.drawCircle(
    centre.translate(0, 2),
    d / 2,
    Paint()
      ..color = const Color(0x59000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.drawCircle(centre, d / 2, Paint()..color = theme.colors.accent);
  canvas.drawCircle(
    centre,
    d / 2 - .5,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x40FFFFFF),
  );
  final info = await vg.loadPicture(SvgStringLoader(SheenIcon(icon, filled: true).svg()), null);
  canvas
    ..save()
    ..translate(side / 2 - glyph / 2, side / 2 - glyph / 2)
    ..scale(glyph / info.size.width)
    ..saveLayer(
      Offset.zero & info.size,
      Paint()..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
    )
    ..drawPicture(info.picture)
    ..restore()
    ..restore();
  info.picture.dispose();
  final image = await recorder.endRecording().toImage((side * pixelRatio).ceil(), (side * pixelRatio).ceil());
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}
