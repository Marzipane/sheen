import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// One card at a time from a list, changed by a sideways swipe: the next card slides in from the end of the line.
///
/// The [index] is the parent's; the swiper reports the wanted one through [onChanged]. Screen readers get next and
/// previous actions. With Reduce Motion the cards cross-fade.
///
/// ```dart
/// SheenCardSwiper(
///   count: stays.length,
///   index: chosen,
///   onChanged: (i) => setState(() => chosen = i),
///   itemBuilder: (context, i) => StayCard(stays[i]),
/// )
/// ```
///
/// {@category Content}
class SheenCardSwiper extends StatefulWidget {
  /// A swiper over [count] cards showing [index].
  const SheenCardSwiper({
    super.key,
    required this.count,
    required this.index,
    required this.onChanged,
    required this.itemBuilder,
    this.nextLabel,
    this.previousLabel,
  });

  /// The number of cards.
  final int count;

  /// The card shown.
  final int index;

  /// Called with the card a swipe or an action asks for.
  final ValueChanged<int> onChanged;

  /// Builds the card at an index.
  final IndexedWidgetBuilder itemBuilder;

  /// The screen reader's next action; [SheenStrings.next] when null.
  final String? nextLabel;

  /// The screen reader's previous action; [SheenStrings.previous] when null.
  final String? previousLabel;

  @override
  State<SheenCardSwiper> createState() => _SheenCardSwiperState();
}

class _SheenCardSwiperState extends State<SheenCardSwiper> {
  /// +1 when the last step went forward, -1 back: where the new card comes from.
  int _dir = 1;

  void _step(int by) {
    final i = widget.index + by;
    if (i < 0 || i >= widget.count) return;
    HapticFeedback.selectionClick();
    setState(() => _dir = by);
    widget.onChanged(i);
  }

  @override
  Widget build(BuildContext context) {
    final strings = SheenStrings.of(context);
    final reduced = SheenMotion.reduced(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final at = widget.index;
    return Semantics(
      customSemanticsActions: {
        if (at < widget.count - 1) CustomSemanticsAction(label: widget.nextLabel ?? strings.next): () => _step(1),
        if (at > 0) CustomSemanticsAction(label: widget.previousLabel ?? strings.previous): () => _step(-1),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 150) return;
          // a swipe towards the start of the line brings the next card in
          _step((v < 0) != rtl ? 1 : -1);
        },
        child: AnimatedSwitcher(
          duration: reduced ? SheenMotion.reducedFade : const Duration(milliseconds: 240),
          switchInCurve: SheenMotion.easeOut,
          switchOutCurve: SheenMotion.easeOut,
          layoutBuilder: (current, previous) =>
              Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
          transitionBuilder: (child, a) {
            if (reduced) return FadeTransition(opacity: a, child: child);
            final incoming = child.key == ValueKey(at);
            final from = (incoming ? .35 : -.35) * _dir * (rtl ? -1 : 1);
            return FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: Offset(from, 0), end: Offset.zero).animate(a),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(key: ValueKey(at), child: widget.itemBuilder(context, at)),
        ),
      ),
    );
  }
}
