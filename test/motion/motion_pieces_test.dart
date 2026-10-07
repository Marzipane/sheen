import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child, {TextDirection dir = TextDirection.ltr}) => host(
  Center(child: child),
  brightness: Brightness.dark,
  direction: dir,
);

void reduceMotion(WidgetTester t) {
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  double opacity(WidgetTester t) =>
      t.widget<Opacity>(find.descendant(of: find.byType(SheenEntrance), matching: find.byType(Opacity))).opacity;
  double dy(WidgetTester t) => t
      .widget<Transform>(find.descendant(of: find.byType(SheenEntrance), matching: find.byType(Transform)).first)
      .transform
      .getTranslation()
      .y;

  group('SheenEntrance', () {
    testWidgets('waits for its delay, then fades in and rises into place; taps work from the first frame', (t) async {
      var taps = 0;
      await t.pumpWidget(
        app(
          SheenEntrance(
            delay: const Duration(milliseconds: 300),
            rise: 18,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(width: 100, height: 40, child: Text('Search')),
            ),
          ),
        ),
      );
      expect(opacity(t), 0);
      expect(dy(t), 18);
      await t.tap(find.text('Search'), warnIfMissed: false);
      expect(taps, 1, reason: 'an entrance never blocks input');
      expect(find.bySemanticsLabel('Search'), findsOneWidget, reason: 'VoiceOver reads it while it is still clear');
      await t.pump(const Duration(milliseconds: 250));
      expect(opacity(t), 0, reason: 'still in its delay');
      await t.pump(const Duration(milliseconds: 200));
      expect(opacity(t), greaterThan(.5));
      expect(dy(t), inExclusiveRange(0, 18));
      await t.pumpAndSettle();
      expect(opacity(t), 1);
      expect(dy(t), 0);
    });

    testWidgets('with Reduce Motion it only fades, without the delay', (t) async {
      reduceMotion(t);
      await t.pumpWidget(
        app(const SheenEntrance(delay: Duration(milliseconds: 300), rise: 18, scaleFrom: .9, child: Text('Search'))),
      );
      expect(dy(t), 0);
      await t.pump(const Duration(milliseconds: 90));
      expect(opacity(t), inExclusiveRange(0, 1));
      final scale = t.widget<Transform>(
        find.descendant(of: find.byType(SheenEntrance), matching: find.byType(Transform)).at(1),
      );
      expect(scale.transform.storage[0], 1, reason: 'the x scale');
      await t.pump(const Duration(milliseconds: 100));
      expect(opacity(t), 1);
    });

    testWidgets('play: false shows the child as it is', (t) async {
      await t.pumpWidget(app(const SheenEntrance(play: false, rise: 18, child: Text('Card'))));
      expect(find.descendant(of: find.byType(SheenEntrance), matching: find.byType(Opacity)), findsNothing);
      expect(find.text('Card'), findsOneWidget);
    });
  });

  group('SheenPhotoHero', () {
    Widget card(BuildContext c) => GestureDetector(
      onTap: () => Navigator.of(c).push(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: SheenPhotoHero(
                tag: 'photo-1',
                child: ColoredBox(key: Key('page-photo'), color: Color(0xFF0000FF)),
              ),
            ),
          ),
        ),
      ),
      child: const SizedBox(
        width: 200,
        height: 120,
        child: SheenPhotoHero(
          tag: 'photo-1',
          radius: BorderRadius.all(Radius.circular(22)),
          child: ColoredBox(key: Key('card-photo'), color: Color(0xFFFF0000)),
        ),
      ),
    );

    testWidgets('the card photo flies to the page, its corners turning from the card\'s into the page\'s', (t) async {
      await t.pumpWidget(app(Builder(builder: card)));
      await t.tap(find.byKey(const Key('card-photo')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 150));
      // in flight the card's (already loaded) photo shows, clipped with a radius between 22 and 0
      final clip = t.widget<ClipRRect>(
        find.ancestor(of: find.byKey(const Key('card-photo')), matching: find.byType(ClipRRect)).first,
      );
      final r = (clip.borderRadius as BorderRadius).topLeft.x;
      expect(r, inExclusiveRange(0, 22));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('page-photo')), findsOneWidget);
      expect(t.getSize(find.byKey(const Key('page-photo'))).height, 300);
    });

    testWidgets('with Reduce Motion there is no flight', (t) async {
      reduceMotion(t);
      await t.pumpWidget(app(Builder(builder: card)));
      expect(find.byType(Hero), findsNothing);
    });
  });
}
