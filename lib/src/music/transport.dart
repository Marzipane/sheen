import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// What repeats.
///
/// {@category Music}
enum SheenRepeatMode {
  /// Nothing repeats; the queue stops (or a radio continues it).
  off,

  /// The whole queue repeats.
  all,

  /// The current song repeats.
  one,
}

/// The row of a player's controls: shuffle, previous, play/pause on a large glass circle, next and repeat.
///
/// Shuffle and repeat turn the accent colour when on; repeat shows a "1" when one song repeats. The play glyph cross-
/// fades into pause. Media controls keep their direction in right-to-left text, as Apple's guidelines ask.
///
/// ```dart
/// SheenTransportControls(
///   playing: state.playing,
///   onPlayPause: player.toggle,
///   onNext: player.next,
///   onPrevious: player.previous,
///   shuffle: state.shuffle,
///   onShuffle: player.toggleShuffle,
///   repeat: state.repeat,
///   onRepeat: player.cycleRepeat,
/// )
/// ```
///
/// {@category Music}
class SheenTransportControls extends StatelessWidget {
  /// Controls for a player that is [playing] or paused.
  const SheenTransportControls({
    super.key,
    required this.playing,
    this.loading = false,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.shuffle = false,
    this.onShuffle,
    this.repeat = SheenRepeatMode.off,
    this.onRepeat,
    this.color,
  });

  /// Whether music plays (the big button shows pause).
  final bool playing;

  /// Whether the song is still loading: a spinner fills the play button (a tap still pauses).
  final bool loading;

  /// Play or pause.
  final VoidCallback? onPlayPause;

  /// Next song.
  final VoidCallback? onNext;

  /// Previous song (or back to the start of this one).
  final VoidCallback? onPrevious;

  /// Whether shuffle is on.
  final bool shuffle;

  /// Toggle shuffle; the button is hidden when null.
  final VoidCallback? onShuffle;

  /// What repeats.
  final SheenRepeatMode repeat;

  /// Move to the next repeat mode; the button is hidden when null.
  final VoidCallback? onRepeat;

  /// The glyph colour; the theme's text colour by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    final ink = color ?? t.colors.text;
    Widget small(String icon, String label, VoidCallback? onTap, {bool on = false}) => _Tap(
      label: label,
      onTap: onTap,
      size: SheenSpace.hit,
      child: SheenIcon(icon, size: 22, color: on ? t.colors.accentText : ink.withValues(alpha: .75)),
    );
    Widget skip(String icon, String label, VoidCallback? onTap) => _Tap(
      label: label,
      onTap: onTap,
      size: 56,
      child: SheenIcon(icon, size: 30, color: ink, filled: true),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onShuffle != null)
            small(SheenIcons.shuffle, shuffle ? s.shuffleOn : s.shuffleOff, onShuffle, on: shuffle),
          skip(SheenIcons.previousFill, s.previous, onPrevious),
          _Tap(
            label: playing ? s.pause : s.play,
            onTap: onPlayPause,
            size: 76,
            child: SheenGlass(
              shape: const CircleBorder(),
              child: SizedBox.square(
                dimension: 76,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: SheenMotion.reduced(context) ? Duration.zero : SheenMotion.fadeIn,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(scale: Tween(begin: .7, end: 1.0).animate(a), child: child),
                    ),
                    child: loading
                        ? SheenSpinner(key: const ValueKey('loading'), size: 30, color: ink, stroke: 3)
                        : SheenIcon(
                            playing ? SheenIcons.pauseFill : SheenIcons.playFill,
                            key: ValueKey(playing),
                            size: 34,
                            color: ink,
                            filled: true,
                          ),
                  ),
                ),
              ),
            ),
          ),
          skip(SheenIcons.nextFill, s.next, onNext),
          if (onRepeat != null)
            small(
              repeat == SheenRepeatMode.one ? SheenIcons.repeatOne : SheenIcons.repeat,
              switch (repeat) {
                SheenRepeatMode.off => s.repeatOff,
                SheenRepeatMode.all => s.repeatAll,
                SheenRepeatMode.one => s.repeatOne,
              },
              onRepeat,
              on: repeat != SheenRepeatMode.off,
            ),
        ],
      ),
    );
  }
}

class _Tap extends StatelessWidget {
  const _Tap({required this.label, required this.onTap, required this.size, required this.child});

  final String label;
  final VoidCallback? onTap;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) => SheenPressable(
    semanticLabel: label,
    minSize: size,
    onTap: onTap == null
        ? null
        : () {
            HapticFeedback.lightImpact();
            onTap!();
          },
    child: SizedBox.square(
      dimension: size,
      child: Center(child: child),
    ),
  );
}
