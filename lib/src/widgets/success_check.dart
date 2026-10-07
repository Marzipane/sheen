import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A filled check that springs in once with a success haptic, for a moment worth marking: a booking made, a payment
/// done. With Reduce Motion it fades in instead.
///
/// {@category Feedback}
class SheenSuccessCheck extends StatefulWidget {
  /// A success check [size] points across.
  const SheenSuccessCheck({super.key, this.size = 44, this.color, this.semanticLabel});

  /// The diameter.
  final double size;

  /// The colour; [SheenColors.success] when null.
  final Color? color;

  /// What a screen reader says, such as "Booked".
  final String? semanticLabel;

  @override
  State<SheenSuccessCheck> createState() => _SheenSuccessCheckState();
}

class _SheenSuccessCheckState extends State<SheenSuccessCheck> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.successNotification();
  }

  @override
  Widget build(BuildContext context) => SheenEntrance(
    scaleFrom: .4,
    spring: SheenMotion.celebrate,
    child: SheenIcon(
      SheenIcons.checkCircleFill,
      size: widget.size,
      color: widget.color ?? context.sheen.colors.success,
      semanticLabel: widget.semanticLabel,
    ),
  );
}
