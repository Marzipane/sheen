import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  group('SheenMusicStrings', () {
    testWidgets('English defaults without a scope, the scope\'s strings under one', (t) async {
      late SheenMusicStrings outside, inside;
      await t.pumpWidget(
        host(
          Column(
            children: [
              Builder(builder: (c) => (outside = SheenMusicStrings.of(c), const SizedBox()).$2),
              SheenMusicScope(
                strings: const SheenMusicStrings(play: 'Lecture'),
                child: Builder(builder: (c) => (inside = SheenMusicStrings.of(c), const SizedBox()).$2),
              ),
            ],
          ),
        ),
      );
      expect(outside.play, 'Play');
      expect(outside.pause, 'Pause');
      expect(inside.play, 'Lecture');
      expect(inside.pause, 'Pause');
    });
  });

  group('SheenPlayingBars', () {
    testWidgets('moves while playing', (t) async {
      await t.pumpWidget(host(const SheenPlayingBars()));
      final before = t.getSize(find.byKey(const ValueKey('sheen-bar-0'))).height;
      await t.pump(const Duration(milliseconds: 300));
      final after = t.getSize(find.byKey(const ValueKey('sheen-bar-0'))).height;
      expect(after, isNot(before));
      expect(t.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('stands still when paused and under Reduce Motion', (t) async {
      double h() => t.getSize(find.byKey(const ValueKey('sheen-bar-0'))).height;
      for (final (widget, reduce) in [
        (const SheenPlayingBars(playing: false), false),
        (const SheenPlayingBars(), true),
      ]) {
        await t.pumpWidget(host(widget, reduceMotion: reduce));
        await t.pump();
        final before = h();
        await t.pump(const Duration(milliseconds: 300));
        expect(h(), before);
      }
    });

    testWidgets('tells a screen reader it is playing', (t) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(host(const SheenPlayingBars()));
      expect(find.bySemanticsLabel('Now playing'), findsOneWidget);
      h.dispose();
    });
  });

  group('SheenArtwork', () {
    testWidgets('shows the music glyph without an image', (t) async {
      await t.pumpWidget(host(const SheenArtwork(size: 48)));
      expect(t.getSize(find.byType(SheenArtwork)), const Size(48, 48));
      expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.music), findsOneWidget);
    });

    testWidgets('falls back to the glyph when the image fails', (t) async {
      await t.pumpWidget(host(SheenArtwork(size: 48, image: MemoryImage(Uint8List.fromList([1, 2, 3])))));
      await t.pumpAndSettle();
      expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.music), findsOneWidget);
    });

    testWidgets('clips to its radius', (t) async {
      await t.pumpWidget(host(const SheenArtwork(size: 48, radius: 12)));
      final clip = t.widget<ClipRRect>(
        find.descendant(of: find.byType(SheenArtwork), matching: find.byType(ClipRRect)),
      );
      expect(clip.borderRadius, BorderRadius.circular(12));
    });
  });
}
