import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A bottom bar on glass with a figure and one prominent action: a total and Book, a count and Continue.
///
/// When [value] changes, its digits roll ([SheenRollingDigits]). The bar keeps its text at the system size, as
/// iOS tab, navigation and tool bars do, so it stays one bar at large text sizes.
///
/// ```dart
/// SheenActionBar(
///   value: '€ 1,240',
///   caption: 'Total for 3 nights',
///   actionLabel: 'Book',
///   onAction: book,
/// )
/// ```
///
/// {@category Navigation}
class SheenActionBar extends StatelessWidget {
  /// A bar showing [value] and an [actionLabel] button.
  const SheenActionBar({
    super.key,
    required this.value,
    required this.actionLabel,
    required this.onAction,
    this.caption,
    this.loading = false,
    this.leading,
  });

  /// The figure, already formatted (a total, a count).
  final String value;

  /// A line under [value], such as "Total for 3 nights".
  final String? caption;

  /// The label of the action button.
  final String actionLabel;

  /// Called by the action button; null disables it.
  final VoidCallback? onAction;

  /// Shows a spinner in the action button and ignores taps.
  final bool loading;

  /// Replaces the value block (for example a countdown or a note).
  final Widget? leading;

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as UIKit tab, navigation and tool bars do under Dynamic Type.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    return SheenGlass(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 22, end: 10),
          child: Row(
            children: [
              Expanded(
                child:
                    leading ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // a new value rolls its digits; a long one scales down rather than lose its last digits
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: SheenRollingDigits(
                            value,
                            style: t.type.sized(t.type.price, 18).copyWith(color: t.colors.text, height: 1.25),
                          ),
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.type.caption.copyWith(color: t.colors.textSecondary, height: 1.25),
                          ),
                      ],
                    ),
              ),
              const SizedBox(width: 10),
              SheenPrimaryButton(label: actionLabel, onPressed: onAction, loading: loading, height: 52),
            ],
          ),
        ),
      ),
    );
  }
}
