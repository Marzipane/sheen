import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../foundation/glass_style.dart';
import '../foundation/theme.dart';
import 'color_matrix.dart';
import 'painters.dart';

/// A frosted-glass surface, drawn in Flutter with no platform views and no shaders.
///
/// It blurs and saturates what is behind it, lays a body gradient over a tint, and draws a 1 px gradient rim, inner
/// edge lines, a specular highlight and an outer shadow. [variant] picks the recipe from the theme
/// ([SheenThemeData.glass]); [style] overrides it.
///
/// ```dart
/// SheenGlass(
///   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
///   child: Text('Glass', style: context.sheen.type.headline),
/// )
/// ```
///
/// Performance: every glass surface under one `BackdropGroup` shares a single copy of the backdrop. [SheenScope]
/// provides that group; add another per route if your screens are not under it. Do not put glass inside list items:
/// a blur per row is expensive. Use a plain card there.
///
/// Accessibility: with high contrast on (`MediaQuery.highContrastOf`) or [SheenThemeData.reduceTransparency] set,
/// the glass becomes an opaque surface with a visible border.
///
/// {@category Glass}
class SheenGlass extends StatelessWidget {
  /// A glass surface in [shape] (a capsule by default) around [child].
  const SheenGlass({
    super.key,
    required this.child,
    this.shape = const StadiumBorder(),
    this.variant = SheenGlassVariant.regular,
    this.padding,
    this.style,
  });

  /// The content on the glass.
  final Widget child;

  /// The outline of the glass; a capsule by default. Use `RoundedRectangleBorder` or `RoundedSuperellipseBorder` for
  /// cards and panels.
  final ShapeBorder shape;

  /// Which of the theme's recipes to draw.
  final SheenGlassVariant variant;

  /// Space between the glass edge and [child].
  final EdgeInsetsGeometry? padding;

  /// A recipe that replaces the theme's one for this surface.
  final SheenGlassStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = context.sheen;
    final dir = Directionality.maybeOf(context);
    final g = style ?? theme.glass.of(variant);
    final opaque = theme.reduceTransparency || (MediaQuery.maybeHighContrastOf(context) ?? false);
    final content = padding == null ? child : Padding(padding: padding!, child: child);

    if (opaque) {
      final solid = switch (variant) {
        SheenGlassVariant.prominent => theme.colors.accent,
        _ => theme.isDark ? theme.colors.surfaceMuted : theme.colors.surface,
      };
      final s = shape;
      return CustomPaint(
        painter: SheenOuterShadowPainter(shape: s, shadows: g.shadows, textDirection: dir),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: solid,
            shape: s is OutlinedBorder ? s.copyWith(side: BorderSide(color: theme.colors.textTertiary)) : s,
          ),
          child: content,
        ),
      );
    }

    Widget body = DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: g.tint),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: g.body,
            stops: g.bodyStops,
          ),
        ),
        child: CustomPaint(
          foregroundPainter: SheenGlassEdgePainter(
            shape: shape,
            rim: g.rim,
            rimStops: g.rimStops,
            rimAngle: g.rimAngle,
            innerTop: g.innerTop,
            innerTopWidth: g.innerTopWidth,
            innerBottom: g.innerBottom,
            innerRing: g.innerRing,
            highlight: g.highlight,
            highlightCenter: g.highlightCenter,
            highlightStop: g.highlightStop,
            textDirection: dir,
          ),
          child: content,
        ),
      ),
    );
    if (g.blur > 0) {
      body = BackdropFilter.grouped(
        filter: ui.ImageFilter.compose(
          outer: ColorFilter.matrix(sheenColorMatrix(saturation: g.saturation, brightness: g.brightness)),
          inner: ui.ImageFilter.blur(sigmaX: g.blur, sigmaY: g.blur, tileMode: TileMode.mirror),
        ),
        child: body,
      );
    }
    return CustomPaint(
      painter: SheenOuterShadowPainter(shape: shape, shadows: g.shadows, textDirection: dir),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape, textDirection: dir),
        child: body,
      ),
    );
  }
}

/// The lens that marks the selected tab or segment inside a glass capsule, drawn with the theme's
/// [SheenGlassStyles.lens].
///
/// {@category Glass}
class SheenLens extends StatelessWidget {
  /// A lens in [shape] (a capsule by default), optionally around [child].
  const SheenLens({super.key, this.child, this.shape = const StadiumBorder()});

  /// The content on the lens, if any.
  final Widget? child;

  /// The outline of the lens.
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final l = context.sheen.glass.lens;
    final dir = Directionality.maybeOf(context);
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: l.fill),
      child: CustomPaint(
        foregroundPainter: SheenGlassEdgePainter(
          shape: shape,
          rim: const [Color(0x00FFFFFF), Color(0x00FFFFFF)],
          rimStops: const [0, 1],
          rimAngle: 180,
          innerTop: l.innerTop,
          innerTopWidth: l.innerTopWidth,
          innerRing: l.ring,
          textDirection: dir,
        ),
        child: child,
      ),
    );
  }
}
