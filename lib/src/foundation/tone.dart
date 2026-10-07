import 'package:flutter/painting.dart';

import 'colors.dart';

/// What a message means, which picks its colour: toasts, banners, status pills and status screens take a tone.
///
/// {@category Foundation}
enum SheenTone {
  /// Plain information, in the accent colour.
  info,

  /// Something went well.
  success,

  /// Something needs attention soon.
  warning,

  /// Something failed or cannot be undone.
  danger,

  /// No particular meaning, in the secondary text colour.
  neutral;

  /// The colour of this tone in [colors].
  Color color(SheenColors colors) => switch (this) {
    SheenTone.info => colors.accentText,
    SheenTone.success => colors.success,
    SheenTone.warning => colors.warning,
    SheenTone.danger => colors.danger,
    SheenTone.neutral => colors.textSecondary,
  };
}
