import 'dart:ui' show SemanticsAction;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

void main() {
  group('SheenSlider', () {
    Widget slider(
      double value,
      ValueChanged<double> onChanged, {
      int? divisions,
      TextDirection dir = TextDirection.ltr,
    }) => host(
      SizedBox(
        width: 300,
        child: SheenSlider(value: value, onChanged: onChanged, divisions: divisions, semanticLabel: 'Volume'),
      ),
      direction: dir,
    );

    testWidgets('a tap at three quarters sets .75', (t) async {
      double? v;
      await t.pumpWidget(slider(0, (x) => v = x));
      final r = t.getRect(find.byType(SheenSlider));
      await t.tapAt(Offset(r.left + SheenSlider.thumb / 2 + (r.width - SheenSlider.thumb) * .75, r.center.dy));
      expect(v, closeTo(.75, .01));
    });

    testWidgets('divisions snap', (t) async {
      double? v;
      await t.pumpWidget(slider(0, (x) => v = x, divisions: 4));
      final r = t.getRect(find.byType(SheenSlider));
      await t.tapAt(Offset(r.left + SheenSlider.thumb / 2 + (r.width - SheenSlider.thumb) * .6, r.center.dy));
      expect(v, .5);
    });

    testWidgets('right to left, the start is on the right', (t) async {
      double? v;
      await t.pumpWidget(slider(0, (x) => v = x, dir: TextDirection.rtl));
      final r = t.getRect(find.byType(SheenSlider));
      await t.tapAt(Offset(r.left + SheenSlider.thumb / 2 + (r.width - SheenSlider.thumb) * .25, r.center.dy));
      expect(v, closeTo(.75, .01));
    });

    testWidgets('screen readers adjust it in steps; arrow keys too', (t) async {
      final handle = t.ensureSemantics();
      final seen = <double>[];
      await t.pumpWidget(slider(.5, seen.add, divisions: 10));
      final node = t.getSemantics(find.byType(SheenSlider));
      expect(node.label, 'Volume');
      expect(node.value, '50%');
      t.semantics.performAction(find.semantics.byLabel('Volume'), SemanticsAction.increase);
      expect(seen.last, closeTo(.6, 1e-9));
      handle.dispose();
    });
  });

  group('progress', () {
    testWidgets('a bar fills to its value', (t) async {
      await t.pumpWidget(host(const SizedBox(width: 200, child: SheenProgressBar(value: .3))));
      final fill = t.getSize(find.byKey(const ValueKey('sheen-progress-fill')));
      expect(fill.width, closeTo(60, .5));
    });

    testWidgets('without a value it is indeterminate and keeps moving; with Reduce Motion it holds still', (t) async {
      await t.pumpWidget(host(const SizedBox(width: 200, child: SheenProgressBar())));
      expect(t.binding.hasScheduledFrame, isTrue);
      await t.pumpWidget(host(const SizedBox(width: 200, child: SheenProgressBar()), reduceMotion: true));
      await t.pump();
      expect(t.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a ring reads its value as a percentage', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(host(const SheenProgressRing(value: .42, semanticLabel: 'Uploading')));
      final node = t.getSemantics(find.byType(SheenProgressRing));
      expect(node.label, 'Uploading');
      expect(node.value, '42%');
      handle.dispose();
    });
  });

  group('menu', () {
    Widget anchor(GlobalKey key, Future<String?> Function(BuildContext) open, {Alignment at = Alignment.topLeft}) =>
        host(
          SizedBox.expand(
            child: Align(
              alignment: at,
              child: Builder(
                builder: (c) => GestureDetector(
                  key: key,
                  onTap: () => open(c),
                  child: const SizedBox(width: 44, height: 44, child: Text('more')),
                ),
              ),
            ),
          ),
        );

    final items = [
      const SheenMenuItem(value: 'share', label: 'Share', icon: SheenIcons.share),
      const SheenMenuItem(value: 'copy', label: 'Copy link', icon: SheenIcons.link),
      const SheenMenuItem(value: 'delete', label: 'Delete', icon: SheenIcons.trash, destructive: true),
    ];

    testWidgets('opens below its anchor when there is room and returns the tapped value', (t) async {
      final key = GlobalKey();
      Future<String?>? result;
      await t.pumpWidget(anchor(key, (c) => result = showSheenMenu<String>(c, anchorKey: key, items: items)));
      await t.tap(find.text('more'));
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.text('Share')).dy, greaterThan(t.getBottomLeft(find.byKey(key)).dy));
      await t.tap(find.text('Copy link'));
      await t.pumpAndSettle();
      expect(await result, 'copy');
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('opens above an anchor at the bottom; a tap outside returns null', (t) async {
      final key = GlobalKey();
      Future<String?>? result;
      await t.pumpWidget(
        anchor(
          key,
          (c) => result = showSheenMenu<String>(c, anchorKey: key, items: items),
          at: Alignment.bottomRight,
        ),
      );
      await t.tap(find.text('more'));
      await t.pumpAndSettle();
      expect(t.getBottomLeft(find.text('Delete')).dy, lessThan(t.getTopLeft(find.byKey(key)).dy));
      expect(t.widget<Text>(find.text('Delete')).style!.color, SheenColors.light().danger);
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('Escape closes it', (t) async {
      final key = GlobalKey();
      Future<String?>? result;
      await t.pumpWidget(anchor(key, (c) => result = showSheenMenu<String>(c, anchorKey: key, items: items)));
      await t.tap(find.text('more'));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(await result, isNull);
    });
  });

  group('badge', () {
    testWidgets('a count at the top end of its child; 0 hides it; past the cap it reads 99+', (t) async {
      Widget badge(int count, {TextDirection dir = TextDirection.ltr}) => host(
        Center(
          child: SheenBadge(count: count, child: const SizedBox(width: 40, height: 40)),
        ),
        direction: dir,
      );
      await t.pumpWidget(badge(3));
      expect(find.text('3'), findsOneWidget);
      final child = t.getRect(find.byType(SizedBox).last);
      expect(t.getCenter(find.text('3')).dx, greaterThan(child.center.dx));
      await t.pumpWidget(badge(0));
      expect(find.text('0'), findsNothing);
      await t.pumpWidget(badge(120));
      expect(find.text('99+'), findsOneWidget);
      await t.pumpWidget(badge(5, dir: TextDirection.rtl));
      expect(t.getCenter(find.text('5')).dx, lessThan(t.getCenter(find.byType(SheenBadge)).dx));
    });

    testWidgets('a dot has no text', (t) async {
      await t.pumpWidget(host(const Center(child: SheenBadge.dot(child: SizedBox(width: 40, height: 40)))));
      expect(find.byType(Text), findsNothing);
      expect(find.byKey(const ValueKey('sheen-badge')), findsOneWidget);
    });
  });

  group('avatar', () {
    test('initials: the first letters of the first two words', () {
      expect(SheenAvatar.initialsOf('Ada Lovelace'), 'AL');
      expect(SheenAvatar.initialsOf('  grace   brewster hopper '), 'GB');
      expect(SheenAvatar.initialsOf('Plato'), 'P');
      expect(SheenAvatar.initialsOf('Øyvind Šimek'), 'ØŠ');
      expect(SheenAvatar.initialsOf(''), '');
    });

    test('the same name always gets the same tint', () {
      expect(SheenAvatar.tintOf('Ada Lovelace'), SheenAvatar.tintOf('Ada Lovelace'));
      expect(SheenTint.all, contains(SheenAvatar.tintOf('Grace Hopper')));
    });

    testWidgets('initials on a tint; no name shows the user glyph', (t) async {
      await t.pumpWidget(host(const SheenAvatar(name: 'Ada Lovelace')));
      expect(find.text('AL'), findsOneWidget);
      await t.pumpWidget(host(const SheenAvatar()));
      expect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == SheenIcons.userFill), findsOneWidget);
    });

    testWidgets('an image that fails falls back to the initials', (t) async {
      await t.pumpWidget(host(SheenAvatar(name: 'Ada Lovelace', image: MemoryImage(Uint8List.fromList([0, 1, 2])))));
      await t.pumpAndSettle();
      expect(find.text('AL'), findsOneWidget);
    });
  });
}
