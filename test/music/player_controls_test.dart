import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget bar(SheenSeekBar b, {TextDirection dir = TextDirection.ltr}) =>
    host(SizedBox(width: 300, child: b), direction: dir);

void main() {
  group('formatSheenDuration', () {
    test('minutes and seconds, hours when needed, never negative zero', () {
      expect(formatSheenDuration(const Duration(seconds: 90)), '1:30');
      expect(formatSheenDuration(const Duration(seconds: 5)), '0:05');
      expect(formatSheenDuration(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
      expect(formatSheenDuration(const Duration(seconds: -147)), '-2:27');
      expect(formatSheenDuration(Duration.zero), '0:00');
    });
  });

  group('SheenSeekBar', () {
    testWidgets('shows elapsed and remaining time', (t) async {
      await t.pumpWidget(bar(const SheenSeekBar(position: Duration(seconds: 90), duration: Duration(seconds: 237))));
      expect(find.text('1:30'), findsOneWidget);
      expect(find.text('-2:27'), findsOneWidget);
    });

    testWidgets('a tap seeks to that point; dragging previews and ends once', (t) async {
      final seen = <Duration>[];
      Duration? end;
      await t.pumpWidget(
        bar(
          SheenSeekBar(
            position: Duration.zero,
            duration: const Duration(seconds: 100),
            onSeek: seen.add,
            onSeekEnd: (d) => end = d,
          ),
        ),
      );
      final track = t.getRect(find.byKey(const ValueKey('sheen-seek-track')));
      await t.tapAt(Offset(track.left + track.width * .25, track.center.dy));
      await t.pump();
      expect(end!.inSeconds, closeTo(25, 1));

      final g = await t.startGesture(Offset(track.left + track.width * .5, track.center.dy));
      await t.pump();
      await g.moveTo(Offset(track.left + track.width * .75, track.center.dy));
      await t.pump();
      expect(find.text('1:15'), findsOneWidget, reason: 'the time follows the finger');
      await g.up();
      await t.pump();
      expect(seen.last.inSeconds, closeTo(75, 1));
      expect(end!.inSeconds, closeTo(75, 1));
    });

    testWidgets('in right to left, the start is at the right', (t) async {
      Duration? end;
      await t.pumpWidget(
        bar(
          SheenSeekBar(position: Duration.zero, duration: const Duration(seconds: 100), onSeekEnd: (d) => end = d),
          dir: TextDirection.rtl,
        ),
      );
      final track = t.getRect(find.byKey(const ValueKey('sheen-seek-track')));
      await t.tapAt(Offset(track.left + track.width * .25, track.center.dy));
      await t.pump();
      expect(end!.inSeconds, closeTo(75, 1));
    });

    testWidgets('a screen reader moves it 10 seconds at a time', (t) async {
      final h = t.ensureSemantics();
      Duration? end;
      await t.pumpWidget(
        bar(SheenSeekBar(position: const Duration(seconds: 30), duration: const Duration(seconds: 100), onSeekEnd: (d) => end = d)),
      );
      final node = t.getSemantics(find.byType(SheenSeekBar));
      expect(node.label, 'Position');
      expect(node.value, '0:30');
      t.semantics.performAction(find.semantics.byLabel('Position'), SemanticsAction.increase);
      await t.pump();
      expect(end, const Duration(seconds: 40));
      h.dispose();
    });

    testWidgets('a zero duration draws an empty bar and does not throw', (t) async {
      await t.pumpWidget(bar(const SheenSeekBar(position: Duration.zero, duration: Duration.zero)));
      expect(t.takeException(), isNull);
      expect(find.text('0:00'), findsNWidgets(2));
    });
  });

  group('SheenTransportControls', () {
    testWidgets('each button calls back and is labelled', (t) async {
      final calls = <String>[];
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenTransportControls(
              playing: true,
              onPlayPause: () => calls.add('pp'),
              onNext: () => calls.add('next'),
              onPrevious: () => calls.add('prev'),
              onShuffle: () => calls.add('shuffle'),
              onRepeat: () => calls.add('repeat'),
              repeat: SheenRepeatMode.one,
            ),
          ),
        ),
      );
      for (final label in ['Pause', 'Next', 'Previous', 'Shuffle: off', 'Repeat: this song']) {
        await t.tap(find.bySemanticsLabel(label));
        await t.pump(const Duration(milliseconds: 400));
      }
      expect(calls, ['pp', 'next', 'prev', 'shuffle', 'repeat']);
      expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.repeatOne), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.pauseFill), findsOneWidget);
    });

    testWidgets('shows Play when paused; shuffle and repeat light up in the accent', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 360,
            child: SheenTransportControls(playing: false, shuffle: true, repeat: SheenRepeatMode.all, onPlayPause: () {}, onShuffle: () {}, onRepeat: () {}),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Play'), findsOneWidget);
      expect(find.bySemanticsLabel('Shuffle: on'), findsOneWidget);
      final shuffle = t.widget<SheenIcon>(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.shuffle));
      final ctx = t.element(find.byType(SheenTransportControls));
      expect(shuffle.color, ctx.sheen.colors.accentText);
    });
  });
}
