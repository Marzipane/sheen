import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Finder icon(String name) => find.byWidgetPredicate((w) => w is SheenIcon && w.name == name);

void main() {
  group('SheenTrackRow', () {
    testWidgets('tap, save and more call back; long press opens more', (t) async {
      final calls = <String>[];
      await t.pumpWidget(
        host(
          SizedBox(
            width: 380,
            child: SheenTrackRow(
              title: '98 Flow (feat. Khaski)',
              subtitle: 'Big Baby Tape',
              meta: '4.1M plays',
              save: SheenTrackSave.available,
              onTap: () => calls.add('tap'),
              onSave: () => calls.add('save'),
              onMore: () => calls.add('more'),
            ),
          ),
        ),
      );
      expect(find.text('98 Flow (feat. Khaski)'), findsOneWidget);
      expect(find.text('Big Baby Tape · 4.1M plays'), findsOneWidget);
      await t.tap(find.text('98 Flow (feat. Khaski)'));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.bySemanticsLabel('Save to this phone'));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.bySemanticsLabel('More'));
      await t.pump(const Duration(milliseconds: 400));
      await t.longPress(find.text('98 Flow (feat. Khaski)'));
      await t.pump(const Duration(milliseconds: 400));
      expect(calls, ['tap', 'save', 'more', 'more']);
    });

    testWidgets('saving shows a ring with progress; saved shows the device mark', (t) async {
      await t.pumpWidget(
        host(const SizedBox(width: 380, child: SheenTrackRow(title: 'A', save: SheenTrackSave.saving, saveProgress: .4))),
      );
      expect(find.byType(SheenProgressRing), findsOneWidget);
      await t.pumpWidget(
        host(const SizedBox(width: 380, child: SheenTrackRow(title: 'A', save: SheenTrackSave.saved, onDevice: true))),
      );
      expect(icon(SheenIcons.onDevice), findsWidgets);
      expect(find.byType(SheenProgressRing), findsNothing);
    });

    testWidgets('the current song shows its title in the accent and the playing bars', (t) async {
      await t.pumpWidget(
        host(const SizedBox(width: 380, child: SheenTrackRow(title: 'Now', current: true, playing: true))),
      );
      final text = t.widget<Text>(find.text('Now'));
      final ctx = t.element(find.byType(SheenTrackRow));
      expect(text.style!.color, ctx.sheen.colors.accentText);
      expect(find.byType(SheenPlayingBars), findsOneWidget);
    });

    testWidgets('does not overflow at 200 % text or in right to left', (t) async {
      for (final dir in TextDirection.values) {
        await t.pumpWidget(
          host(
            const SizedBox(
              width: 320,
              child: SheenTrackRow(
                title: 'A very long song title that goes on and on and on',
                subtitle: 'An artist with a long name, another artist',
                meta: '12M plays',
                save: SheenTrackSave.available,
              ),
            ),
            textScale: 2,
            direction: dir,
          ),
        );
        expect(t.takeException(), isNull);
      }
    });
  });

  group('SheenArtworkTile and SheenShelf', () {
    testWidgets('a shelf scrolls sideways and its action calls back', (t) async {
      var all = 0;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenShelf(
              title: 'Recently played',
              actionLabel: 'See all',
              onAction: () => all++,
              children: [
                for (var i = 0; i < 8; i++) SheenArtworkTile(title: 'Song $i', subtitle: 'Artist', onTap: () {}),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Recently played'), findsOneWidget);
      expect(find.text('Song 7').hitTestable(), findsNothing, reason: 'off screen until scrolled');
      await t.drag(find.byType(Scrollable).first, const Offset(-1200, 0));
      await t.pumpAndSettle();
      expect(find.text('Song 7').hitTestable(), findsOneWidget);
      await t.tap(find.text('See all'));
      await t.pump(const Duration(milliseconds: 400));
      expect(all, 1);
    });

    testWidgets('an artist tile is round and centred', (t) async {
      await t.pumpWidget(host(const SheenArtworkTile(title: 'Big Baby Tape', round: true, size: 120)));
      final art = t.widget<SheenArtwork>(find.byType(SheenArtwork));
      expect(art.round, isTrue);
      expect(t.getSize(find.byType(SheenArtwork)).width, 120);
    });
  });

  group('SheenMiniPlayer', () {
    Widget mini(List<String> calls, {bool playing = true}) => host(
      SizedBox(
        width: 380,
        child: SheenMiniPlayer(
          title: 'BRATAN',
          subtitle: 'Big Baby Tape',
          playing: playing,
          progress: .38,
          onOpen: () => calls.add('open'),
          onPlayPause: () => calls.add('pp'),
          onNext: () => calls.add('next'),
          onSwipeNext: () => calls.add('swipeNext'),
          onSwipePrevious: () => calls.add('swipePrev'),
        ),
      ),
    );

    testWidgets('buttons and tap', (t) async {
      final calls = <String>[];
      await t.pumpWidget(mini(calls));
      await t.tap(find.bySemanticsLabel('Pause'));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.bySemanticsLabel('Next'));
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.text('BRATAN'));
      await t.pump(const Duration(milliseconds: 400));
      expect(calls, ['pp', 'next', 'open']);
    });

    testWidgets('swipe sideways changes song; drag up opens the player', (t) async {
      final calls = <String>[];
      await t.pumpWidget(mini(calls));
      await t.fling(find.text('BRATAN'), const Offset(-200, 0), 1000);
      await t.pumpAndSettle();
      await t.fling(find.text('BRATAN'), const Offset(200, 0), 1000);
      await t.pumpAndSettle();
      await t.fling(find.text('BRATAN'), const Offset(0, -150), 1000);
      await t.pumpAndSettle();
      expect(calls, ['swipeNext', 'swipePrev', 'open']);
    });

    testWidgets('shows Play when paused', (t) async {
      await t.pumpWidget(mini([], playing: false));
      expect(find.bySemanticsLabel('Play'), findsOneWidget);
    });
  });
}
