import 'dart:math' as math;

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// One tab of the [SheenTabBar]: a filled glyph from the design kit and its label (a translated string).
@immutable
class SheenTabItem {
  const SheenTabItem({required this.icon, required this.label, this.badge});
  final String icon;
  final String label;

  /// A short count or mark shown on the glyph; null for none.
  final String? badge;
}

/// The iOS 27 floating tab bar (C1 SheenTabBar): four tabs on one glass capsule, the selected tab on a lens, and
/// search as its own circle.
///
/// The lens slides on the snappy spring and stretches 12 % along its travel, and the new icon dips to 86 % (M03).
/// [minimized] shrinks it to the current tab, an optional [accessory] (a held room) and search, on the smooth
/// spring (M02). With reduced motion the lens jumps and the bars crossfade.
///
/// Press and slide (U01, as the iOS 26 bar and Telegram): a finger on the capsule lifts the lens at once, well past
/// the capsule, and it zooms what is under it 1.22 x; the bar's glass swells and runs into the search circle through a
/// liquid neck (owner 5 Oct, Telegram). The lens follows the finger with a selection tick at each tab and on to the
/// search circle; letting go opens what is under it (away from the bar: nothing changes). A plain tap selects as
/// before. With reduced motion the lens only swells 6 %, nothing zooms and the glass keeps its shape.
class SheenTabBar extends StatefulWidget {
  const SheenTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.onSearch,
    required this.searchLabel,
    this.searchActive = false,
    this.minimized = false,
    this.accessory,
    this.onAccessory,
    this.onRestore,
  });

  final List<SheenTabItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onSearch;
  final String searchLabel;

  /// Search is the active destination: the search circle carries the lens, no tab does.
  final bool searchActive;
  final bool minimized;
  final Widget? accessory;
  final VoidCallback? onAccessory;

  /// Tap on the current-tab circle of the minimized bar; defaults to selecting the current tab.
  final VoidCallback? onRestore;

  static const double height = 62;

  /// The widest the bar and its search circle grow in a wide window (iPad): four tabs do not stretch across it.
  static const double maxWidth = 560;
  static const double minimizedHeight = 52;
  static const double gap = 10;

  @override
  State<SheenTabBar> createState() => _SheenTabBarState();
}

