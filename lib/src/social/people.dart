import 'package:flutter/widgets.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// What a person is doing, as their avatar shows it.
///
/// {@category Social}
enum SheenPresence {
  /// Nothing shown.
  none,

  /// A green dot.
  online,

  /// A badge in the accent with moving playing bars.
  playing,
}

/// A [SheenAvatar] with the person's [presence]: a green dot when online, playing bars while they listen.
///
/// ```dart
/// SheenPresenceAvatar(name: friend.username, presence: friend.listening ? SheenPresence.playing : SheenPresence.none)
/// ```
///
/// {@category Social}
class SheenPresenceAvatar extends StatelessWidget {
  /// An avatar for [name], [size] points across.
  const SheenPresenceAvatar({super.key, this.name, this.image, this.size = 44, this.presence = SheenPresence.none});

  /// The person's name.
  final String? name;

  /// Their picture.
  final ImageProvider? image;

  /// The diameter.
  final double size;

  /// What the mark shows.
  final SheenPresence presence;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    final avatar = SheenAvatar(name: name, image: image, size: size);
    if (presence == SheenPresence.none) return avatar;
    final ring = Border.all(color: t.colors.background, width: 2.5);
    final mark = presence == SheenPresence.online
        ? Semantics(
            label: s.online,
            child: Container(
              width: (size * .3).clamp(10, 16),
              height: (size * .3).clamp(10, 16),
              decoration: BoxDecoration(color: t.colors.success, shape: BoxShape.circle, border: ring),
            ),
          )
        : Semantics(
            label: s.listening,
            child: Container(
              width: (size * .42).clamp(18, 26),
              height: (size * .42).clamp(18, 26),
              decoration: BoxDecoration(color: t.colors.accent, shape: BoxShape.circle, border: ring),
              alignment: Alignment.center,
              child: SheenPlayingBars(size: 9, color: t.colors.onAccent, semanticLabel: ''),
            ),
          );
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          PositionedDirectional(
            end: presence == SheenPresence.playing ? -3 : -1,
            bottom: presence == SheenPresence.playing ? -3 : -1,
            child: mark,
          ),
        ],
      ),
    );
  }
}

/// Two to four avatars overlapping, for a group chat or the people listening together.
///
/// {@category Social}
class SheenAvatarStack extends StatelessWidget {
  /// Avatars for [names] (the first [max] of them).
  const SheenAvatarStack({super.key, required this.names, this.size = 28, this.max = 3});

  /// The people's names.
  final List<String> names;

  /// Each avatar's diameter.
  final double size;

  /// How many avatars at most.
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final step = size * .68;
    return Semantics(
      label: names.join(', '),
      excludeSemantics: true,
      child: SizedBox(
        width: shown.isEmpty ? 0 : size + step * (shown.length - 1),
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              PositionedDirectional(
                start: step * i,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.sheen.colors.background, width: 2),
                  ),
                  child: SheenAvatar(name: shown[i], size: size),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
