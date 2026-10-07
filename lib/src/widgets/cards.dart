import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The card surface (`.card`): s1, radius 24; in light a soft two-layer shadow. Inside a sheet ([SheenNested]) the
/// nested s2 surface and flat: on the sheet's white a shadow only darkens the grey's edges. Clips its child to the
/// corners.
class SheenCard extends StatelessWidget {
  const SheenCard({super.key, required this.child, this.color, this.radius = 24, this.padding});

  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry? padding;

  /// The card's shadow in light (fields on the page ground wear it too).
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

/// Save on a photo: a clear glass circle with a white heart, filled once saved. Visual [size], 44 pt hit area. Over
/// the no-photo placeholder ([onPhoto] false) the heart takes the ink colour, which stays legible in light.
class SheenSaveButton extends StatelessWidget {
  const SheenSaveButton({
    super.key,
    required this.saved,
    required this.onTap,
    required this.semanticLabel,
    this.size = 38,
    this.onPhoto = true,
  });

  final bool saved;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;
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

/// Page dots over a photo: 6 pt dots at white .5, the current one a 16 pt white pill. At most five dots show; past
/// five the window follows the current page.
class SheenPagerDots extends StatelessWidget {
  const SheenPagerDots({super.key, required this.count, required this.index});

  final int count;
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

/// Swipeable hotel photos with page dots at the bottom (dots only when there is more than one photo).
class SheenPhotoPager extends StatefulWidget {
  const SheenPhotoPager({super.key, required this.count, required this.photoBuilder});

  final int count;
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

/// The photo stand-in when the supplier sends none (a quarter of search replies): bed glyph and the app's label.
class SheenImagePlaceholder extends StatelessWidget {
  const SheenImagePlaceholder({super.key, required this.label, this.iconSize = 34});

  final String? label;
  final double iconSize;

  /// The boards' `.ph` (135°, #1A2030 → #0E121A); light uses s2 → s3.
  static const List<Color> _dark = [Color(0xFF1A2030), Color(0xFF0E121A)];

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: t.isDark ? _dark : [t.colors.surfaceMuted, t.colors.track],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenIcon(SheenIcons.bed, size: iconSize, filled: true, color: t.colors.textTertiary),
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

/// A search result (C3 SheenHotelCard, D05/D06): photo pager with Save; name and total; headline and per night; score,
/// "% recommend" and board; the cancellation line. Every field but name and total is optional and simply left out
/// when the supplier does not send it. The whole card is one button; Save is its own.
