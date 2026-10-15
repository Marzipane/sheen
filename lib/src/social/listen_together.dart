import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'people.dart';
import 'strings.dart';

/// Listening together in a chat: who hosts, what plays, and Join or Leave, on the accent.
///
/// ```dart
/// SheenListenTogetherBanner(
///   title: 'danil is listening — join in',
///   subtitle: 'Habibi — Sabi',
///   people: ['danil'],
///   joined: false,
///   onJoin: jam.join,
/// )
/// ```
///
/// {@category Social}
class SheenListenTogetherBanner extends StatelessWidget {
  /// A banner saying [title].
  const SheenListenTogetherBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.people = const [],
    this.joined = false,
    this.onJoin,
    this.onLeave,
    this.actionLabel,
  });

  /// "danil is listening — join in", "You're hosting".
  final String title;

  /// The song playing.
  final String? subtitle;

  /// Who listens.
  final List<String> people;

  /// Whether I take part (shows Leave instead of Join).
  final bool joined;

  /// Joins.
  final VoidCallback? onJoin;

  /// Leaves (or ends, for the host).
  final VoidCallback? onLeave;

  /// The button's label; Join or Leave by default.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    final on = t.colors.onAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: t.colors.accent, borderRadius: BorderRadius.circular(SheenRadius.group)),
      child: Row(
        children: [
          if (people.isNotEmpty) ...[SheenAvatarStack(names: people, size: 30), const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.type.headline.copyWith(color: on),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.type.footnote.copyWith(color: on),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SheenPressable(
            onTap: joined ? onLeave : onJoin,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: ShapeDecoration(color: on.withValues(alpha: .22), shape: const StadiumBorder()),
              child: Text(
                actionLabel ?? (joined ? s.leave : s.join),
                style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: on),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
