import 'package:flutter/physics.dart';
import 'package:sheen/sheen.dart';

/// Points sampled on each spring for CSS `linear()`.
const int _samples = 32;

String _round(double value) {
  final fixed = value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
  return fixed.endsWith('.') ? fixed.substring(0, fixed.length - 1) : fixed;
}

/// The spring over its settle time as a CSS `linear()` easing, from the same simulation Flutter runs.
String _linear(SpringDescription spring, int settleMs) {
  final sim = SpringSimulation(spring, 0, 1, 0);
  final points = [
    for (var i = 0; i <= _samples; i++) _round(i == _samples ? 1 : sim.x(settleMs / 1000 * i / _samples)),
  ];
  return 'linear(${points.join(', ')})';
}

Map<String, Object> _spring(SpringDescription spring, Duration settle) => {
  'durationMs': settle.inMilliseconds,
  'linear': _linear(spring, settle.inMilliseconds),
};

/// Every motion value of [SheenMotion] as data, for sheen-web's `tokens.json`.
Map<String, Object> motionTokens() => {
  'springs': {
    'press': _spring(SheenMotion.press, SheenMotion.pressSettle),
    'snappy': _spring(SheenMotion.snappy, SheenMotion.snappySettle),
    'smooth': _spring(SheenMotion.smooth, SheenMotion.smoothSettle),
    'gentle': _spring(SheenMotion.gentle, SheenMotion.gentleSettle),
    'celebrate': _spring(SheenMotion.celebrate, SheenMotion.celebrateSettle),
  },
  'durationsMs': {
    'fadeIn': SheenMotion.fadeIn.inMilliseconds,
    'fadeOut': SheenMotion.fadeOut.inMilliseconds,
    'reducedFade': SheenMotion.reducedFade.inMilliseconds,
    'pressDown': SheenMotion.pressDown.inMilliseconds,
    'stagger': SheenMotion.stagger.inMilliseconds,
  },
  'easing': {'easeOut': 'cubic-bezier(0.2, 0, 0, 1)', 'easeIn': 'cubic-bezier(0.4, 0, 1, 1)'},
  'pressScale': SheenMotion.pressScale,
  'staggerMax': SheenMotion.staggerMax,
};
