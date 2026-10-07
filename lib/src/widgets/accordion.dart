import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A question that opens to its answer: a card with the [title] and a chevron; a tap reveals [child] below.
///
/// It keeps its own open state, or follows [open] when you pass it with [onChanged] (for a list where one item is open
/// at a time). Screen readers hear it as expanded or collapsed.
///
/// ```dart
/// Column(children: [
///   for (final (q, a) in faqs) SheenAccordion(title: q, child: Text(a)),
/// ])
/// ```
///
/// {@category Content}
class SheenAccordion extends StatefulWidget {
  /// An accordion titled [title] around [child].
  const SheenAccordion({
    super.key,
    required this.title,
    required this.child,
    this.open,
    this.onChanged,
    this.initiallyOpen = false,
  });

  /// The always-visible line.
  final String title;

  /// The content revealed when open.
  final Widget child;

  /// Whether it is open, when the parent decides; null lets the accordion keep its own state.
  final bool? open;

  /// Called with the new state when the title is tapped.
  final ValueChanged<bool>? onChanged;

  /// Whether it starts open (when [open] is null).
  final bool initiallyOpen;

  @override
  State<SheenAccordion> createState() => _SheenAccordionState();
}

class _SheenAccordionState extends State<SheenAccordion> {
  late bool _open = widget.initiallyOpen;

  bool get _isOpen => widget.open ?? _open;

  void _toggle() {
    final next = !_isOpen;
    if (widget.open == null) setState(() => _open = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final reduced = SheenMotion.reduced(context);
    final open = _isOpen;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SheenCard(
        radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              expanded: open,
              button: true,
              label: widget.title,
              excludeSemantics: true,
              onTap: _toggle,
              child: SheenPressable(
                pressedScale: 1,
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: t.type.body.copyWith(color: t.colors.text, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: open ? .5 : 0,
                        duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
                        child: SheenIcon(SheenIcons.chevronDown, size: 16, stroke: 2.2, color: t.colors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: reduced ? Duration.zero : const Duration(milliseconds: 220),
              curve: SheenMotion.easeOut,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: DefaultTextStyle.merge(
                        style: t.type.subhead.copyWith(color: t.colors.textSecondary, height: 1.4),
                        child: widget.child,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
