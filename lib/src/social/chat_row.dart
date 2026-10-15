import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'people.dart';
import 'strings.dart';

/// One chat in a list: who it is with, the last message, its time and how many messages are unread.
///
/// Unread chats show the last message in the text colour and a count in the accent.
///
/// ```dart
/// SheenChatRow(
///   leading: SheenPresenceAvatar(name: 'danil', presence: SheenPresence.online),
///   title: 'danil',
///   subtitle: 'Shared “Habibi”',
///   time: '9:38',
///   unread: 2,
///   onTap: () => openChat(chat),
/// )
/// ```
///
/// {@category Social}
class SheenChatRow extends StatelessWidget {
  /// A row for the chat called [title].
  const SheenChatRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.time,
    this.unread = 0,
    this.onTap,
    this.onLongPress,
  });

  /// An avatar or an avatar stack.
  final Widget leading;

  /// The person's or the group's name.
  final String title;

  /// The last message, in one line.
  final String? subtitle;

  /// When the last message came.
  final String? time;

  /// Unread messages; none shows no count.
  final int unread;

  /// Opens the chat.
  final VoidCallback? onTap;

  /// Opens the chat's menu.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6);
    return SheenPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: .985,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SheenSpace.l, vertical: SheenSpace.s),
        child: Row(
          children: [
            leading,
            const SizedBox(width: SheenSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: scaler,
                    textDirection: sheenTextDirectionOf(title),
                    style: t.type.headline.copyWith(color: t.colors.text),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: scaler,
                      textDirection: sheenTextDirectionOf(subtitle!),
                      style: t.type.subhead.copyWith(
                        color: unread > 0 ? t.colors.text : t.colors.textSecondary,
                        fontWeight: unread > 0 ? FontWeight.w500 : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: SheenSpace.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (time != null)
                  Text(
                    time!,
                    textScaler: scaler,
                    style: t.type.footnote.copyWith(
                      color: t.colors.textTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                if (unread > 0) ...[const SizedBox(height: 6), SheenUnreadCount(count: unread)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A count in an accent pill, for unread messages.
///
/// {@category Social}
class SheenUnreadCount extends StatelessWidget {
  /// A pill showing [count] (up to [max], then "max+").
  const SheenUnreadCount({super.key, required this.count, this.max = 99});

  /// The number.
  final int count;

  /// The largest number shown as it is.
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final t = context.sheen;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: t.colors.accent, shape: const StadiumBorder()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: MediaQuery.withNoTextScaling(
              child: Text(
                count > max ? '$max+' : '$count',
                style: t.type.caption.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: t.colors.onAccent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A request from someone new: their avatar, a line about them, and Accept / Decline.
///
/// {@category Social}
class SheenRequestCard extends StatelessWidget {
  /// A request from [name].
  const SheenRequestCard({super.key, required this.name, this.message, this.onAccept, this.onDecline});

  /// Who asks.
  final String name;

  /// What they ask, under the name ("wants to be friends").
  final String? message;

  /// Accepts.
  final VoidCallback? onAccept;

  /// Declines.
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: t.colors.surfaceMuted, borderRadius: BorderRadius.circular(SheenRadius.group)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: SheenSpace.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheenAvatar(name: name, size: 44),
            const SizedBox(width: SheenSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.type.headline.copyWith(color: t.colors.text),
                  ),
                  if (message != null) Text(message!, style: t.type.subhead.copyWith(color: t.colors.textSecondary)),
                  const SizedBox(height: SheenSpace.s),
                  Wrap(
                    spacing: SheenSpace.s,
                    runSpacing: SheenSpace.s,
                    children: [
                      if (onAccept != null) _Pill(label: s.accept, onTap: onAccept!, primary: true),
                      if (onDecline != null) _Pill(label: s.decline, onTap: onDecline!, primary: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap, required this.primary});

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: primary ? t.colors.accent : t.colors.surface, shape: const StadiumBorder()),
        child: Text(
          label,
          style: t.type.subhead.copyWith(
            fontWeight: FontWeight.w600,
            color: primary ? t.colors.onAccent : t.colors.text,
          ),
        ),
      ),
    );
  }
}

/// One friend in a [SheenPresenceStrip].
///
/// {@category Social}
@immutable
class SheenPresenceItem {
  /// [name] listening to [song].
  const SheenPresenceItem({required this.name, this.song, this.image, this.onTap});

  /// The friend's name.
  final String name;

  /// What they listen to, in one or two lines.
  final String? song;

  /// Their picture.
  final ImageProvider? image;

  /// Opens their chat.
  final VoidCallback? onTap;
}

/// The friends listening now, in a row that scrolls sideways: avatar with playing bars, name, song.
///
/// {@category Social}
class SheenPresenceStrip extends StatelessWidget {
  /// A strip of [items].
  const SheenPresenceStrip({super.key, required this.items});

  /// The friends.
  final List<SheenPresenceItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SheenSpace.l),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: SheenSpace.l),
        itemBuilder: (context, i) {
          final it = items[i];
          return SheenPressable(
            onTap: it.onTap,
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  SheenPresenceAvatar(name: it.name, image: it.image, size: 58, presence: SheenPresence.playing),
                  const SizedBox(height: 6),
                  Text(
                    it.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.type.footnote.copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
                  ),
                  if (it.song != null)
                    Text(
                      it.song!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: t.type.caption.copyWith(color: t.colors.textTertiary),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
