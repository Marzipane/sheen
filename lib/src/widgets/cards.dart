import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A card: [SheenColors.surface] with 24-point corners and, in light, a soft two-layer shadow. Inside a sheet
/// ([SheenNested]) it takes [SheenColors.surfaceMuted] and no shadow. It clips its child to its corners.
///
/// {@category Content}
class SheenCard extends StatelessWidget {
  /// A card around [child].
  const SheenCard({super.key, required this.child, this.color, this.radius = 24, this.padding});

  /// The content.
  final Widget child;

  /// The card colour; [SheenColors.surface] (or [SheenColors.surfaceMuted] when nested) when null.
  final Color? color;

  /// The corner radius.
  final double radius;

  /// Space inside the card.
  final EdgeInsetsGeometry? padding;

  /// The card's shadow in the light theme (fields on the page ground wear it too).
  static final List<BoxShadow> lightShadow = [
    SheenGlassStyle.cssShadow(0, 1, 2, const Color.fromRGBO(16, 20, 30, .05)),
    SheenGlassStyle.cssShadow(0, 6, 20, const Color.fromRGBO(16, 20, 30, .06)),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final nested = SheenNested.of(context);
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? (nested ? t.colors.surfaceMuted : t.colors.surface),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: t.isDark || nested ? null : lightShadow,
      ),
      child: child,
    );
  }
}

/// A save (heart) button for photos: a clear glass circle with a white heart, filled once saved; [size] points across
/// with a 44-point hit area. Off a photo ([onPhoto] false) the heart takes the text colour.
///
/// {@category Content}
class SheenSaveButton extends StatelessWidget {
  /// A save button, filled when [saved].
  const SheenSaveButton({
    super.key,
    required this.saved,
    required this.onTap,
    required this.semanticLabel,
    this.size = 38,
    this.onPhoto = true,
  });

  /// Whether the item is saved.
  final bool saved;

  /// Called on a tap.
  final VoidCallback onTap;

  /// What a screen reader says, such as "Save".
  final String semanticLabel;

  /// The visible diameter.
  final double size;

  /// Whether the button sits on a photo (white heart) or on a plain surface.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) => SheenPressable(
    onTap: onTap,
    selected: saved,
    semanticLabel: semanticLabel,
    child: SheenGlass(
      variant: SheenGlassVariant.clear,
      shape: const CircleBorder(),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: SheenIcon(
            'heart',
            size: size / 2,
            stroke: 2,
            filled: saved,
            color: onPhoto ? const Color(0xFFFFFFFF) : context.sheen.colors.text,
          ),
        ),
      ),
    ),
  );
}

/// Page dots over a photo: 6-point dots at half white, the current one a 16-point white pill. At most five dots show;
/// with more pages the window follows the current page.
///
/// {@category Content}
class SheenPagerDots extends StatelessWidget {
  /// Dots for [count] pages with [index] current.
  const SheenPagerDots({super.key, required this.count, required this.index});

  /// The number of pages.
  final int count;

  /// The current page.
  final int index;

  static const int _max = 5;

  @override
  Widget build(BuildContext context) {
    final shown = count < _max ? count : _max;
    final first = (index - _max ~/ 2).clamp(0, count - shown);
    final d = SheenMotion.reduced(context) ? Duration.zero : SheenMotion.settleOf(SheenMotion.snappy);
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < shown; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            AnimatedContainer(
              duration: d,
              curve: SheenMotion.curveOf(SheenMotion.snappy),
              width: first + i == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: first + i == index ? const Color(0xFFFFFFFF) : const Color(0x80FFFFFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Swipeable photos with page dots at the bottom (dots only when there is more than one photo).
///
/// {@category Content}
class SheenPhotoPager extends StatefulWidget {
  /// A pager over [count] photos.
  const SheenPhotoPager({super.key, required this.count, required this.photoBuilder});

  /// The number of photos.
  final int count;

  /// Builds the photo at an index.
  final IndexedWidgetBuilder photoBuilder;

  @override
  State<SheenPhotoPager> createState() => _PhotoPagerState();
}

class _PhotoPagerState extends State<SheenPhotoPager> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.count == 1) return SizedBox.expand(child: widget.photoBuilder(context, 0));
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: widget.count,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (c, i) => SizedBox.expand(child: widget.photoBuilder(c, i)),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Center(
            child: SheenPagerDots(count: widget.count, index: _page),
          ),
        ),
      ],
    );
  }
}

/// A stand-in for a missing photo: a soft gradient with a glyph and an optional label.
///
/// {@category Content}
class SheenImagePlaceholder extends StatelessWidget {
  /// A placeholder with [icon] and an optional [label].
  const SheenImagePlaceholder({super.key, this.label, this.icon = SheenIcons.image, this.iconSize = 34});

  /// A short text under the glyph, such as "No photo".
  final String? label;

  /// The glyph ([SheenIcons]).
  final String icon;

  /// The glyph size in points.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: t.isDark ? [t.colors.track, t.colors.surface] : [t.colors.surfaceMuted, t.colors.track],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenIcon(icon, size: iconSize, color: t.colors.textTertiary),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(label!, style: t.type.footnote.copyWith(color: t.colors.textTertiary)),
            ],
          ],
        ),
      ),
    );
  }
}
