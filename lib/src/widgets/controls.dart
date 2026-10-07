import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A filter or sort chip (C2 FilterChip): 36 high capsule, 14/600. On = inverted (ink fill), off = glass. Optional
/// leading glyph and a menu chevron. Chip rows scroll sideways and never wrap.
class SheenChip extends StatelessWidget {
  const SheenChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.menu = false,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? icon;
  final bool menu;

  /// A glyph after the label (e.g. a filled star for "3 ★").
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final fg = selected ? t.colors.background : t.colors.text;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[SheenIcon(icon!, size: 16, stroke: 2, color: fg), const SizedBox(width: 6)],
          // a long label (a long translation, a narrow phone) ends in an ellipsis rather than overflowing the chip
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.type.sized(t.type.subhead, 14).copyWith(fontWeight: FontWeight.w600, color: fg, height: 1),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            SheenIcon(trailingIcon!, size: 13, filled: true, color: fg),
          ],
          if (menu) ...[const SizedBox(width: 6), SheenIcon(SheenIcons.chevronDown, size: 14, stroke: 2.4, color: fg)],
        ],
      ),
    );
    return SheenPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      child: SizedBox(
        height: 36,
        child: selected
            ? DecoratedBox(
                decoration: ShapeDecoration(shape: const StadiumBorder(), color: t.colors.text),
                child: Center(widthFactor: 1, child: content),
              )
            : SheenGlass(child: Center(widthFactor: 1, child: content)),
      ),
    );
  }
}

/// One segment of a [SheenSegmentedControl], with an optional count line (Explore: "Visa-free / 126").
@immutable
class SheenSegment {
  const SheenSegment(this.label, {this.count});
  final String label;
  final String? count;
}

/// A segmented control on glass (C2): 2 to 4 segments, the selected one on a lens that slides on the snappy spring.
class SheenSegmentedControl extends StatefulWidget {
  const SheenSegmentedControl({super.key, required this.segments, required this.index, required this.onChanged});

  final List<SheenSegment> segments;

  /// The chosen segment; -1 for none yet (a choice the user has to make, such as a guest's title).
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<SheenSegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SheenSegmentedControl> with SingleTickerProviderStateMixin {
  // made on first use: a control with no choice yet may never need it, and must not make it while it is unmounted
  AnimationController? _lensController;
  AnimationController get _lens =>
      _lensController ??= AnimationController.unbounded(vsync: this, value: widget.index.clamp(0, 1 << 20).toDouble());

  @override
  void didUpdateWidget(SheenSegmentedControl old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      // from no choice the lens appears where the choice is, it does not slide in from the first segment
      if (SheenMotion.reduced(context) || old.index < 0) {
        _lens.value = widget.index.toDouble();
      } else {
        _lens.animateWith(SpringSimulation(SheenMotion.snappy, _lens.value, widget.index.toDouble(), _lens.velocity));
      }
    }
  }