class _SheenTabBarState extends State<SheenTabBar> with TickerProviderStateMixin {
  late final AnimationController _lens = AnimationController.unbounded(vsync: this, value: widget.index.toDouble());
  late final AnimationController _stretch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final AnimationController _mini = AnimationController.unbounded(vsync: this, value: widget.minimized ? 1 : 0);
  late final Animation<double> _stretchX = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: SheenMotion.easeOut)), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: SheenMotion.easeOut)), weight: 24),
  ]).animate(_stretch);

  bool _reduced = false;

  // press and slide: 0 at rest, 1 lifted
  late final AnimationController _lift = AnimationController.unbounded(vsync: this);
  int? _pointer;
  Offset _down = Offset.zero;
  bool _sliding = false;
  bool _away = false;
  int _hover = 0;
  int _downTab = 0;

  /// How far a finger moves before the lens follows it (a plain tap below it), and how far above or below the bar a
  /// release still counts as on it.
  static const double _slop = 6, _reach = 44;
  static const double _zoom = 1.22, _swell = .06;

  /// Lifted: the lens' extra height and width (Telegram's is about 1.35 x the bar), and how far the bar's glass grows
  /// out on each side and closes the gap to the search circle.
  static const double _lensTaller = 30, _lensWider = .28, _barOutX = 1, _barOutY = 1;

  /// Lifted, the whole bar rises off the page (owner 5 Oct, the iOS Fitness bar: about 10 % taller and wider): it grows
  /// 9 % about its centre, its glass 1 pt more on each side, and its shadow deepens.
  static const double _elevate = .09;

  /// The bar's scale now (1 at rest).
  double get _scale => _reduced ? 1 : 1 + _elevate * _lift.value.clamp(0.0, 1.0);

  /// A finger's x on the scaled bar, in the bar's own (unscaled) coordinates.
  double _unscaled(double x, _BarGeometry g) => g.total / 2 + (x - g.total / 2) / _scale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = SheenMotion.reduced(context);
  }

  @override
  void didUpdateWidget(SheenTabBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      if (_reduced) {
        _lens.value = widget.index.toDouble();
      } else {
        _lens.animateWith(SpringSimulation(SheenMotion.snappy, _lens.value, widget.index.toDouble(), _lens.velocity));
        _stretch.forward(from: 0);
      }
    }
    if (old.minimized != widget.minimized) {
      final target = widget.minimized ? 1.0 : 0.0;
      if (_reduced) {
        _mini.animateTo(target, duration: SheenMotion.fadeIn, curve: SheenMotion.easeOut);
      } else {
        _mini.animateWith(SpringSimulation(SheenMotion.smooth, _mini.value, target, _mini.velocity));
      }
    }
  }

  @override
  void dispose() {
    _lens.dispose();
    _lift.dispose();
    _stretch.dispose();
    _mini.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i != widget.index) HapticFeedback.selectionClick();
    widget.onSelect(i);
  }

  /// The lens' place along the bar for x (the bar's own coordinates): 0 … n - 1 over the tabs, n on the search circle.
  double _at(double x, _BarGeometry g) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final s = rtl ? g.total - x : x; // from the bar's start edge
    final last = g.tabCentre(g.n - 1);
    if (s <= last) return ((s - 4) / g.tw - .5).clamp(0.0, g.n - 1.0);
    return (g.n - 1 + (s - last) / (g.searchCentre - last)).clamp(0.0, g.n.toDouble());
  }

  void _press(PointerDownEvent e, _BarGeometry g) {
    if (_pointer != null) return;
    // a press on the search circle is its own tap; the lens lifts from the capsule
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final s = rtl ? g.total - e.localPosition.dx : e.localPosition.dx; // at rest: not scaled yet
    if (s > g.capW) return;
    _pointer = e.pointer;
    _down = e.localPosition;
    _sliding = false;
    _away = false;
    final at = _at(e.localPosition.dx, g);
    _hover = _downTab = at.round();
    if (_reduced) {
      _lift.value = 1;
      _lens.value = _hover.toDouble();
    } else {
      _lift.animateWith(SpringSimulation(SheenMotion.snappy, _lift.value, 1, 0));
      _lens.animateWith(SpringSimulation(SheenMotion.snappy, _lens.value, _hover.toDouble(), _lens.velocity));
    }
    setState(() {});
  }

  void _move(PointerMoveEvent e, _BarGeometry g) {
    if (e.pointer != _pointer) return;
    if (!_sliding && (e.localPosition - _down).distance < _slop) return;
    _sliding = true;
    _away = e.localPosition.dy < -_reach || e.localPosition.dy > SheenTabBar.height + _reach;
    final at = _at(_unscaled(e.localPosition.dx, g), g);
    _lens.value = at; // glued to the finger
    final tab = at.round();
    if (tab != _hover) {
      _hover = tab;
      HapticFeedback.selectionClick();
    }
    setState(() {});
  }

  void _release(PointerEvent e, {required bool cancel}) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_reduced) {
      _lift.value = 0;
    } else {
      _lift.animateWith(SpringSimulation(SheenMotion.snappy, _lift.value, 0, _lift.velocity));
    }
    // a slide that ends on the bar opens the tab under it; a short wobble on the pressed tab is the tap's to handle
    final opens = !cancel && !_away && (_hover != _downTab || (e.localPosition - _down).distance >= kTouchSlop);
    final search = _hover >= widget.items.length;
    if (opens && search) {
      // slid on to the search circle: search opens, the lens goes home under it
      widget.onSearch();
    }
    if (opens && !search && _hover != widget.index) {
      widget.onSelect(_hover);
    } else {
      final home = widget.index.toDouble();
      if (_reduced) {
        _lens.value = home;
      } else {
        _lens.animateWith(SpringSimulation(SheenMotion.snappy, _lens.value, home, _lens.velocity));
      }
    }
    _sliding = false;
    setState(() {});
  }

  /// The lifted lens: drawn over the bar (not clipped by it), and inside it the bar's faces again, zoomed about its
  /// centre. Over the tabs it is a tab wide; on its way to search it turns into a circle around the search glyph.
  Widget _lifted(BuildContext context, _BarGeometry g) {
    final t = context.sheen;
    final lift = _lift.value.clamp(0.0, 1.2);
    final v = _lens.value.clamp(0.0, g.n.toDouble());
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final h = _reduced ? 54 * (1 + _swell * lift) : 54 + _lensTaller * lift;
    final grow = _reduced ? 1 + _swell * lift : 1 + _lensWider * lift;
    final toSearch = (v - (g.n - 1)).clamp(0.0, 1.0);
    final w = _lerp(g.tw * grow, h, toSearch);
    final zoom = _reduced ? 1.0 : 1 + (_zoom - 1) * lift.clamp(0.0, 1.0);
    final centreStart = v <= g.n - 1 ? g.tabCentre(v) : _lerp(g.tabCentre(g.n - 1.0), g.searchCentre, toSearch);
    final centre = rtl ? g.total - centreStart : centreStart;
    final left = centre - w / 2;
    final top = SheenTabBar.height / 2 - h / 2;
    final hover = v.round();
    return Positioned(
      key: const ValueKey('tab-lens-lifted'),
      left: left,
      top: top,
      width: w,
      height: h,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: t.isDark ? t.colors.track : t.colors.surface,
              shadows: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, t.isDark ? .45 : .16),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const SheenLens(),
                  // the lens' edge splits the light, as the iOS 26 lens does
                  if (!_reduced) const IgnorePointer(child: CustomPaint(painter: _PrismRim())),
                  Transform.scale(
                    key: const ValueKey('tab-lens-zoom'),
                    scale: zoom,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -left,
                          top: -top,
                          width: g.total,
                          height: SheenTabBar.height,
                          child: _faces(context, g, hover),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// The bar's tabs and search glyph as the lifted lens shows them, the one under it in the accent colour.
  Widget _faces(BuildContext context, _BarGeometry g, int hover) {
    final t = context.sheen;
    final onSearch = hover >= g.n;
    return Row(
      children: [
        SizedBox(
          width: g.capW,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                for (var i = 0; i < g.n; i++)
                  Expanded(
                    child: _face(
                      context,
                      widget.items[i],
                      i == hover ? t.colors.accentText : t.colors.text,
                      fringe: !_reduced && i == hover,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: SheenTabBar.gap),
        SizedBox.square(
          dimension: SheenTabBar.height,
          child: Center(
            child: SheenIcon(
              SheenIcons.search,
              size: 25,
              stroke: 2.3,
              color: onSearch ? t.colors.accentText : t.colors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _search(double size, double icon) {
    final t = context.sheen;
    final on = widget.searchActive;
    return SheenPressable(
      onTap: widget.onSearch,
      semanticLabel: widget.searchLabel,
      selected: on,
      minSize: 0,
      child: SheenGlass(
        shape: const CircleBorder(),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (on) const Positioned.fill(child: SheenLens(shape: CircleBorder())),
              SheenIcon(SheenIcons.search, size: icon, stroke: 2.3, color: on ? t.colors.accentText : t.colors.text),
            ],
          ),
        ),
      ),
    );
  }

  /// The search circle's face on the full bar: the glass is the bar's own (one shape with the capsule).
  Widget _searchFace() {
    final t = context.sheen;
    final on = widget.searchActive;
    return SheenPressable(
      onTap: widget.onSearch,
      semanticLabel: widget.searchLabel,
      selected: on,
      minSize: 0,
      child: SizedBox.square(
        dimension: SheenTabBar.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (on) const Positioned.fill(child: SheenLens(shape: CircleBorder())),
            SheenIcon(SheenIcons.search, size: 25, stroke: 2.3, color: on ? t.colors.accentText : t.colors.text),
          ],
        ),
      ),
    );
  }

  Widget _full() {
    final n = widget.items.length;
    return SizedBox(
      height: SheenTabBar.height,
      child: LayoutBuilder(
        builder: (context, outer) {
          final g = _BarGeometry(total: outer.maxWidth, n: n);
          return Listener(
            onPointerDown: (e) => _press(e, g),
            onPointerMove: (e) => _move(e, g),
            onPointerUp: (e) => _release(e, cancel: false),
            onPointerCancel: (e) => _release(e, cancel: true),
            child: AnimatedBuilder(
              animation: Listenable.merge([_lens, _stretch, _lift]),
              builder: (context, _) {
                final lifted = _lift.value > .01;
                // pressed, the glass swells and runs into the search circle (Telegram); not with reduced motion
                final out = _reduced || _lift.value < .01 ? 0.0 : _lift.value.clamp(0.0, 1.0);
                // the circle grows with the glass' height, so the gap closes by twice that growth
                final shape = SheenBarBorder(gap: SheenTabBar.gap - 2 * _barOutY * out, merge: out);
                final scale = _scale;
                return Transform.scale(
                  key: const ValueKey('tab-bar-elevation'),
                  scale: scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        key: const ValueKey('tab-bar-glass'),
                        left: -_barOutX * out,
                        right: -_barOutX * out,
                        top: -_barOutY * out,
                        bottom: -_barOutY * out,
                        child: DecoratedBox(
                          // lifted off the page: a deeper shadow under the whole bar
                          decoration: ShapeDecoration(
                            shape: shape,
                            shadows: [
                              if (out > 0)
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, .20 * out),
                                  blurRadius: 30 * out,
                                  offset: Offset(0, 12 * out),
                                ),
                            ],
                          ),
                          child: SheenGlass(shape: shape, child: const SizedBox.expand()),
                        ),
                      ),
                      Row(
                        children: [
                          // as tall as the bar (and search beside it); sized by its 54 pt tabs it was 8 pt short and cut the lens' bottom flat
                          SizedBox(
                            width: g.capW,
                            height: SheenTabBar.height,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  PositionedDirectional(
                                    start: g.tw * _lens.value.clamp(0.0, n - 1.0),
                                    top: 4,
                                    width: g.tw,
                                    height: 54,
                                    child: Opacity(
                                      opacity: widget.searchActive || lifted ? 0 : 1,
                                      child: Transform.scale(scaleX: _stretchX.value, child: const SheenLens()),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (var i = 0; i < n; i++)
                                        Expanded(
                                          child: _Tab(
                                            item: widget.items[i],
                                            selected: i == widget.index && !widget.searchActive,
                                            reduced: _reduced,
                                            onTap: () => _select(i),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: SheenTabBar.gap),
                          _searchFace(),
                        ],
                      ),
                      if (lifted) _lifted(context, g),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _wrapTap(Widget child) =>
      widget.onAccessory == null ? child : SheenPressable(onTap: widget.onAccessory, minSize: 0, child: child);

  Widget _minimized() {
    final t = context.sheen;
    final current = widget.items[widget.index];
    return SizedBox(
      height: SheenTabBar.minimizedHeight,
      child: Row(
        children: [
          SheenPressable(
            onTap: widget.onRestore ?? () => widget.onSelect(widget.index),
            semanticLabel: current.label,
            selected: true,
            minSize: 0,
            child: SheenGlass(
              shape: const CircleBorder(),
              child: SizedBox.square(
                dimension: SheenTabBar.minimizedHeight,
                child: Center(child: SheenIcon(current.icon, filled: true, size: 24, color: t.colors.accentText)),
              ),
            ),
          ),
          const SizedBox(width: SheenTabBar.gap),
          Expanded(
            child: widget.accessory == null
                ? const SizedBox()
                : _wrapTap(
                    SheenGlass(
                      child: SizedBox(
                        height: SheenTabBar.minimizedHeight,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8, end: 6),
                          child: widget.accessory,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: SheenTabBar.gap),
          _search(SheenTabBar.minimizedHeight, 23),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: AnimatedBuilder(
        animation: _mini,
        builder: (context, _) {
          final m = _mini.value.clamp(-0.2, 1.2);
          final mo = m.clamp(0.0, 1.0);
          const origin = Alignment(-.4, 1);
          final full = Opacity(
            opacity: 1 - mo,
            child: _reduced
                ? _full()
                : Transform(
                    alignment: origin,
                    transform: Matrix4.identity()
                      ..translateByDouble(0, 6 * m, 0, 1)
                      ..scaleByDouble(1 - .14 * m, 1 - .16 * m, 1, 1),
                    child: _full(),
                  ),
          );
          final mini = Opacity(
            opacity: mo,
            child: _reduced
                ? _minimized()
                : Transform(
                    alignment: origin,
                    transform: Matrix4.identity()..scaleByDouble(1.08 - .08 * m, 1.12 - .12 * m, 1, 1),
                    child: _minimized(),
                  ),
          );
          return SizedBox(
            height: SheenTabBar.height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (mo < 1)
                  IgnorePointer(
                    ignoring: mo > .5,
                    child: ExcludeSemantics(excluding: mo > .5, child: full),
                  ),
                if (mo > 0)
                  IgnorePointer(
                    ignoring: mo <= .5,
                    child: ExcludeSemantics(excluding: mo <= .5, child: mini),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A tab's glyph (with its badge) over its label, in [color]; [dip] scales the glyph (M03), [fringe] adds the slight
/// colour fringe a zooming lens gives its glyph.
Widget _face(BuildContext context, SheenTabItem item, Color color, {Animation<double>? dip, bool fringe = false}) {
  final t = context.sheen;
  final badge = item.badge;
  Widget glyph(Color c) => SheenIcon(item.icon, filled: true, size: 25, color: c);
  final icon = Stack(
    clipBehavior: Clip.none,
    children: [
      if (fringe) ...[
        Transform.translate(offset: const Offset(-.7, 0), child: glyph(const Color(0x8CFF5A5A))),
        Transform.translate(offset: const Offset(.7, 0), child: glyph(const Color(0x995AAAFF))),
      ],
      glyph(color),
      if (badge != null)
        PositionedDirectional(
          top: -3,
          end: -8,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16),
            height: 16,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: t.colors.danger),
            alignment: Alignment.center,
            child: Text(
              badge,
              style: t.type
                  .sized(t.type.caption, 11)
                  .copyWith(fontWeight: FontWeight.w700, color: t.colors.onAccent, height: 1),
            ),
          ),
        ),
    ],
  );
  return SizedBox(
    height: 54,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (dip != null) ScaleTransition(scale: dip, child: icon) else icon,
        const SizedBox(height: 1),
        ExcludeSemantics(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
            style: t.type.tabLabel.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}

class _Tab extends StatefulWidget {
  const _Tab({required this.item, required this.selected, required this.reduced, required this.onTap});

  final SheenTabItem item;
  final bool selected;
  final bool reduced;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  late final AnimationController _dip = AnimationController.unbounded(vsync: this, value: 1);

  @override
  void didUpdateWidget(_Tab old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected && !widget.reduced) {
      // The new icon dips to 86 % and springs back (M03).
      _dip.animateTo(.86, duration: const Duration(milliseconds: 80), curve: SheenMotion.easeOut).then((_) {
        if (mounted) _dip.animateWith(SpringSimulation(SheenMotion.snappy, _dip.value, 1, 0));
      });
    }
  }

  @override
  void dispose() {
    _dip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: widget.onTap,
      semanticLabel: widget.item.label,
      selected: widget.selected,
      minSize: 0,
      child: _face(context, widget.item, widget.selected ? t.colors.accentText : t.colors.text, dip: _dip),
    );
  }
}

/// The bottom accessory of the minimized tab bar: a thumbnail, a title and subtitle, and a trailing value — today
/// the held room with its countdown (D02).
class SheenTabAccessory extends StatelessWidget {
  const SheenTabAccessory({super.key, required this.title, this.subtitle, this.leading, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    return Row(
      children: [
        if (leading != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox.square(dimension: 34, child: leading),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.type
                    .sized(t.type.subhead, 14)
                    .copyWith(fontWeight: FontWeight.w600, color: t.colors.text, height: 1.2),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.type.caption.copyWith(color: t.colors.textSecondary, height: 1.2),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!, const SizedBox(width: 8)],
      ],
    );
  }
}

/// Where things sit on the full bar ([total] wide): the capsule, its [n] tabs and the search circle at the end.
@immutable
class _BarGeometry {
  const _BarGeometry({required this.total, required this.n});
  final double total;
  final int n;

  double get capW => total - SheenTabBar.gap - SheenTabBar.height;
  double get tw => (capW - 8) / n;

  /// Tab [i]'s centre (fractional between tabs) from the bar's start edge.
  double tabCentre(num i) => 4 + tw * (i + .5);

  /// The search circle's centre from the bar's start edge.
  double get searchCentre => total - SheenTabBar.height / 2;
}

/// The full tab bar's glass as one shape: the capsule and, [gap] after it, the search circle as tall as the shape. With
/// [merge] above 0 a liquid neck joins them, its waist growing with [merge] (the iOS 26 bar and Telegram while a
/// finger presses it); at 0 they are the two separate shapes of the bar at rest. Right to left, the circle is on the left.
class SheenBarBorder extends ShapeBorder {
  const SheenBarBorder({this.gap = SheenTabBar.gap, this.merge = 0});

  final double gap;
  final double merge;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final h = rect.height, r = h / 2;
    final rtl = textDirection == TextDirection.rtl;
    final capW = (rect.width - gap - h).clamp(h, double.infinity);
    final cap = rtl ? Rect.fromLTWH(rect.right - capW, rect.top, capW, h) : Rect.fromLTWH(rect.left, rect.top, capW, h);
    final circle = rtl ? Rect.fromLTWH(rect.left, rect.top, h, h) : Rect.fromLTWH(rect.right - h, rect.top, h, h);
    final shapes = Path()
      ..addRRect(RRect.fromRectAndRadius(cap, Radius.circular(r)))
      ..addOval(circle);
    final m = merge.clamp(0.0, 1.0);
    if (m <= 0) return shapes;
    // the neck: from the capsule's end cap to the circle, top and bottom curves leaving each circle along its tangent
    final c1 = Offset(rtl ? cap.left + r : cap.right - r, cap.center.dy);
    final c2 = circle.center;
    final dir = c2.dx > c1.dx ? 1.0 : -1.0;
    // where the neck meets each circle, from the axis: none at 0, 60° at 1, so the neck grows out of nothing
    final a = 60 * m * math.pi / 180;
    final sinA = math.sin(a), cosA = math.cos(a);
    final p1 = Offset(c1.dx + dir * r * cosA, c1.dy - r * sinA);
    final p2 = Offset(c2.dx - dir * r * cosA, c2.dy - r * sinA);
    final span = (p2.dx - p1.dx).abs();
    if (span <= 0) return shapes;
    final k = span * .45;
    // the waist's half height (a cubic between level ends dips by 3/4 of its handles); none yet: two shapes still
    if (r * sinA - .75 * k * cosA <= .5) return shapes;
    final q1 = Offset(p1.dx, c1.dy + r * sinA), q2 = Offset(p2.dx, c2.dy + r * sinA);
    final neck = Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(p1.dx + dir * k * sinA, p1.dy + k * cosA, p2.dx - dir * k * sinA, p2.dy + k * cosA, p2.dx, p2.dy)
      ..lineTo(q2.dx, q2.dy)
      ..cubicTo(q2.dx - dir * k * sinA, q2.dy - k * cosA, q1.dx + dir * k * sinA, q1.dy - k * cosA, q1.dx, q1.dy)
      ..close();
    return Path.combine(PathOperation.union, shapes, neck);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  bool operator ==(Object other) => other is SheenBarBorder && other.gap == gap && other.merge == merge;

  @override
  int get hashCode => Object.hash(gap, merge);
}

/// The lifted lens' rim: a thin ring whose colour runs round the spectrum, faint, brighter top and bottom.
class _PrismRim extends CustomPainter {
  const _PrismRim();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(.8);
    final path = const StadiumBorder().getOuterPath(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = const SweepGradient(
        colors: [
          Color(0x9966E0FF),
          Color(0x99A98BFF),
          Color(0x99FF7EB6),
          Color(0x99FFD27A),
          Color(0x9966E0FF),
          Color(0x99A98BFF),
          Color(0x99FF7EB6),
          Color(0x99FFD27A),
          Color(0x9966E0FF),
        ],
      ).createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PrismRim old) => false;
}
