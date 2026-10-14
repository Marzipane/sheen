import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'artwork.dart';
import 'playing_bars.dart';
import 'strings.dart';

/// Whether a song can be stored on the device, is being stored, or is stored.
///
/// {@category Music}
enum SheenTrackSave {
  /// No save button.
  none,

  /// A download button.
  available,

  /// A ring that fills as the song is stored.
  saving,

  /// The on-device mark; tapping it calls `onSave` (for example to remove it).
  saved,
}

/// One song in a list: its cover, title, artist and a short fact ("4.1M plays", "3:56"), with a save button and a
/// menu button at the end.
///
/// The current song shows its title in the accent and, while [playing], small moving bars. A long press opens the
/// menu, as on iOS. Titles keep one line and end in an ellipsis at any text size.
///
/// ```dart
/// SheenTrackRow(
///   title: track.title,
///   subtitle: track.artist,
///   meta: track.plays,
///   artwork: NetworkImage(track.thumb),
///   current: track.id == player.currentId,
///   playing: player.playing,
///   onDevice: store.has(track.id),
///   save: store.saveStateOf(track.id),
///   saveProgress: store.progressOf(track.id),
///   onTap: () => player.playList(tracks, index),
///   onSave: () => store.toggle(track),
///   onMore: () => showTrackMenu(context, track),
/// )
/// ```
///
/// {@category Music}
class SheenTrackRow extends StatelessWidget {
  /// A row for the song called [title].
  const SheenTrackRow({
    super.key,
    required this.title,
    this.subtitle,
    this.meta,
    this.artwork,
    this.leading,
    this.current = false,
    this.playing = false,
    this.onDevice = false,
    this.dimmed = false,
    this.save = SheenTrackSave.none,
    this.saveProgress,
    this.onTap,
    this.onSave,
    this.onMore,
    this.trailing,
  });

  /// The song's title.
  final String title;

  /// The artist (or album).
  final String? subtitle;

  /// A short fact after the subtitle.
  final String? meta;

  /// The cover; a placeholder when null.
  final ImageProvider? artwork;

  /// Replaces the cover, for example with a track number in an album.
  final Widget? leading;

  /// Whether this is the song in the player.
  final bool current;

  /// Whether the player plays (the bars move on the [current] row).
  final bool playing;

  /// Shows the on-device mark before the subtitle (unless the save button already shows it).
  final bool onDevice;

  /// Draws the row faded, for songs that cannot play now (offline).
  final bool dimmed;

  /// The save button's state.
  final SheenTrackSave save;

  /// How much of the song is stored while [save] is [SheenTrackSave.saving], from 0 to 1.
  final double? saveProgress;

  /// Plays the song.
  final VoidCallback? onTap;

  /// Saves the song, or (when saved) asks to remove it.
  final VoidCallback? onSave;

  /// Opens the song's menu; also on a long press.
  final VoidCallback? onMore;

  /// Replaces the save and menu buttons, for example with a drag handle.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6);
    final second = [?subtitle, ?meta].join(' · ');
    Widget button(String icon, String label, VoidCallback? onTap, {Color? color}) => SheenPressable(
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox.square(dimension: SheenSpace.hit, child: Center(child: SheenIcon(icon, size: 20, color: color ?? t.colors.textSecondary))),
    );

    final saveButton = switch (save) {
      SheenTrackSave.none => null,
      SheenTrackSave.available => button(SheenIcons.download, s.save, onSave),
      SheenTrackSave.saving => SheenPressable(
        semanticLabel: s.saving,
        onTap: onSave,
        child: SizedBox.square(
          dimension: SheenSpace.hit,
          child: Center(child: SheenProgressRing(value: saveProgress, size: 20, stroke: 2.5)),
        ),
      ),
      SheenTrackSave.saved => button(SheenIcons.onDevice, s.saved, onSave, color: t.colors.success),
    };

    final row = Row(
      children: [
        leading ?? SheenArtwork(image: artwork, size: 48, radius: 8),
        const SizedBox(width: SheenSpace.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, textDirection: sheenTextDirectionOf(title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: scaler,
                style: t.type.body.copyWith(color: current ? t.colors.accentText : t.colors.text),
              ),
              if (second.isNotEmpty || (onDevice && save != SheenTrackSave.saved))
                Row(
                  children: [
                    if (onDevice && save != SheenTrackSave.saved) ...[
                      SheenIcon(SheenIcons.onDevice, size: 13, color: t.colors.success, semanticLabel: s.saved),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(second, textDirection: sheenTextDirectionOf(second),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: scaler,
                        style: t.type.subhead.copyWith(color: t.colors.textSecondary),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (current) ...[const SizedBox(width: SheenSpace.s), SheenPlayingBars(playing: playing)],
        if (trailing != null)
          trailing!
        else ...[
          ?saveButton,
          if (onMore != null) button(SheenIcons.more, s.more, onMore),
        ],
      ],
    );

    return Opacity(
      opacity: dimmed ? .4 : 1,
      child: SheenPressable(
        onTap: onTap,
        onLongPress: onMore,
        pressedScale: .985,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: SheenSpace.l, end: SheenSpace.xs, top: 6, bottom: 6),
          child: row,
        ),
      ),
    );
  }
}