  @override
  void dispose() {
    _lensController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // Its text stays at the system size, as UISegmentedControl's does under Dynamic Type.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    final counts = widget.segments.any((s) => s.count != null);
    final h = counts ? 48.0 : 36.0;
    final n = widget.segments.length;
    // inside a sheet: the iOS look on the nested surface (a grey track, a raised thumb), not glass on a white ground
    final nested = SheenNested.of(context);
    Widget track({required Widget child}) => nested
        ? DecoratedBox(
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: t.colors.surfaceMuted),
            child: child,
          )
        : SheenGlass(child: child);
    final thumb = nested
        ? DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: t.isDark ? t.colors.track : t.colors.surface,
              shadows: [
                BoxShadow(
                  color: t.colors.text.withValues(alpha: t.isDark ? 0 : .10),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          )
        : const SheenLens();
    return SizedBox(
      height: h,
      child: track(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth / n;
              return Stack(
                children: [
                  if (widget.index >= 0)
                    AnimatedBuilder(
                      animation: _lens,
                      builder: (c, _) =>
                          PositionedDirectional(start: w * _lens.value, top: 3, width: w, height: h - 6, child: thumb),
                    ),
                  Row(
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(
                          child: SheenPressable(
                            minSize: 0,
                            selected: i == widget.index,
                            semanticLabel: widget.segments[i].count == null
                                ? widget.segments[i].label
                                : '${widget.segments[i].label}, ${widget.segments[i].count}',
                            onTap: () {
                              if (i != widget.index) HapticFeedback.selectionClick();
                              widget.onChanged(i);
                            },
                            child: SizedBox(
                              height: h - 6,
                              child: Center(
                                child: ExcludeSemantics(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.segments[i].label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.type
                                            .sized(t.type.footnote, counts ? 12 : 13)
                                            .copyWith(
                                              fontWeight: i == widget.index ? FontWeight.w700 : FontWeight.w600,
                                              color: i == widget.index ? t.colors.text : t.colors.textSecondary,
                                              height: 1.1,
                                            ),
                                      ),
                                      if (widget.segments[i].count != null)
                                        Text(
                                          widget.segments[i].count!,
                                          style: t.type
                                              .sized(t.type.price, 14)
                                              .copyWith(
                                                color: i == widget.index ? t.colors.text : t.colors.textSecondary,
                                                height: 1.15,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Minus · value · plus (C2 Stepper): glass circles of 36 with a 44 pt hit area; a bound disables its side.
class SheenStepper extends StatelessWidget {
  const SheenStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.min = 0,
    this.max = 99,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String decreaseLabel;
  final String increaseLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    Widget button(String icon, String label, bool enabled, int to) => Opacity(
      opacity: enabled ? 1 : .4,
      child: SheenPressable(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged(to);
              }
            : null,
        semanticLabel: label,
        child: SheenGlass(
          shape: const CircleBorder(),
          child: SizedBox.square(
            dimension: 36,
            child: Center(child: SheenIcon(icon, size: 18, stroke: 2.2, color: t.colors.text)),
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button('minus', decreaseLabel, value > min, value - 1),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 18),
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: t.type.price.copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
          ),
        ),
        const SizedBox(width: 6),
        button('plus', increaseLabel, value < max, value + 1),
      ],
    );
  }
}

/// An iOS-style switch (C2 Switch): 51 × 31, green when on, the knob slides on the snappy spring.
class SheenSwitch extends StatelessWidget {
  const SheenSwitch({super.key, required this.value, required this.onChanged, required this.semanticLabel});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  static const Color onColor = Color(0xFF30A46C);

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final reduced = SheenMotion.reduced(context);
    final d = reduced ? Duration.zero : SheenMotion.snappySettle;
    final curve = SheenMotion.curveOf(SheenMotion.snappy);
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: semanticLabel,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onChanged!(!value);
              },
        child: Opacity(
          opacity: onChanged == null ? .5 : 1,
          child: AnimatedContainer(
            duration: d,
            width: 51,
            height: 31,
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: value ? onColor : t.colors.track),
            child: AnimatedAlign(
              duration: d,
              curve: curve,
              alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 2), blurRadius: 5)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Counts down the server's hold (C2 SheenCountdownPill): amber while held, red in the last two minutes, grey at 0:00.
class SheenCountdownPill extends StatefulWidget {
  const SheenCountdownPill({super.key, required this.remaining, required this.semanticLabel});

  final Duration remaining;

  /// The translated "room held" label read before the time.
  final String semanticLabel;

  /// Under this the hold is nearly over: the pill turns red and pulses once (M07).
  static const Duration warnAt = Duration(minutes: 2);

  static String format(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  State<SheenCountdownPill> createState() => _HoldTimerPillState();
}

class _HoldTimerPillState extends State<SheenCountdownPill> with TickerProviderStateMixin {
  // one pulse when the hold crosses 2:00; three shakes of 4 pt when it runs out (M09)
  late final AnimationController _pulse = AnimationController(vsync: this, duration: SheenMotion.snappySettle);
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void didUpdateWidget(SheenCountdownPill old) {
    super.didUpdateWidget(old);
    final was = old.remaining, now = widget.remaining;
    final reduced = SheenMotion.reduced(context);
    if (was > SheenCountdownPill.warnAt && now <= SheenCountdownPill.warnAt && now > Duration.zero) {
      HapticFeedback.warningNotification();
      if (!reduced) _pulse.forward(from: 0);
    }
    if (was > Duration.zero && now <= Duration.zero) {
      HapticFeedback.errorNotification();
      if (!reduced) _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final remaining = widget.remaining;
    final color = remaining <= Duration.zero
        ? t.colors.textTertiary
        : remaining <= SheenCountdownPill.warnAt
        ? t.colors.danger
        : t.colors.warning;
    final text = SheenCountdownPill.format(remaining);
    return Semantics(
      label: '${widget.semanticLabel}, $text',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _shake]),
        builder: (context, child) {
          // the pulse: up 8 % and back; the shake: three swings that fade out
          final p = _pulse.isAnimating ? math.sin(_pulse.value * math.pi) : 0.0;
          final k = _shake.isAnimating ? math.sin(_shake.value * math.pi * 6) * 4 * (1 - _shake.value) : 0.0;
          return Transform.translate(
            offset: Offset(k, 0),
            child: Transform.scale(scale: 1 + .08 * p, child: child),
          );
        },
        child: SheenGlass(
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SheenIcon(SheenIcons.hourglass, size: 16, stroke: 2.2, color: color),
                  const SizedBox(width: 6),
                  SheenRollingDigits(text, style: t.type.sized(t.type.timer, 15).copyWith(color: color)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
