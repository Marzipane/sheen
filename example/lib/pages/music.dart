import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

/// A cover painted in the app (the gallery ships no photos): two soft blobs on a gradient, from [seed].
Future<ImageProvider> paintedCover(int seed) async {
  const palettes = [
    [Color(0xFFB3121F), Color(0xFFE2452B), Color(0xFFFFB03A)],
    [Color(0xFF14275E), Color(0xFF2A4FB5), Color(0xFF9CC3FF)],
    [Color(0xFF14110C), Color(0xFF6F6046), Color(0xFFC9B48A)],
    [Color(0xFF0E6E5C), Color(0xFF21C08B), Color(0xFFE6FFF4)],
    [Color(0xFF3A1F5C), Color(0xFF8E4EC6), Color(0xFFF2B5FF)],
    [Color(0xFF7A3E2B), Color(0xFFD9895B), Color(0xFFF6D6A8)],
  ];
  final p = palettes[seed % palettes.length];
  const size = 240.0;
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  c.drawRect(
    const Rect.fromLTWH(0, 0, size, size),
    Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(size, size), [p[0], p[1]]),
  );
  final r = math.Random(seed);
  for (var i = 0; i < 2; i++) {
    c.drawCircle(
      Offset(r.nextDouble() * size, r.nextDouble() * size),
      40 + r.nextDouble() * 50,
      Paint()
        ..color = p[2].withValues(alpha: .85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }
  final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(bytes!.buffer.asUint8List());
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<ImageProvider?> _covers = List.filled(6, null);
  bool _playing = true;
  bool _shuffle = false;
  SheenRepeatMode _repeat = SheenRepeatMode.off;
  Duration _pos = const Duration(seconds: 90);
  final _queue = ['Silhouette', 'BENZIN', 'AAutro', 'Mama Makusa', 'DRUNK'];
  SheenTrackSave _save = SheenTrackSave.available;
  double _progress = 0;
  final _bands = [6.0, 1.0, -2.0];

  static const _lyrics = [
    SheenLyricsLine(Duration(seconds: 80), 'The night came down again'),
    SheenLyricsLine(Duration(seconds: 86), 'Two of us against the city'),
    SheenLyricsLine(Duration(seconds: 92), 'A silhouette across the street'),
    SheenLyricsLine(Duration(seconds: 98), 'Fading like the lights at dawn'),
    SheenLyricsLine(Duration(seconds: 104), "Don't hold me, let me go"),
  ];

  @override
  void initState() {
    super.initState();
    Future.wait([for (var i = 0; i < 6; i++) paintedCover(i)]).then((c) {
      if (mounted) setState(() => _covers = c);
    });
  }

  Future<void> _saveSong() async {
    if (_save == SheenTrackSave.saved) return setState(() => _save = SheenTrackSave.available);
    setState(() {
      _save = SheenTrackSave.saving;
      _progress = 0;
    });
    for (var i = 1; i <= 10 && mounted; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted) setState(() => _progress = i / 10);
    }
    if (mounted) setState(() => _save = SheenTrackSave.saved);
  }

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Music',
    children: [
      Demo(
        title: 'Now playing',
        note: 'SheenArtworkGlow behind the glass; SheenSeekBar and SheenTransportControls.',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SheenRadius.card),
          child: SizedBox(
            height: 470,
            child: SheenArtworkGlow(
              image: _covers[0],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SheenArtwork(image: _covers[0], size: 220, radius: 18),
                    const SizedBox(height: 18),
                    Text('98 Flow', style: context.sheen.type.title),
                    Text('Big Baby Tape', style: context.sheen.type.subhead.copyWith(color: context.sheen.colors.textSecondary)),
                    const SizedBox(height: 8),
                    SheenSeekBar(
                      position: _pos,
                      duration: const Duration(seconds: 237),
                      buffered: const Duration(seconds: 160),
                      onSeek: (d) => setState(() => _pos = d),
                      onSeekEnd: (d) => setState(() => _pos = d),
                    ),
                    SheenTransportControls(
                      playing: _playing,
                      onPlayPause: () => setState(() => _playing = !_playing),
                      onNext: () {},
                      onPrevious: () {},
                      shuffle: _shuffle,
                      onShuffle: () => setState(() => _shuffle = !_shuffle),
                      repeat: _repeat,
                      onRepeat: () => setState(() => _repeat = SheenRepeatMode.values[(_repeat.index + 1) % 3]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Demo(
        title: 'Mini player',
        note: 'Tap to open; swipe sideways for the next song; drag up to open.',
        child: SheenMiniPlayer(
          title: 'BRATAN',
          subtitle: 'Big Baby Tape',
          artwork: _covers[2],
          playing: _playing,
          progress: .38,
          onPlayPause: () => setState(() => _playing = !_playing),
          onNext: () {},
          onOpen: () {},
        ),
      ),
      Demo(
        title: 'Song rows',
        note: 'Save, saving and saved; the current song with the playing bars.',
        child: Column(
          children: [
            SheenTrackRow(title: '98 Flow (feat. Khaski)', subtitle: 'Big Baby Tape', meta: '4.1M plays', artwork: _covers[0], current: true, playing: _playing, onDevice: true, save: SheenTrackSave.saved, onSave: () {}, onMore: () {}, onTap: () {}),
            SheenTrackRow(title: 'BENZIN', subtitle: 'Big Baby Tape, Молодой Платон', meta: '12M plays', artwork: _covers[5], save: _save, saveProgress: _progress, onSave: _saveSong, onMore: () {}, onTap: () {}),
            SheenTrackRow(title: 'AAutro', subtitle: 'Big Baby Tape, Aarne', meta: '3:02', artwork: _covers[1], dimmed: true, onMore: () {}),
          ],
        ),
      ),
      Demo(
        title: 'Shelf',
        child: SheenShelf(
          title: 'Recently played',
          actionLabel: 'See all',
          onAction: () {},
          padding: EdgeInsets.zero,
          children: [
            for (final (i, (t, s)) in [('98 Flow', 'Big Baby Tape'), ('Silhouette', 'Miyagi'), ('BRATAN', 'Big Baby Tape'), ('Mix', 'For you')].indexed)
              SheenArtworkTile(title: t, subtitle: s, artwork: _covers[i], size: 128, onTap: () {}),
            SheenArtworkTile(title: 'Big Baby Tape', subtitle: 'Artist', artwork: _covers[4], size: 128, round: true, onTap: () {}),
          ],
        ),
      ),
      Demo(
        title: 'Up next',
        note: 'Drag the handle to reorder; swipe to remove.',
        child: SheenReorderList<String>(
          items: _queue,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          keyOf: ValueKey.new,
          onReorder: (a, b) => setState(() => _queue.insert(b, _queue.removeAt(a))),
          onRemove: (i) => setState(() => _queue.removeAt(i)),
          itemBuilder: (context, s, i, handle) => SheenTrackRow(title: s, subtitle: 'Big Baby Tape', artwork: _covers[i % 6], trailing: handle),
        ),
      ),
      Demo(
        title: 'Lyrics',
        note: 'Tap a line to jump there.',
        child: SizedBox(
          height: 260,
          child: SheenLyricsView(lines: _lyrics, position: _pos, onSeek: (d) => setState(() => _pos = d)),
        ),
      ),
      Demo(
        title: 'Equaliser',
        child: SizedBox(
          height: 220,
          child: Row(
            children: [
              for (final (i, name) in ['Bass', 'Mid', 'Treble'].indexed)
                Expanded(child: SheenBandSlider(label: name, value: _bands[i], onChanged: (v) => setState(() => _bands[i] = v))),
            ],
          ),
        ),
      ),
    ],
  );
}
