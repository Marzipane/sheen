import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// A message: text in a bubble (mine in the accent at the end, theirs muted at the start), or any [child] such as a
/// [SheenShareCard], with the sender's name above it in groups and reactions under it.
///
/// A long press (or [onHold]) is where an app opens its [SheenReactionBar].
///
/// {@category Social}
class SheenChatBubble extends StatelessWidget {
  /// A message with [text], or with [child] instead.
  const SheenChatBubble({
    super.key,
    this.text,
    this.child,
    this.mine = false,
    this.author,
    this.footer,
    this.reactions,
    this.onHold,
  }) : assert(text != null || child != null);

  /// The message text.
  final String? text;

  /// Content other than text (a shared song); replaces the bubble.
  final Widget? child;

  /// Whether I sent it.
  final bool mine;

  /// The sender's name, shown above in group chats.
  final String? author;

  /// A small line under the message ("Seen").
  final String? footer;

  /// Reactions under the message, usually a [SheenReactions].
  final Widget? reactions;

  /// A long press: open the reaction bar.
  final VoidCallback? onHold;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final width = MediaQuery.sizeOf(context).width;
    final body =
        child ??
        DecoratedBox(
          decoration: BoxDecoration(
            color: mine ? t.colors.accent : t.colors.surfaceMuted,
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(20),
              topEnd: const Radius.circular(20),
              bottomStart: Radius.circular(mine ? 20 : 6),
              bottomEnd: Radius.circular(mine ? 6 : 20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Text(
              text!,
              textDirection: sheenTextDirectionOf(text!),
              style: t.type.body.copyWith(color: mine ? t.colors.onAccent : t.colors.text, height: 1.35),
            ),
          ),
        );
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (width * .82).clamp(0, 440)),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (author != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 2),
                child: Text(
                  author!,
                  style: t.type.caption.copyWith(fontWeight: FontWeight.w600, color: t.colors.textSecondary),
                ),
              ),
            GestureDetector(onLongPress: onHold, child: body),
            if (reactions != null)
              Transform.translate(
                offset: const Offset(0, -6),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: reactions),
              ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(footer!, style: t.type.caption.copyWith(color: t.colors.textTertiary)),
              ),
          ],
        ),
      ),
    );
  }
}

/// One reaction under a message: its emoji, how many chose it, and whether I did.
///
/// {@category Social}
@immutable
class SheenReactionCount {
  /// [emoji] chosen by [count] people, [mine] when one of them is me.
  const SheenReactionCount({required this.emoji, required this.count, this.mine = false, this.label});

  /// The emoji.
  final String emoji;

  /// How many people chose it.
  final int count;

  /// Whether I chose it.
  final bool mine;

  /// What a screen reader says ("🔥 from danil, mariam").
  final String? label;
}

/// The reaction chips under a message; tapping one calls [onTap] (an app adds or removes mine).
///
/// {@category Social}
class SheenReactions extends StatelessWidget {
  /// Chips for [reactions].
  const SheenReactions({super.key, required this.reactions, this.onTap});

  /// The reactions.
  final List<SheenReactionCount> reactions;

  /// A chip was tapped.
  final ValueChanged<SheenReactionCount>? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final r in reactions)
          SheenPressable(
            onTap: onTap == null ? null : () => onTap!(r),
            minSize: 24,
            semanticLabel: r.label ?? r.emoji,
            selected: r.mine,
            child: ExcludeSemantics(
              child: Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: ShapeDecoration(
                  color: t.colors.surface,
                  shape: StadiumBorder(
                    side: BorderSide(color: r.mine ? t.colors.accent : t.colors.separator, width: r.mine ? 1.5 : 1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r.emoji, style: const TextStyle(fontSize: 13, height: 1.2)),
                    if (r.count > 1) ...[
                      const SizedBox(width: 3),
                      Text(
                        '${r.count}',
                        style: t.type.caption.copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The emoji to react with, in a floating pill; the one I chose is marked.
///
/// {@category Social}
class SheenReactionBar extends StatelessWidget {
  /// A bar of [emojis].
  const SheenReactionBar({super.key, this.emojis = defaults, this.chosen, required this.onPick});

  /// The usual set.
  static const defaults = ['❤️', '🔥', '😂', '😮', '🙏', '👎'];

  /// The emoji offered.
  final List<String> emojis;

  /// The emoji I chose before, if any.
  final String? chosen;

  /// An emoji was picked.
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    return Semantics(
      label: s.react,
      container: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: t.colors.sheet,
          shape: StadiumBorder(side: BorderSide(color: t.colors.separator)),
          shadows: const [BoxShadow(color: Color(0x3D000000), blurRadius: 32, offset: Offset(0, 12))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in emojis)
                SheenPressable(
                  onTap: () => onPick(e),
                  selected: e == chosen,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: e == chosen ? t.colors.surfaceMuted : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 24, height: 1.1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three dots that rise in turn while someone types; still under Reduce Motion.
///
/// {@category Social}
class SheenTypingIndicator extends StatefulWidget {
  /// Typing dots.
  const SheenTypingIndicator({super.key});

  @override
  State<SheenTypingIndicator> createState() => _SheenTypingIndicatorState();
}

class _SheenTypingIndicatorState extends State<SheenTypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Semantics(
      label: SheenSocialStrings.of(context).typing,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.surfaceMuted,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
            bottomEnd: Radius.circular(20),
            bottomStart: Radius.circular(6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Builder(
                    builder: (context) {
                      final phase = ((_c.value - i * .17) % 1 + 1) % 1;
                      final up = phase < .3 ? phase / .3 : (phase < .6 ? (.6 - phase) / .3 : 0.0);
                      return Transform.translate(
                        offset: Offset(0, -2 * up),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: t.colors.textTertiary.withValues(alpha: .35 + .65 * up),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
