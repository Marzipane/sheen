import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The words the music widgets show or announce when you give them none.
///
/// The defaults are English. Translate them once with a [SheenMusicScope] above your app:
///
/// ```dart
/// SheenMusicScope(
///   strings: const SheenMusicStrings(play: 'Lecture', pause: 'Pause'),
///   child: app,
/// )
/// ```
///
/// {@category Music}
@immutable
class SheenMusicStrings with Diagnosticable {
  /// Strings with English defaults; pass the ones you translate.
  const SheenMusicStrings({
    this.play = 'Play',
    this.pause = 'Pause',
    this.next = 'Next',
    this.previous = 'Previous',
    this.shuffleOn = 'Shuffle: on',
    this.shuffleOff = 'Shuffle: off',
    this.repeatOff = 'Repeat: off',
    this.repeatAll = 'Repeat: all',
    this.repeatOne = 'Repeat: this song',
    this.nowPlaying = 'Now playing',
    this.save = 'Save to this phone',
    this.saving = 'Saving to this phone',
    this.saved = 'On this phone',
    this.more = 'More',
    this.remove = 'Remove',
    this.openPlayer = 'Open player',
    this.position = 'Position',
    this.reorder = 'Drag to reorder',
  });

  /// Play button.
  final String play;

  /// Pause button.
  final String pause;

  /// Next song.
  final String next;

  /// Previous song.
  final String previous;

  /// The shuffle button while shuffle is on.
  final String shuffleOn;

  /// The shuffle button while shuffle is off.
  final String shuffleOff;

  /// The repeat button when nothing repeats.
  final String repeatOff;

  /// The repeat button when the list repeats.
  final String repeatAll;

  /// The repeat button when one song repeats.
  final String repeatOne;

  /// What a screen reader says for the playing bars.
  final String nowPlaying;

  /// The save button of a song that is not stored.
  final String save;

  /// The save button while the song is being stored.
  final String saving;

  /// The mark of a song stored on the device.
  final String saved;

  /// The menu button of a row.
  final String more;

  /// Removing a row.
  final String remove;

  /// Opening the full player from the mini player.
  final String openPlayer;

  /// The seek bar.
  final String position;

  /// A drag handle.
  final String reorder;

  /// The strings of the nearest [SheenMusicScope], or the English defaults.
  static SheenMusicStrings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheenMusicScope>()?.strings ?? const SheenMusicStrings();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('play', play))
      ..add(StringProperty('pause', pause));
  }
}

/// Provides [SheenMusicStrings] to the music widgets below it.
///
/// {@category Music}
class SheenMusicScope extends InheritedWidget {
  /// A scope with [strings].
  const SheenMusicScope({super.key, required this.strings, required super.child});

  /// The words music widgets use below this scope.
  final SheenMusicStrings strings;

  @override
  bool updateShouldNotify(SheenMusicScope oldWidget) => strings != oldWidget.strings;
}
