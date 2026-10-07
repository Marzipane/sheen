import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/space.dart';

/// Press feedback for anything tappable: 120 ms down to 0.97, then back on the press spring, so a tap answers within
/// the 100 ms people perceive as instant.
///
/// With Reduce Motion it dims instead of scaling. The hit area is at least 44 × 44 pt (Apple's Human Interface
/// Guidelines) even around a small glyph. It does not dim when disabled ([onTap] null): each widget draws its own
/// disabled look.
///
/// ```dart
/// SheenPressable(onTap: open, semanticLabel: 'Open', child: const SheenIcon(SheenIcons.chev))
/// ```
///
/// {@category Motion}
class SheenPressable extends StatefulWidget {
  /// Press feedback around [child] (or what [builder] builds) that calls [onTap].
  const SheenPressable({
    super.key,
    required this.onTap,
    this.child,
    this.builder,
    this.semanticLabel,
    this.onLongPress,
    this.minSize = SheenSpace.hit,
    this.pressedScale = SheenMotion.pressScale,
    this.selected,
  }) : assert(child != null || builder != null, 'Give a child or a builder');

  /// Called on a tap; null disables the press.
  final VoidCallback? onTap;

  /// Called on a long press.
  final VoidCallback? onLongPress;

  /// The content; give this or [builder].
  final Widget? child;

  /// Builds the content with the pressed state, for components whose look changes while held (a darker fill).
  final Widget Function(BuildContext context, bool pressed)? builder;

  /// What a screen reader says for this button; null keeps the content's own semantics.
  final String? semanticLabel;

  /// The smallest hit area, in points, on each side.
  final double minSize;

  /// The scale while pressed.
  final double pressedScale;

  /// For toggles and tabs: exposes the selected state to screen readers.
  final bool? selected;

  @override
  State<SheenPressable> createState() => _SheenPressableState();
}

class _SheenPressableState extends State<SheenPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _scale = AnimationController.unbounded(vsync: this, value: 1);
  bool _down = false;
  bool _reduced = false;
  bool _live = true;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = SheenMotion.reduced(context);
  }

  // The recognizer cancels its tap while this subtree is being torn down; no lookups or setState after deactivate.
  @override
  void deactivate() {
    _live = false;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _live = true;
  }

  void _press(bool down) {
    if (!_live || !_enabled || _down == down) return;
    setState(() => _down = down);
    if (_reduced) return;
    if (down) {
      _scale.animateTo(widget.pressedScale, duration: SheenMotion.pressDown, curve: SheenMotion.easeOut);
    } else {
      _scale.animateWith(SpringSimulation(SheenMotion.press, _scale.value, 1, _scale.velocity));
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = _reduced;
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.minSize, minHeight: widget.minSize),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: AnimatedBuilder(
              animation: _scale,
              builder: (context, child) => Opacity(
                opacity: reduced && _down ? .6 : 1,
                child: Transform.scale(scale: reduced ? 1 : _scale.value, child: child),
              ),
              child: widget.builder?.call(context, _down) ?? widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
