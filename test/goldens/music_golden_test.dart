import 'package:flutter/widgets.dart';
import 'package:sheen/music.dart';

import 'variants.dart';

void main() {
  familyGoldens('music', [
    (
      'SheenSeekBar · SheenTransportControls',
      () => overPhoto(
        SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheenSeekBar(
                position: const Duration(seconds: 90),
                duration: const Duration(seconds: 237),
                buffered: const Duration(seconds: 160),
                onSeekEnd: (_) {},
              ),
              SheenTransportControls(
                playing: true,
                onPlayPause: () {},
                onNext: () {},
                onPrevious: () {},
                shuffle: true,
                onShuffle: () {},
                repeat: SheenRepeatMode.one,
                onRepeat: () {},
              ),
            ],
          ),
        ),
      ),
    ),
    (
      'SheenMiniPlayer',
      () => overPhoto(
        SizedBox(
          width: 360,
          child: SheenMiniPlayer(
            title: 'BRATAN',
            subtitle: 'Big Baby Tape',
            playing: true,
            progress: .38,
            onPlayPause: () {},
            onNext: () {},
            onOpen: () {},
          ),
        ),
      ),
    ),
    (
      'SheenTrackRow',
      () => SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenTrackRow(
              title: '98 Flow (feat. Khaski)',
              subtitle: 'Big Baby Tape',
              meta: '4.1M plays',
              current: true,
              playing: false,
              save: SheenTrackSave.saved,
              onSave: () {},
              onMore: () {},
            ),
            SheenTrackRow(
              title: 'BENZIN',
              subtitle: 'Big Baby Tape, Молодой Платон',
              meta: '12M plays',
              save: SheenTrackSave.saving,
              saveProgress: .6,
              onSave: () {},
              onMore: () {},
            ),
            SheenTrackRow(
              title: 'AAutro',
              subtitle: 'Big Baby Tape, Aarne',
              meta: '3:02',
              onDevice: true,
              save: SheenTrackSave.available,
              onSave: () {},
              onMore: () {},
            ),
            const SheenTrackRow(title: 'Mama Makusa', subtitle: 'Needs internet', dimmed: true),
          ],
        ),
      ),
    ),
    (
      'SheenShelf · SheenArtworkTile',
      () => SizedBox(
        width: 380,
        child: SheenShelf(
          title: 'Recently played',
          actionLabel: 'See all',
          onAction: () {},
          children: [
            SheenArtworkTile(title: '98 Flow', subtitle: 'Big Baby Tape', size: 110, onTap: () {}),
            SheenArtworkTile(title: 'Silhouette', subtitle: 'Miyagi', size: 110, onTap: () {}),
            SheenArtworkTile(title: 'Big Baby Tape', subtitle: 'Artist', size: 110, round: true, onTap: () {}),
          ],
        ),
      ),
    ),
    (
      'SheenLyricsView',
      () => const SizedBox(
        width: 340,
        height: 260,
        child: SheenLyricsView(
          position: Duration(seconds: 87),
          lines: [
            SheenLyricsLine(Duration(seconds: 80), 'The night came down again'),
            SheenLyricsLine(Duration(seconds: 86), 'Two of us against the city'),
            SheenLyricsLine(Duration(seconds: 92), 'A silhouette across the street'),
          ],
        ),
      ),
    ),
    (
      'SheenBandSlider · SheenPlayingBars',
      () => SizedBox(
        width: 300,
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: SheenBandSlider(label: 'Bass', value: 6, onChanged: (_) {}),
            ),
            Expanded(
              child: SheenBandSlider(label: 'Mid', value: 0, onChanged: (_) {}),
            ),
            Expanded(
              child: SheenBandSlider(label: 'Treble', value: -4, onChanged: (_) {}),
            ),
            const SheenPlayingBars(playing: false, size: 20),
          ],
        ),
      ),
    ),
  ]);
}
