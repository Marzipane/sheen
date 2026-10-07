import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A stand-in photo drawn in code: a sky-to-ground gradient with a few soft blobs, the same for the same [seed].
///
/// The gallery ships no images, so glass has something real-looking to blur and the package stays free of
/// third-party pictures.
class GeneratedPhoto extends StatelessWidget {
  const GeneratedPhoto({super.key, required this.seed});

  final int seed;

  static const List<List<Color>> _palettes = [
    [Color(0xFF1B3A5C), Color(0xFF3F7CAC), Color(0xFFE9B872)], // dusk over water
    [Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFF8FC1B5)], // sea
    [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)], // sunset
    [Color(0xFF134E5E), Color(0xFF71B280), Color(0xFFDCE35B)], // hills
    [Color(0xFF232526), Color(0xFF6B4E71), Color(0xFFE0A96D)], // city at night
    [Color(0xFF355C7D), Color(0xFF6C5B7B), Color(0xFFF8B195)], // morning
  ];

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PhotoPainter(seed), child: const SizedBox.expand());
}

class _PhotoPainter extends CustomPainter {
  _PhotoPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    final colors = GeneratedPhoto._palettes[seed % GeneratedPhoto._palettes.length];
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
    for (var i = 0; i < 6; i++) {
      final c = Color.lerp(colors[r.nextInt(3)], const Color(0xFFFFFFFF), r.nextDouble() * .3)!;
      final center = Offset(r.nextDouble() * size.width, size.height * (.3 + r.nextDouble() * .7));
      final radius = size.shortestSide * (.15 + r.nextDouble() * .35);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = c.withValues(alpha: .55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * .45),
      );
    }
    // a horizon line and a darker foot, so white text over the photo reads
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .62, size.width, size.height * .38),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Colors.black45],
        ).createShader(Rect.fromLTWH(0, size.height * .62, size.width, size.height * .38)),
    );
  }

  @override
  bool shouldRepaint(_PhotoPainter old) => old.seed != seed;
}

/// Plain colours the painter needs (the gallery does not import Material).
abstract final class Colors {
  static const Color black45 = Color(0x73000000);
}
