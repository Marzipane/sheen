import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Text whose changed digits roll, like iOS numeric text: the new digit rises into place while the old one leaves
/// upward; unchanged characters stay still.
///
/// Digits are matched from the end, so 10:00 to 9:59 rolls the last digits and drops the first. Only the number rolls:
/// the words around it (a currency) stay whole and keep their shaping. With Reduce Motion the text changes in place.
/// Read as one label.
///
/// {@category Motion}
class SheenRollingDigits extends StatelessWidget {
  /// Rolling text showing [text].
  const SheenRollingDigits(this.text, {super.key, required this.style});

  /// The text.
  final String text;

  /// The text style (use tabular figures, such as [SheenType.price]).
  final TextStyle style;

  /// How long a roll takes.
  static const Duration duration = Duration(milliseconds: 260);

  /// How far a character travels, as a share of its height.
  static const double rise = .35;

  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _rtl = RegExp('[֐-ࣿיִ-﷿ﹰ-﻿]');

  @override
  Widget build(BuildContext context) {
    final reduced = SheenMotion.reduced(context);
    final first = text.indexOf(_digit);
    final last = text.lastIndexOf(_digit);
    final before = first < 0 ? text : text.substring(0, first);
    final number = first < 0 ? '' : text.substring(first, last + 1);
    final after = first < 0 ? '' : text.substring(last + 1);
    final chars = number.characters.toList();
    return Semantics(
      label: text,
      excludeSemantics: true,
      // A number reads left to right in every language: 12:48 must not become 84:21. Around it, a currency in Arabic
      // script follows the reading direction ("2,770.80 د.إ" shows the currency on the left); Latin text and digits
      // alone form one left-to-right run, as the bidi algorithm lays them out.
      child: Directionality(
        textDirection: _rtl.hasMatch(text) ? Directionality.of(context) : TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (before.isNotEmpty) Text(before, style: style),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (i, ch) in chars.indexed)
                    _Slot(key: ValueKey('slot-${chars.length - 1 - i}'), char: ch, style: style, reduced: reduced),
                ],
              ),
            ),
            if (after.isNotEmpty) Text(after, style: style),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({super.key, required this.char, required this.style, required this.reduced});

  final String char;
  final TextStyle style;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final current = ValueKey(char);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: reduced ? Duration.zero : SheenRollingDigits.duration,
        switchInCurve: SheenMotion.easeOut,
        switchOutCurve: SheenMotion.easeIn,
        layoutBuilder: (cur, previous) => Stack(alignment: Alignment.center, children: [...previous, ?cur]),
        transitionBuilder: (child, a) {
          // the incoming character comes up from below; the outgoing one (played backwards) leaves upward
          final incoming = child.key == current;
          final from = Offset(0, incoming ? SheenRollingDigits.rise : -SheenRollingDigits.rise);
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: from, end: Offset.zero).animate(a),
              child: child,
            ),
          );
        },
        child: Text(char, key: current, style: style),
      ),
    );
  }
}
