import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A banner in the flow of a page that tells about a change and offers one action: "Prices changed · Show".
///
/// A glyph in a soft circle of its [tone], a title, an optional message, and the action as a text link at the end.
///
/// {@category Feedback}
class SheenActionBanner extends StatelessWidget {
  /// A banner titled [title].
  const SheenActionBanner({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = SheenTone.info,
    this.actionLabel,
    this.onAction,
    this.onTap,
  });

  /// The glyph ([SheenIcons]).
  final String icon;

  /// What changed.
  final String title;

  /// More about it.
  final String? message;

  /// The colour of the glyph.
  final SheenTone tone;

  /// The action's label; no action when null.
  final String? actionLabel;

  /// Called by the action.
  final VoidCallback? onAction;

  /// Called when the banner itself is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final color = tone.color(t.colors);
    Widget body = SheenCard(
      radius: 18,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 10, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: .14), shape: BoxShape.circle),
            child: Center(child: SheenIcon(icon, size: 18, stroke: 2.2, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: t.type.subhead.copyWith(color: t.colors.text, fontWeight: FontWeight.w600),
                ),
                if (message != null) Text(message!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            SheenTextLink(label: actionLabel!, onPressed: onAction, size: 15),
          ],
        ],
      ),
    );
    if (onTap != null) body = SheenPressable(onTap: onTap, pressedScale: .99, child: body);
    return body;
  }
}

/// A small capsule that names a state, such as "Confirmed" or "Pending", in the colour of its [tone].
///
/// {@category Feedback}
class SheenStatusPill extends StatelessWidget {
  /// A pill showing [label].
  const SheenStatusPill({super.key, required this.label, this.tone = SheenTone.neutral, this.icon});

  /// The state.
  final String label;

  /// The colour.
  final SheenTone tone;

  /// A glyph before the label.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final color = tone.color(t.colors);
    return DecoratedBox(
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: color.withValues(alpha: .14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[SheenIcon(icon!, size: 13, stroke: 2.4, color: color), const SizedBox(width: 5)],
            Text(
              label,
              style: t.type.caption.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
