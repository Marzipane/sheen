import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'artwork.dart';
import 'strings.dart';

/// The glass bar above the tab bar that shows what plays: the cover, title and artist, play/pause and next, and a thin
/// progress line along its foot.
///
/// A tap or an upward drag opens the full player; a sideways swipe goes to the next or previous song (in right-to-left
/// text, the other way round). Give the cover a [heroTag] to fly it into the player's cover.
///
/// ```dart
/// SheenMiniPlayer(
///   title: track.title,
///   subtitle: track.artist,
///   artwork: NetworkImage(track.thumb),
///   playing: state.playing,
///   progress: state.progress,
///   onPlayPause: player.toggle,
///   onNext: player.next,
///   onSwipeNext: player.next,
///   onSwipePrevious: player.previous,
///   onOpen: () => openPlayer(context),
/// )
/// ```
///
/// {@category Music}
class SheenMiniPlayer extends StatelessWidget {
  /// A mini player for [title].
  const SheenMiniPlayer({
    super.key,
    required this.title,
    this.subtitle,
    this.artwork,
    this.playing = false,
    this.progress = 0,
    this.onPlayPause,
    this.onNext,
    this.onOpen,
    this.onSwipeNext,
    this.onSwipePrevious,
    this.heroTag,
  });

  /// The song's title.
  final String title;

  /// The artist.
  final String? subtitle;

  /// The cover.
  final ImageProvider? artwork;

  /// Whether music plays.
  final bool playing;

  /// How far the song is, from 0 to 1.
  final double progress;

  /// Play or pause.
  final VoidCallback? onPlayPause;

  /// Next song.
  final VoidCallback? onNext;

  /// Opens the full player.
  final VoidCallback? onOpen;

  /// A swipe towards the start (left in left-to-right text).
  final VoidCallback? onSwipeNext;

  /// A swipe towards the end.
  final VoidCallback? onSwipePrevious;

  /// A hero tag for the cover.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    Widget art = SheenArtwork(image: artwork, size: 44, radius: 10);
    if (heroTag != null) art = Hero(tag: heroTag!, child: art);

    Widget button(String icon, String label, VoidCallback? onTap) => SheenPressable(
      semanticLabel: label,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      child: SizedBox.square(
        dimension: SheenSpace.hit,
        child: Center(child: SheenIcon(icon, size: 24, filled: true, color: t.colors.text)),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        final towardStart = rtl ? v > 0 : v < 0;
        HapticFeedback.selectionClick();
        (towardStart ? onSwipeNext : onSwipePrevious)?.call();
      },
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -200) onOpen?.call();
      },
      child: SheenGlass(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SheenPressable(
                      semanticLabel: s.openPlayer,
                      onTap: onOpen,
                      pressedScale: .99,
                      child: Row(
                        children: [
                          art,
                          const SizedBox(width: SheenSpace.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  textDirection: sheenTextDirectionOf(title),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textScaler: scaler,
                                  style: t.type.headline.copyWith(color: t.colors.text, fontSize: 15),
                                ),
                                if (subtitle != null)
                                  Text(
                                    subtitle!,
                                    textDirection: sheenTextDirectionOf(subtitle!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaler: scaler,
                                    style: t.type.footnote.copyWith(color: t.colors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  button(playing ? SheenIcons.pauseFill : SheenIcons.playFill, playing ? s.pause : s.play, onPlayPause),
                  button(SheenIcons.nextFill, s.next, onNext),
                ],
              ),
            ),
            PositionedDirectional(
              start: 18,
              end: 18,
              bottom: 3,
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: t.colors.separator),
                        FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: ColoredBox(color: t.colors.text.withValues(alpha: .8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
