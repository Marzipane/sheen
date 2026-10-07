import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// The springs and timings of sheen, written the way Apple writes them: a perceptual duration and a bounce.
///
/// `SpringDescription.withDurationAndBounce` is the same physics as SwiftUI's `spring(duration:bounce:)`, so sheen moves
/// like native iOS.
///
/// {@category Motion}
abstract final class SheenMotion {
  /// Buttons, cards and chips springing back after the 120 ms press.
  static final SpringDescription press = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 250),
  );

  /// Tab lens, segmented control, toggles, chips, the save heart.
  static final SpringDescription snappy = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 300),
    bounce: .15,
  );

  /// Sheets, pill to sheet, the zoom into a detail page, popovers.
  static final SpringDescription smooth = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 450),
  );

  /// The hero photo settling, big layout changes.
  static final SpringDescription gentle = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 600),
  );

  /// A success check, once per success.
  static final SpringDescription celebrate = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 500),
    bounce: .3,
  );

  /// How long an element takes to fade in.
  static const Duration fadeIn = Duration(milliseconds: 180);

  /// How long an element takes to fade out.
  static const Duration fadeOut = Duration(milliseconds: 120);

  /// The cross-fade that replaces movement when the person asked for less motion.
  static const Duration reducedFade = Duration(milliseconds: 150);

  /// How long a pressed element takes to shrink to [pressScale].
  static const Duration pressDown = Duration(milliseconds: 120);

  /// The scale of a pressed button, card or chip.
  static const double pressScale = .97;

  /// The delay between items of a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 30);

  /// Items after this many enter together with the last staggered one.
  static const int staggerMax = 6;

  /// The curve for elements arriving.
  static const Curve easeOut = Cubic(0.2, 0, 0, 1);

  /// The curve for elements leaving.
  static const Curve easeIn = Cubic(0.4, 0, 1, 1);

  /// Settle times of the springs (within 0.002 of the target), for widgets that need a plain duration.
  static const Duration pressSettle = Duration(milliseconds: 337);

  /// The settle time of [snappy].
  static const Duration snappySettle = Duration(milliseconds: 385);

  /// The settle time of [smooth].
  static const Duration smoothSettle = Duration(milliseconds: 607);

  /// The settle time of [gentle].
  static const Duration gentleSettle = Duration(milliseconds: 809);

  /// The settle time of [celebrate].
  static const Duration celebrateSettle = Duration(milliseconds: 729);

  /// True when the person asked for less motion. iOS Reduce Motion sets accessibilityFeatures.reduceMotion only
  /// (MediaQuery.disableAnimations stays false there); Android's "remove animations" sets disableAnimations.
  ///
  /// Under a [SheenMotionScope] the answer is rebuilt when the setting changes while the app runs.
  static bool reduced(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ReducedMotion>();
    final bool ios =
        scope?.reduceMotion ??
        (View.maybeOf(context)?.platformDispatcher ?? WidgetsBinding.instance.platformDispatcher)
            .accessibilityFeatures
            .reduceMotion;
    return ios || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
  }

  /// Delay of item [index] in a staggered entrance: 30 ms apart, capped after the first six.
  static Duration staggerDelay(int index) => stagger * (index < staggerMax ? index : staggerMax - 1);

  /// Seconds until [spring] stays within 0.002 of its target, from rest at 0 to 1.
  static Duration settleOf(SpringDescription spring) {
    final sim = SpringSimulation(spring, 0, 1, 0);
    double last = 0;
    for (var t = 0.0; t < 4; t += 0.001) {
      if ((1 - sim.x(t)).abs() > 0.002) last = t;
    }
    return Duration(microseconds: ((last + 0.001) * 1e6).round());
  }

  /// The spring as a Curve over its settle time, for implicit animations that take a curve and a duration
  /// (use the matching *Settle duration).
  static Curve curveOf(SpringDescription spring) => _SpringCurve(spring);
}

class _SpringCurve extends Curve {
  _SpringCurve(this.spring) : _settle = SheenMotion.settleOf(spring).inMicroseconds / 1e6;

  final SpringDescription spring;
  final double _settle;

  @override
  double transformInternal(double t) => SpringSimulation(spring, 0, 1, 0).x(t * _settle);
}

/// Rebuilds everything that asked [SheenMotion.reduced] when the person turns Reduce Motion on or off while the app
/// runs. [SheenScope] places one for you.
///
/// {@category Motion}
class SheenMotionScope extends StatefulWidget {
  /// Watches the Reduce Motion setting for [child] and its descendants.
  const SheenMotionScope({super.key, required this.child});

  /// The subtree that reads [SheenMotion.reduced].
  final Widget child;

  @override
  State<SheenMotionScope> createState() => _SheenMotionScopeState();
}

class _SheenMotionScopeState extends State<SheenMotionScope> with WidgetsBindingObserver {
  bool _reduce = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAccessibilityFeatures() {
    final now = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;
    if (now != _reduce) setState(() => _reduce = now);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ReducedMotion(reduceMotion: _reduce, child: widget.child);
}

class _ReducedMotion extends InheritedWidget {
  const _ReducedMotion({required this.reduceMotion, required super.child});

  final bool reduceMotion;

  @override
  bool updateShouldNotify(_ReducedMotion old) => old.reduceMotion != reduceMotion;
}
