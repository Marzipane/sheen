import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

const _chapters = [
  SheenChapter('Introduction', Duration.zero),
  SheenChapter('The storm', Duration(minutes: 40)),
  SheenChapter('The taiga', Duration(hours: 1, minutes: 20)),
];

void main() {
  group('SheenTransportControls for long audio', () {
    testWidgets('skip buttons take the place of previous and next, and say how far they go', (t) async {
      final h = t.ensureSemantics();
      var back = 0, fwd = 0;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenTransportControls(
              playing: true,
              onPlayPause: () {},
              onNext: () => fail('next must not show'),
              onSkipBack: () => back++,
              onSkipForward: () => fwd++,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Previous'), findsNothing);
      expect(find.bySemanticsLabel('Next'), findsNothing);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Back 15 seconds'));
      await t.tap(find.bySemanticsLabel('Forward 30 seconds'));
      expect((back, fwd), (1, 1));
      h.dispose();
    });

    testWidgets('the skip distance is the caller\'s', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenTransportControls(
              playing: false,
              onSkipBack: () {},
              onSkipForward: () {},
              skipBack: const Duration(seconds: 10),
              skipForward: const Duration(seconds: 45),
            ),
          ),
        ),
      );
      expect(find.text('10'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('leading and trailing replace shuffle and repeat', (t) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenTransportControls(
              playing: false,
              onShuffle: () {},
              onRepeat: () {},
              leading: const Text('1.25×'),
              trailing: const Text('sleep'),
            ),
          ),
        ),
      );
      expect(find.text('1.25×'), findsOneWidget);
      expect(find.text('sleep'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Shuffle')), findsNothing);
      h.dispose();
    });
  });

  group('SheenSkipButton', () {
    testWidgets('keeps its direction in right to left (media controls do not mirror)', (t) async {
      await t.pumpWidget(
        host(SheenSkipButton(seconds: 15, forward: false, onPressed: () {}), direction: TextDirection.rtl),
      );
      final mirrored = find.byWidgetPredicate((w) => w is Transform && w.transform.storage[0] < 0);
      expect(mirrored, findsNothing);
      expect(find.text('15'), findsOneWidget);
    });
  });

  group('SheenSeekBar for long audio', () {
    testWidgets('draws a mark where each chapter starts, not at zero', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: SheenSeekBar(
              position: Duration.zero,
              duration: const Duration(hours: 2),
              marks: [for (final c in _chapters) c.start],
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('sheen-seek-mark')), findsNWidgets(2));
    });

    testWidgets('time left follows the playback speed', (t) async {
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: SheenSeekBar(position: Duration(hours: 1), duration: Duration(hours: 3), rate: 2),
          ),
        ),
      );
      expect(find.text('1:00:00'), findsOneWidget);
      expect(find.text('-1:00:00'), findsOneWidget, reason: '2 hours left at 2× take 1 hour');
    });
  });

  group('SheenArtwork', () {
    testWidgets('a book is 3:4, as tall as size', (t) async {
      await t.pumpWidget(host(const SheenArtwork(size: 80, book: true)));
      expect(t.getSize(find.byType(SheenArtwork)), const Size(60, 80));
    });
  });

  group('SheenSpeedPicker', () {
    test('formatSheenSpeed', () {
      expect(formatSheenSpeed(1), '1×');
      expect(formatSheenSpeed(1.25), '1.25×');
      expect(formatSheenSpeed(.8), '0.8×');
      expect(formatSheenSpeed(2), '2×');
    });

    testWidgets('shows the speeds, marks the chosen one and reports a tap', (t) async {
      final h = t.ensureSemantics();
      double? picked;
      await t.pumpWidget(
        host(SizedBox(width: 360, child: SheenSpeedPicker(value: 1.25, onChanged: (v) => picked = v))),
      );
      for (final s in ['0.8×', '1×', '1.25×', '1.5×', '2×']) {
        expect(find.text(s), findsOneWidget);
      }
      expect(t.getSemantics(find.text('1.25×')), isSemantics(isSelected: true, isButton: true, label: '1.25×'));
      expect(t.getSemantics(find.text('1×')), isSemantics(isSelected: false));
      await t.tap(find.text('1.5×'));
      expect(picked, 1.5);
      h.dispose();
    });
  });

  group('SheenChapterList', () {
    testWidgets('the chapter holding the position is current; a tap picks a chapter', (t) async {
      final h = t.ensureSemantics();
      SheenChapter? picked;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenChapterList(
              chapters: _chapters,
              position: const Duration(minutes: 55),
              onSelected: (c) => picked = c,
            ),
          ),
        ),
      );
      expect(find.text('0:40:00'), findsOneWidget, reason: 'start times in hours when the book is long');
      expect(t.getSemantics(find.text('The storm')), isSemantics(isSelected: true));
      expect(t.getSemantics(find.text('The taiga')), isSemantics(isSelected: false));
      await t.tap(find.text('The taiga'));
      expect(picked, _chapters[2]);
      h.dispose();
    });

    test('currentSheenChapter', () {
      expect(currentSheenChapter(_chapters, const Duration(minutes: 39)), 0);
      expect(currentSheenChapter(_chapters, const Duration(minutes: 40)), 1);
      expect(currentSheenChapter(_chapters, const Duration(hours: 5)), 2);
      expect(currentSheenChapter(const [], Duration.zero), -1);
      expect(
        currentSheenChapter(const [SheenChapter('Later', Duration(minutes: 5))], Duration.zero),
        -1,
        reason: 'before the first chapter (another part of the book) no chapter is current',
      );
    });
  });

  group('SheenResumeCard', () {
    testWidgets('shows what is left and plays', (t) async {
      final h = t.ensureSemantics();
      var played = 0, opened = 0;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenResumeCard(
              title: 'Tigrolovy',
              subtitle: 'Chapter 7 · 6 h 20 min left',
              progress: .34,
              onPlay: () => played++,
              onTap: () => opened++,
            ),
          ),
        ),
      );
      expect(find.text('Continue listening'), findsOneWidget);
      expect(find.text('Tigrolovy'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Play'));
      await t.tap(find.text('Tigrolovy'));
      expect((played, opened), (1, 1));
      h.dispose();
    });
  });

  group('SheenMiniPlayer for long audio', () {
    testWidgets('a skip-forward button takes the place of next', (t) async {
      final h = t.ensureSemantics();
      var fwd = 0;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenMiniPlayer(
              title: 'Tigrolovy',
              playing: true,
              onPlayPause: () {},
              onNext: () => fail('next must not show'),
              onSkipForward: () => fwd++,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Next'), findsNothing);
      await t.tap(find.bySemanticsLabel('Forward 30 seconds'));
      expect(fwd, 1);
      h.dispose();
    });
  });

  group('SheenTagRow', () {
    testWidgets('shows each tag; a success tag takes the success colour', (t) async {
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: SheenTagRow(
              tags: [
                SheenTag('Whole book', tone: SheenTone.success),
                SheenTag('Ukrainian'),
              ],
            ),
          ),
        ),
      );
      final whole = t.widget<Text>(find.text('Whole book'));
      final lang = t.widget<Text>(find.text('Ukrainian'));
      expect(whole.style!.color, isNot(lang.style!.color));
    });
  });

  testWidgets('everything fits at 200 % text in right to left', (t) async {
    await t.pumpWidget(
      host(
        SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SheenTransportControls(
                  playing: true,
                  onSkipBack: () {},
                  onSkipForward: () {},
                  leading: const Text('1×'),
                ),
                const SheenSeekBar(
                  position: Duration(hours: 1),
                  duration: Duration(hours: 12),
                  rate: 1.5,
                  marks: [Duration(hours: 2)],
                ),
                SheenSpeedPicker(value: 1, onChanged: (_) {}),
                SheenChapterList(chapters: _chapters, position: Duration.zero, onSelected: (_) {}),
                SheenResumeCard(
                  title: 'A very long book title that goes on',
                  subtitle: 'Chapter 12 · 10 h 5 min left',
                  progress: .5,
                  onPlay: () {},
                ),
                const SheenTagRow(tags: [SheenTag('Whole book'), SheenTag('Ukrainian'), SheenTag('2 parts joined')]),
              ],
            ),
          ),
        ),
        direction: TextDirection.rtl,
        textScale: 2,
      ),
    );
    expect(t.takeException(), isNull);
  });
}
