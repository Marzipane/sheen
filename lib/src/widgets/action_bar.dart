import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The bottom action bar (C1 SheenActionBar): the total for the stay and one prominent action on glass, above the home
/// indicator. The price is always the final price for the stay.
class SheenActionBar extends StatelessWidget {
  const SheenActionBar({
    super.key,
    required this.price,
    required this.action,
    required this.onAction,
    this.caption,
    this.loading = false,
    this.leading,
  });

  final String price;
  final String? caption;
  final String action;
  final VoidCallback? onAction;
  final bool loading;

  /// Replaces the price block (e.g. a hold timer or a note).
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
                        // a new total rolls its digits (M07); a long one scales down rather than lose its last digits
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: SheenRollingDigits(
                            price,
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
              SheenPrimaryButton(label: action, onPressed: onAction, loading: loading, height: 52),
            ],
          ),
        ),
      ),
    );
  }
}
