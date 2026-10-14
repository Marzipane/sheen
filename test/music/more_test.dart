import 'dart:typed_data';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

// A 1×1 PNG.
final png = MemoryImage(
  Uint8List.fromList(const [
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    248,
    207,
    192,
    240,
    31,
    0,
    5,
    0,
    1,
    255,
    137,
    153,
    61,
    29,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ]),
);

void main() {
  group('SheenArtworkGlow', () {
    testWidgets('blurs the cover behind its child', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 300,
            height: 300,
            child: SheenArtworkGlow(image: png, child: const Text('x')),
          ),
        ),
      );
      expect(find.byType(ImageFiltered), findsOneWidget);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('with reduced transparency it is a flat tint, no blur', (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 300,
            height: 300,
            child: SheenArtworkGlow(image: png, child: const Text('x')),
          ),
          theme: SheenThemeData.light().copyWith(reduceTransparency: true),
        ),
      );
      expect(find.byType(ImageFiltered), findsNothing);
    });

    testWidgets('without a cover it shows only the ground', (t) async {
      await t.pumpWidget(host(const SizedBox(width: 300, height: 300, child: SheenArtworkGlow(child: Text('x')))));
      expect(find.byType(ImageFiltered), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });
  });

  group('SheenLyricsView', () {
    const lines = [
      SheenLyricsLine(Duration.zero, 'one'),
      SheenLyricsLine(Duration(seconds: 10), 'two'),
      SheenLyricsLine(Duration(seconds: 20), 'three'),
    ];

    test('the current line is the last one that has started', () {
      expect(SheenLyricsView.indexAt(lines, const Duration(seconds: 5)), 0);
      expect(SheenLyricsView.indexAt(lines, const Duration(seconds: 10)), 1);
      expect(SheenLyricsView.indexAt(lines, const Duration(seconds: 99)), 2);
      expect(SheenLyricsView.indexAt(const [SheenLyricsLine(Duration(seconds: 3), 'late')], Duration.zero), -1);
    });

    testWidgets('the current line is bright, a tap seeks to a line', (t) async {
      Duration? seek;
      await t.pumpWidget(
        host(
          SizedBox(
            width: 320,
            height: 500,
            child: SheenLyricsView(lines: lines, position: const Duration(seconds: 12), onSeek: (d) => seek = d),
          ),
        ),
      );
      await t.pumpAndSettle();
      double opacityOf(String text) =>
          t.widget<AnimatedOpacity>(find.ancestor(of: find.text(text), matching: find.byType(AnimatedOpacity))).opacity;
      expect(opacityOf('two'), 1);
      expect(opacityOf('one'), lessThan(1));
      await t.tap(find.text('three'));
      expect(seek, const Duration(seconds: 20));
    });

    testWidgets('plain lyrics are shown as text when there are no timed lines', (t) async {
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 320,
            height: 500,
            child: SheenLyricsView(lines: [], plain: 'line a\nline b'),
          ),
        ),
      );
      expect(find.textContaining('line a'), findsOneWidget);
    });
  });

  group('SheenReorderList', () {
    testWidgets('dragging a handle reorders to the final index; a swipe removes', (t) async {
      final items = ['a', 'b', 'c', 'd'];
      final moves = <(int, int)>[];
      final removed = <int>[];
      await t.pumpWidget(
        host(
          SizedBox(
            width: 320,
            height: 400,
            child: SheenReorderList<String>(
              items: items,
              keyOf: (s) => ValueKey(s),
              onReorder: (from, to) => moves.add((from, to)),
              onRemove: removed.add,
              itemBuilder: (context, s, i, handle) => SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Expanded(child: Text(s)),
                    handle,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final handle = find.byType(ReorderableDragStartListener).first;
      final g = await t.startGesture(t.getCenter(handle));
      await t.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 8; i++) {
        await g.moveBy(const Offset(0, 15));
        await t.pump(const Duration(milliseconds: 16));
      }
      await t.pump(const Duration(milliseconds: 300));
      await g.up();
      await t.pumpAndSettle();
      expect(moves, [(0, 2)]);

      await t.drag(find.text('d'), const Offset(-400, 0));
      await t.pumpAndSettle();
      expect(removed, [3]);
    });
  });

  group('SheenBandSlider', () {
    testWidgets('drags up and down around 0 dB and reads in dB', (t) async {
      double v = 0;
      final h = t.ensureSemantics();
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => SizedBox(
              height: 220,
              child: SheenBandSlider(label: 'Bass', value: v, onChanged: (x) => set(() => v = x)),
            ),
          ),
        ),
      );
      expect(find.text('0 dB'), findsOneWidget);
      await t.drag(find.byKey(const ValueKey('sheen-band-track')), const Offset(0, -60));
      await t.pump();
      expect(v, greaterThan(2));
      final before = v.round();
      t.semantics.performAction(find.semantics.byLabel('Bass'), SemanticsAction.increase);
      await t.pump();
      expect(v.round(), before + 1);
      expect(find.text('+${before + 1} dB'), findsOneWidget);
      h.dispose();
    });
  });
}
