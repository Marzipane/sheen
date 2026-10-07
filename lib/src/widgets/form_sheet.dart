import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A form page that becomes a centred card on wide windows.
///
/// On a phone it shows [child] as it is. From [SheenLayout.splitMin] it shows it as a form sheet at most
/// [SheenLayout.sheet] wide, centred over the background, the way iPadOS presents forms; [child] lays itself out for
/// the card's size, and the keyboard covers the card only by what rises above its bottom edge.
///
/// ```dart
/// Navigator.of(context).push(PageRouteBuilder(pageBuilder: (_, _, _) => const SheenFormSheet(child: CheckoutPage())));
/// ```
///
/// {@category Sheets}
class SheenFormSheet extends StatelessWidget {
  /// Presents [child] as a form sheet on wide windows.
  const SheenFormSheet({super.key, required this.child});

  /// The page.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (!SheenLayout.isWide(mq.size.width)) return child;
    final t = context.sheen;
    final w = math.min(SheenLayout.sheet, mq.size.width - 48);
    final h = math.max(320.0, mq.size.height - mq.padding.top - mq.padding.bottom - 48);
    final gap = (mq.size.height - h) / 2;
    return ColoredBox(
      color: t.colors.background,
      child: Center(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SheenRadius.sheet),
            boxShadow: [
              BoxShadow(color: t.colors.text.withValues(alpha: .12), blurRadius: 40, offset: const Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SheenRadius.sheet),
            child: MediaQuery(
              data: mq.copyWith(
                size: Size(w, h),
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                viewPadding: const EdgeInsets.only(top: 8, bottom: 8),
                viewInsets: mq.viewInsets.copyWith(bottom: math.max(0, mq.viewInsets.bottom - gap)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
