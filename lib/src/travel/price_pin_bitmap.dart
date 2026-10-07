import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

/// A [SheenPricePin] drawn as a PNG for a native map's marker (Google Maps draws markers from bitmaps, not widgets): the
/// same capsule, label and sizes, with the glass approximated by its tint and rim, and a soft shadow around it. The
/// image is [pixelRatio] times the logical size; give the marker the same ratio. Text grows with [textScale] up to
/// 1.5, as the widget's does.
///
/// {@category Travel}
Future<Uint8List> renderSheenPricePin(
  String label, {
  required bool selected,
  required SheenThemeData theme,
  double pixelRatio = 3,
  double textScale = 1,
}) async {
  final t = theme;
  final style = t.type
      .sized(t.type.price, selected ? 14 : 13)
      .copyWith(height: 1.1, color: selected ? t.colors.onAccent : t.colors.text);
  final tp = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.linear(textScale.clamp(1.0, 1.5)),
  )..layout();
  final padH = selected ? 13.0 : 11.0;
  final h = math.max(selected ? 34.0 : 30.0, tp.height + 12);
  final w = tp.width + padH * 2;
  const margin = 6.0; // room for the shadow
  final logical = Size(w + margin * 2, h + margin * 2);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final body = RRect.fromRectAndRadius(Rect.fromLTWH(margin, margin, w, h), Radius.circular(h / 2));
  canvas.drawRRect(
    body.shift(const Offset(0, 2)),
    Paint()
      ..color = const Color(0x59000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  final fill = selected
      ? t.colors.accent
      : Color.alphaBlend(t.colors.surfaceMuted.withValues(alpha: .94), t.colors.background);
  canvas.drawRRect(body, Paint()..color = fill);
  canvas.drawRRect(
    body.deflate(.4),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = t.isDark ? const Color(0x2EFFFFFF) : const Color(0x14000000),
  );
  tp.paint(canvas, Offset(margin + padH, margin + (h - tp.height) / 2));

  final image = await recorder.endRecording().toImage(
    (logical.width * pixelRatio).ceil(),
    (logical.height * pixelRatio).ceil(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}

/// A place picked on a map as a marker bitmap: its name in a red capsule over a red dot with a white ring.
/// The record's `anchor` is the dot's centre as a fraction of the image, for the marker's anchor.
///
/// {@category Travel}
Future<({Uint8List png, Offset anchor})> renderSheenPickedPlacePin(
  String label, {
  required SheenThemeData theme,
  double pixelRatio = 3,
  double textScale = 1,
  double maxWidth = 220,
}) async {
  final t = theme;
  final style = t.type
      .sized(t.type.subhead, 13)
      .copyWith(height: 1.1, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF));
  final tp = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.linear(textScale.clamp(1.0, 1.5)),
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);
  const padH = 12.0, gap = 6.0, dot = 16.0, ring = 3.0, margin = 6.0;
  final h = math.max(30.0, tp.height + 12);
  final w = tp.width + padH * 2;
  final logical = Size(math.max(w, dot + ring * 2) + margin * 2, h + gap + dot + ring * 2 + margin * 2);
  final cx = logical.width / 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  final shadow = Paint()
    ..color = const Color(0x59000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final body = RRect.fromRectAndRadius(Rect.fromLTWH(cx - w / 2, margin, w, h), Radius.circular(h / 2));
  canvas.drawRRect(body.shift(const Offset(0, 2)), shadow);
  canvas.drawRRect(body, Paint()..color = t.colors.danger);
  tp.paint(canvas, Offset(cx - tp.width / 2, margin + (h - tp.height) / 2));
  final centre = Offset(cx, margin + h + gap + ring + dot / 2);
  canvas.drawCircle(centre.translate(0, 1.5), dot / 2 + ring, shadow);
  canvas.drawCircle(centre, dot / 2 + ring, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawCircle(centre, dot / 2, Paint()..color = t.colors.danger);

  final image = await recorder.endRecording().toImage(
    (logical.width * pixelRatio).ceil(),
    (logical.height * pixelRatio).ceil(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return (png: png!.buffer.asUint8List(), anchor: Offset(centre.dx / logical.width, centre.dy / logical.height));
}
