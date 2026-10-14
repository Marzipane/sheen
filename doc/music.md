# Music

`import 'package:sheen/music.dart';`

The parts of a music player: the cover and its glow behind the glass, a mini player above the tab bar, a seek bar,
transport controls, song rows with a save button, shelves of covers, synced lyrics, a queue to reorder and equaliser
bands. Titles and words are always yours; `SheenMusicScope` translates the few labels the widgets announce.

![Music](https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/12-music.webp)

## The player

`SheenArtworkGlow` blurs the cover into the page behind its child, so the glass above takes the song's colours; with
Reduce Transparency it is a flat tint. `SheenSeekBar` previews while the finger moves and reports once on release
(`onSeekEnd`), which is when to tell the player. `SheenTransportControls` puts play/pause on a large glass circle;
shuffle and repeat turn the accent colour when on.

```dart
SheenArtworkGlow(
  image: NetworkImage(track.cover),
  child: Column(children: [
    SheenArtwork(image: NetworkImage(track.cover), size: 300, radius: 20),
    SheenSeekBar(position: state.position, duration: state.duration, onSeekEnd: player.seek),
    SheenTransportControls(
      playing: state.playing,
      onPlayPause: player.toggle,
      onNext: player.next,
      onPrevious: player.previous,
      shuffle: state.shuffle,
      onShuffle: player.toggleShuffle,
      repeat: state.repeat,
      onRepeat: player.cycleRepeat,
    ),
  ]),
);
```

Media controls keep their direction in right-to-left text, as Apple's guidelines ask; times stay left to right.

## Mini player

`SheenMiniPlayer` sits above `SheenTabBar`. A tap or an upward drag opens the player; a sideways swipe changes the song.
Give the cover a `heroTag` to fly it into the player.

## Songs and shelves

`SheenTrackRow` shows a song with its save state (`SheenTrackSave.available`, `saving` with a ring, `saved`) and a menu
button; a long press opens the menu too. The current song shows its title in the accent and `SheenPlayingBars`.
`SheenShelf` holds `SheenArtworkTile`s that scroll sideways; artists are `round`.

```dart
SheenTrackRow(
  title: track.title,
  subtitle: track.artist,
  meta: track.plays,
  artwork: NetworkImage(track.thumb),
  current: track.id == state.currentId,
  playing: state.playing,
  save: store.saveStateOf(track.id),
  saveProgress: store.progressOf(track.id),
  onTap: () => player.play(tracks, index),
  onSave: () => store.toggle(track),
  onMore: () => openMenu(track),
);
```

## Lyrics, queue and equaliser

`SheenLyricsView` scrolls synced lines by itself and stops following for a few seconds after the user scrolls; a tap
on a line seeks there. `SheenReorderList` gives each row a drag handle and removes a row on a swipe; `onReorder` gets
the old and the new index. `SheenBandSlider` is one equaliser band in dB with its centre at 0.

## Words

```dart
SheenMusicScope(
  strings: const SheenMusicStrings(play: 'Lecture', pause: 'Pause', next: 'Suivant'),
  child: app,
)
```
