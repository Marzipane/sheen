import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

Widget app(Widget child, {TextDirection dir = TextDirection.ltr, Brightness b = Brightness.dark}) =>
    host(child, brightness: b, direction: dir);

const tabs = [
  SheenTabItem(icon: 'home', label: 'Home'),
  SheenTabItem(icon: 'map', label: 'Map'),
  SheenTabItem(icon: 'compass', label: 'Explore'),
  SheenTabItem(icon: 'user', label: 'Profile'),
];

Widget bar({
  int index = 0,
  ValueChanged<int>? onSelect,
  VoidCallback? onSearch,
  bool minimized = false,
  Widget? accessory,
}) => Align(
  alignment: Alignment.bottomCenter,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
    child: SheenTabBar(
      items: tabs,
      index: index,
      onSelect: onSelect ?? (_) {},
      onSearch: onSearch ?? () {},
      searchLabel: 'Search',
      minimized: minimized,
      accessory: accessory,
    ),
  ),
);

void main() {
  group('SheenTabBar', () {
    testWidgets('shows four labelled tabs and a separate search circle', (t) async {
      await t.pumpWidget(app(bar()));
      for (final l in ['Home', 'Map', 'Explore', 'Profile']) {
        expect(find.text(l), findsOneWidget);
      }
      expect(t.getSize(find.bySemanticsLabel('Search')).width, 62);
    });

    testWidgets('tapping a tab selects it with a selection haptic; tapping search calls search', (t) async {
      final calls = <MethodCall>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
        calls.add(c);
        return null;
      });
      int? picked;
      var searched = 0;
      await t.pumpWidget(app(bar(onSelect: (i) => picked = i, onSearch: () => searched++)));
      await t.tap(find.text('Explore'));
      expect(picked, 2);
      expect(calls.where((c) => c.method == 'HapticFeedback.vibrate'), isNotEmpty);
      await t.tap(find.bySemanticsLabel('Search'));
      expect(searched, 1);
    });

    testWidgets(
      'a wide window: the tabs at the top with their labels, the lens on the selected one, search beside (I01)',
      (t) async {
        final picked = <String>[];
        await t.pumpWidget(
          app(
            Center(
              child: SheenTopTabBar(
                items: tabs,
                index: 2,
                onSelect: (i) => picked.add('tab $i'),
                onSearch: () => picked.add('search'),
                searchLabel: 'Search',
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        for (final tab in tabs) {
          expect(find.text(tab.label).hitTestable(), findsOneWidget);
        }
        expect(find.byType(SheenLens), findsOneWidget);
        expect(t.getCenter(find.byType(SheenLens)).dx, closeTo(t.getCenter(find.text('Explore')).dx, 16));
        expect(t.getCenter(find.bySemanticsLabel('Search')).dx, greaterThan(t.getCenter(find.text('Profile')).dx));
        await t.tap(find.text('Home'));
        await t.tap(find.bySemanticsLabel('Search'));
        expect(picked, ['tab 0', 'search']);

        // search is where the user is: its circle has the lens, no tab does
        await t.pumpWidget(
          app(
            Center(
              child: SheenTopTabBar(
                items: tabs,
                index: 2,
                onSelect: (_) {},
                onSearch: () {},
                searchLabel: 'Search',
                searchActive: true,
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(find.byType(SheenLens), findsOneWidget);
        expect(t.getCenter(find.byType(SheenLens)).dx, closeTo(t.getCenter(find.bySemanticsLabel('Search')).dx, 2));
      },
    );

    testWidgets('the lens travels to the selected tab', (t) async {
      await t.pumpWidget(app(bar(index: 0)));
      final x0 = t.getTopLeft(find.byType(SheenLens)).dx;
      await t.pumpWidget(app(bar(index: 3)));
      await t.pumpAndSettle();
      final x3 = t.getTopLeft(find.byType(SheenLens)).dx;
      expect(x3, greaterThan(x0 + 150));
    });

    testWidgets(
      'the capsule is as tall as search and the lens sits inside it 4 pt all round; lifted, it stays centred (owner 5 Oct)',
      (t) async {
        await t.pumpWidget(app(bar(index: 2)));
        await t.pumpAndSettle();
        // one glass for the capsule and the search circle (the liquid bar); at rest it is exactly the bar
        final capsule = t.getRect(find.byKey(const ValueKey('tab-bar-glass')));
        final search = t.getRect(find.bySemanticsLabel('Search'));
        expect(capsule.height, SheenTabBar.height);
        expect(capsule.center.dy, closeTo(search.center.dy, .01));
        final lens = t.getRect(find.byType(SheenLens));
        expect(lens.top - capsule.top, closeTo(4, .01));
        expect(capsule.bottom - lens.bottom, closeTo(4, .01), reason: 'its bottom was cut flat by the capsule');
        final face = t.getRect(
          find
              .ancestor(
                of: find.text('Explore'),
                matching: find.byWidgetPredicate((w) => w is SizedBox && w.height == 54),
              )
              .first,
        );
        expect(face.top, closeTo(lens.top, .01), reason: 'the tab sits in its lens');

        final g = await t.startGesture(t.getCenter(find.text('Explore')));
        await t.pump();
        await t.pump(const Duration(milliseconds: 200));
        expect(t.getCenter(find.byKey(const ValueKey('tab-lens-lifted'))).dy, closeTo(capsule.center.dy, .01));
        await g.up();
        await t.pumpAndSettle();
      },
    );

    testWidgets('right to left: the first tab and its lens sit on the right', (t) async {
      await t.pumpWidget(app(bar(index: 0), dir: TextDirection.rtl));
      await t.pumpAndSettle();
      expect(t.getCenter(find.text('Home')).dx, greaterThan(t.getCenter(find.text('Profile')).dx));
      expect(t.getCenter(find.byType(SheenLens)).dx, closeTo(t.getCenter(find.text('Home')).dx, 2));
    });

    group('press and slide (U01)', () {
      late List<MethodCall> calls;
      setUp(() => calls = []);
      int ticks() => calls.where((c) => c.method == 'HapticFeedback.vibrate').length;
      void listen(WidgetTester t) =>
          t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
            calls.add(c);
            return null;
          });
      final lifted = find.byKey(const ValueKey('tab-lens-lifted'));

      testWidgets(
        'the lens lifts at once past the capsule, zooms the tab under it, follows the finger; release opens that tab',
        (t) async {
          listen(t);
          final picked = <int>[];
          await t.pumpWidget(app(bar(onSelect: picked.add)));
          // while lifted the lens shows the tabs again (zoomed), so the places are read before the press
          final home = t.getCenter(find.text('Home'));
          final to = t.getCenter(find.text('Explore'));
          final g = await t.startGesture(home);
          // the spring starts on the next frame
          await t.pump();
          await t.pump(const Duration(milliseconds: 200));
          expect(lifted, findsOneWidget);
          expect(
            t.getSize(lifted).height,
            greaterThan(SheenTabBar.height),
            reason: 'it balloons past the 62 pt capsule',
          );
          expect(
            t.widget<Transform>(find.byKey(const ValueKey('tab-lens-zoom'))).transform.storage[0],
            closeTo(1.22, .01),
          );
          for (var i = 1; i <= 8; i++) {
            await g.moveTo(Offset.lerp(home, to, i / 8)!);
            await t.pump(const Duration(milliseconds: 16));
          }
          expect(t.getCenter(lifted).dx, closeTo(to.dx, 1), reason: 'glued to the finger');
          expect(ticks(), 2, reason: 'a tick at Map and one at Explore');
          expect(picked, isEmpty, reason: 'nothing opens until the finger lifts');
          await g.up();
          await t.pumpAndSettle();
          expect(picked, [2]);
          expect(lifted, findsNothing);
        },
      );

      testWidgets(
        'pressed, the bar\'s glass swells past 62 pt and runs into the search circle (owner 5 Oct, Telegram)',
        (t) async {
          await t.pumpWidget(app(bar()));
          final glass = find.byKey(const ValueKey('tab-bar-glass'));
          SheenBarBorder border() =>
              t.widget<SheenGlass>(find.descendant(of: glass, matching: find.byType(SheenGlass))).shape
                  as SheenBarBorder;
          expect(t.getSize(glass).height, SheenTabBar.height);
          expect(border().merge, 0, reason: 'at rest: the capsule and the circle apart');
          final g = await t.startGesture(t.getCenter(find.text('Explore')));
          await t.pump();
          await t.pump(const Duration(milliseconds: 300));
          // about 10 % taller on screen, as the iOS bar (the glass 2 pt, then the whole bar 9 %)
          expect(t.getRect(glass).height, closeTo((SheenTabBar.height + 2) * 1.09, 1));
          expect(border().merge, greaterThan(.9));
          expect(
            t.widget<Transform>(find.byKey(const ValueKey('tab-bar-elevation'))).transform.getMaxScaleOnAxis(),
            closeTo(1.09, .01),
            reason: 'the whole bar rises off the page (owner 5 Oct, the iOS Fitness bar)',
          );
          expect(
            t.getSize(lifted).height,
            greaterThan(SheenTabBar.height * 1.3),
            reason: 'the lens well past the bar, as Telegram\'s',
          );
          await g.up();
          await t.pumpAndSettle();
          expect(t.getSize(glass).height, SheenTabBar.height);
          expect(border().merge, 0);
          expect(
            t.widget<Transform>(find.byKey(const ValueKey('tab-bar-elevation'))).transform.getMaxScaleOnAxis(),
            closeTo(1, .001),
          );
        },
      );

      testWidgets('the lens slides on to the search circle; letting go there opens search, not a tab', (t) async {
        listen(t);
        final picked = <int>[];
        var searched = 0;
        await t.pumpWidget(app(bar(onSelect: picked.add, onSearch: () => searched++)));
        final from = t.getCenter(find.text('Profile'));
        final g = await t.startGesture(from);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        // the lifted bar is larger: the finger goes to the search circle where it is now
        final to = t.getCenter(find.bySemanticsLabel('Search'));
        for (var i = 1; i <= 8; i++) {
          await g.moveTo(Offset.lerp(from, to, i / 8)!);
          await t.pump(const Duration(milliseconds: 16));
        }
        expect(t.getCenter(lifted).dx, closeTo(to.dx, 1), reason: 'the lens sits on the search circle');
        expect(t.getSize(lifted).width, closeTo(t.getSize(lifted).height, 1), reason: 'round there');
        expect(ticks(), 1, reason: 'a tick as it reaches search');
        await g.up();
        await t.pumpAndSettle();
        expect(searched, 1);
        expect(picked, isEmpty);
      });

      testWidgets('a press on the search circle is its tap: no lens lifts', (t) async {
        var searched = 0;
        await t.pumpWidget(app(bar(onSearch: () => searched++)));
        final g = await t.startGesture(t.getCenter(find.bySemanticsLabel('Search')));
        // the spring would start on the next frame
        await t.pump();
        await t.pump(const Duration(milliseconds: 200));
        expect(lifted, findsNothing);
        await g.up();
        await t.pumpAndSettle();
        expect(searched, 1);
      });

      testWidgets('right to left: search is on the left, and sliding there opens it', (t) async {
        var searched = 0;
        await t.pumpWidget(app(bar(onSearch: () => searched++), dir: TextDirection.rtl));
        final from = t.getCenter(find.text('Profile'));
        final g = await t.startGesture(from);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
        final to = t.getCenter(find.bySemanticsLabel('Search'));
        expect(to.dx, lessThan(from.dx));
        for (var i = 1; i <= 8; i++) {
          await g.moveTo(Offset.lerp(from, to, i / 8)!);
          await t.pump(const Duration(milliseconds: 16));
        }
        expect(t.getCenter(lifted).dx, closeTo(to.dx, 1));
        await g.up();
        await t.pumpAndSettle();
        expect(searched, 1);
      });

      testWidgets('letting go away from the bar changes nothing', (t) async {
        final picked = <int>[];
        await t.pumpWidget(app(bar(onSelect: picked.add)));
        final g = await t.startGesture(t.getCenter(find.text('Home')));
        await g.moveBy(const Offset(120, 0));
        await t.pump();
        await g.moveBy(const Offset(0, -160));
        await t.pump();
        await g.up();
        await t.pumpAndSettle();
        expect(picked, isEmpty);
        expect(
          t.getCenter(find.byType(SheenLens)).dx,
          closeTo(t.getCenter(find.text('Home')).dx, 2),
          reason: 'the lens is back home',
        );
      });

      testWidgets('a plain tap still opens the tab once', (t) async {
        final picked = <int>[];
        await t.pumpWidget(app(bar(onSelect: picked.add)));
        await t.tap(find.text('Profile'));
        await t.pumpAndSettle();
        expect(picked, [3]);
      });

      testWidgets('right to left: sliding toward the left goes to the later tabs', (t) async {
        final picked = <int>[];
        await t.pumpWidget(app(bar(onSelect: picked.add), dir: TextDirection.rtl));
        final home = t.getCenter(find.text('Home'));
        final to = t.getCenter(find.text('Explore'));
        final g = await t.startGesture(home);
        for (var i = 1; i <= 6; i++) {
          await g.moveTo(Offset.lerp(home, to, i / 6)!);
          await t.pump(const Duration(milliseconds: 16));
        }
        await g.up();
        await t.pumpAndSettle();
        expect(picked, [2]);
      });

      testWidgets('Reduce Motion: no balloon and no zoom, only a 6 % swell', (t) async {
        t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(reduceMotion: true);
        addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await t.pumpWidget(app(bar()));
        final g = await t.startGesture(t.getCenter(find.text('Home')));
        await t.pump(const Duration(milliseconds: 200));
        expect(t.getSize(lifted).height, closeTo(54 * 1.06, .5));
        expect(t.widget<Transform>(find.byKey(const ValueKey('tab-lens-zoom'))).transform.storage[0], closeTo(1, .001));
        expect(
          t.getSize(find.byKey(const ValueKey('tab-bar-glass'))).height,
          SheenTabBar.height,
          reason: 'the glass keeps its shape',
        );
        expect(
          t.widget<Transform>(find.byKey(const ValueKey('tab-bar-elevation'))).transform.getMaxScaleOnAxis(),
          closeTo(1, .001),
          reason: 'nor does the bar rise',
        );
        await g.up();
        await t.pumpAndSettle();
      });
    });

    test(
      'SheenBarBorder: apart at rest, one shape through a neck when merged, the circle on the left right to left',
      () {
        const rect = Rect.fromLTWH(0, 0, 360, 62);
        // the middle of the gap, on the axis
        const mid = Offset(360 - 62 - SheenTabBar.gap / 2, 31);
        expect(const SheenBarBorder().getOuterPath(rect).contains(mid), isFalse);
        expect(const SheenBarBorder(merge: 1).getOuterPath(rect).contains(mid), isTrue);
        expect(
          const SheenBarBorder(merge: 1).getOuterPath(rect).contains(const Offset(360 - 62 - SheenTabBar.gap / 2, 2)),
          isFalse,
          reason: 'a waist, not a block',
        );
        const rtlMid = Offset(62 + SheenTabBar.gap / 2, 31);
        expect(
          const SheenBarBorder(merge: 1).getOuterPath(rect, textDirection: TextDirection.rtl).contains(rtlMid),
          isTrue,
        );
        expect(const SheenBarBorder().getOuterPath(rect, textDirection: TextDirection.rtl).contains(rtlMid), isFalse);
        // a light press: the neck grows out of nothing, it does not pop in
        expect(const SheenBarBorder(merge: .02).getOuterPath(rect).contains(mid), isFalse);
      },
    );

    testWidgets('minimized: the current tab, the accessory and search; labels hidden', (t) async {
      await t.pumpWidget(app(bar(minimized: true, accessory: const Text('Room held'))));
      await t.pumpAndSettle();
      expect(find.text('Room held'), findsOneWidget);
      expect(find.text('Explore').hitTestable(), findsNothing);
    });
  });

  group('buttons and bars', () {
    testWidgets('SheenIconButton is 44 pt with a label, in every variant', (t) async {
      var n = 0;
      for (final v in SheenGlassVariant.values) {
        await t.pumpWidget(
          app(
            Center(
              child: SheenIconButton(icon: 'back', semanticLabel: 'Back', variant: v, onTap: () => n++),
            ),
          ),
        );
        expect(t.getSize(find.byType(SheenIconButton)), const Size(44, 44));
        await t.tap(find.bySemanticsLabel('Back'));
      }
      expect(n, 3);
    });

    testWidgets('SheenButtonGroup shares one capsule', (t) async {
      await t.pumpWidget(
        app(
          Center(
            child: SheenButtonGroup(
              items: [
                SheenButtonGroupItem(icon: 'share', semanticLabel: 'Share', onTap: () {}),
                SheenButtonGroupItem(icon: 'heart', semanticLabel: 'Save', onTap: () {}),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SheenGlass), findsOneWidget);
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
    });

    testWidgets('SheenToolbar with a summary capsule', (t) async {
      var opened = 0;
      await t.pumpWidget(
        app(
          SheenToolbar(
            leading: SheenIconButton(icon: 'back', semanticLabel: 'Back', onTap: () {}),
            center: SheenToolbarSummary(title: 'Lisbon', subtitle: '20–22 Oct · 2 adults', onTap: () => opened++),
            trailing: SheenIconButton(icon: 'sliders', semanticLabel: 'Filters', onTap: () {}),
          ),
        ),
      );
      await t.tap(find.text('Lisbon'));
      expect(opened, 1);
      expect(find.text('20–22 Oct · 2 adults'), findsOneWidget);
    });

    testWidgets('SheenActionBar: price, caption and one prominent action', (t) async {
      var n = 0;
      await t.pumpWidget(
        app(
          Align(
            alignment: Alignment.bottomCenter,
            child: SheenActionBar(
              value: 'USD 2,770.80',
              caption: 'Total for 2 nights',
              actionLabel: 'Choose a room',
              onAction: () => n++,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('USD 2,770.80'), findsOneWidget);
      expect(find.text('Total for 2 nights'), findsOneWidget);
      await t.tap(find.text('Choose a room'));
      expect(n, 1);
      expect(t.getSize(find.byType(SheenActionBar)).height, 72);
    });

    testWidgets('SheenPrimaryButton: loading keeps the label and ignores taps; disabled ignores taps', (t) async {
      var n = 0;
      await t.pumpWidget(
        app(
          Center(
            child: SheenPrimaryButton(label: 'Continue', loading: true, onPressed: () => n++),
          ),
        ),
      );
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(SheenSpinner), findsOneWidget);
      await t.tap(find.text('Continue'));
      await t.pumpWidget(app(const Center(child: SheenPrimaryButton(label: 'Continue', onPressed: null))));
      await t.tap(find.text('Continue'), warnIfMissed: false);
      expect(n, 0);
      await t.pumpWidget(
        app(
          Center(
            child: SheenPrimaryButton(label: 'Continue', onPressed: () => n++),
          ),
        ),
      );
      await t.tap(find.text('Continue'));
      expect(n, 1);
    });
  });

  group('sheets, alerts, notices', () {
    testWidgets('showSheenSheet: title, Cancel and Done', (t) async {
      var done = 0;
      await t.pumpWidget(
        app(
          Builder(
            builder: (c) => Center(
              child: GestureDetector(
                onTap: () => showSheenSheet<void>(
                  context: c,
                  title: 'Dates & guests',
                  cancelLabel: 'Cancel',
                  doneLabel: 'Done',
                  onDone: () => done++,
                  builder: (c, scroll) => ListView(
                    controller: scroll,
                    children: const [SizedBox(height: 600, child: Text('body'))],
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Dates & guests'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Done'));
      await t.pumpAndSettle();
      expect(done, 1);
      expect(find.text('Dates & guests'), findsNothing);
    });

    testWidgets('the sheet header can carry a second line under the title', (t) async {
      await t.pumpWidget(
        app(
          SizedBox(
            height: 400,
            child: SheenSheetBody(
              title: 'Choose a room',
              subtitle: '172 offers · 20–22 Oct · 2 adults',
              cancelLabel: 'Close',
              onCancel: () {},
              child: const SizedBox(),
            ),
          ),
        ),
      );
      expect(find.text('Choose a room'), findsOneWidget);
      expect(find.text('172 offers · 20–22 Oct · 2 adults'), findsOneWidget);
      expect(
        t.getTopLeft(find.text('172 offers · 20–22 Oct · 2 adults')).dy,
        greaterThan(t.getTopLeft(find.text('Choose a room')).dy),
      );
    });

    testWidgets('showSheenAlert takes the theme of the screen that asks, not the app\'s', (t) async {
      await t.pumpWidget(
        host(
          SheenTheme(
            data: SheenThemeData.dark(),
            child: Builder(
              builder: (c) => GestureDetector(
                onTap: () => showSheenAlert(context: c, title: 'Time is up', message: 'm', primaryLabel: 'Try again'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(t.element(find.byType(SheenAlert)).sheen.isDark, isTrue);
    });

    testWidgets('showSheenAlert returns true for the primary action', (t) async {
      bool? result;
      await t.pumpWidget(
        app(
          Builder(
            builder: (c) => Center(
              child: GestureDetector(
                onTap: () async => result = await showSheenAlert(
                  context: c,
                  title: 'Booking Time Over',
                  message: 'The time for booking has expired.',
                  primaryLabel: 'Book Again',
                  secondaryLabel: 'Go Back',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      // D19: the actions stack, primary above secondary, each 48 pt high.
      final book = t.getRect(find.ancestor(of: find.text('Book Again'), matching: find.byType(SheenPressable)));
      final back = t.getRect(find.ancestor(of: find.text('Go Back'), matching: find.byType(SheenPressable)));
      expect(book.bottom, lessThanOrEqualTo(back.top));
      expect(book.height, 48);
      expect(t.widget<Text>(find.text('Booking Time Over')).style!.fontSize, 17);
      await t.tap(find.text('Book Again'));
      await t.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('SheenStatusNotice shows the server message', (t) async {
      await t.pumpWidget(app(const Center(child: SheenStatusNotice(message: 'Payments are temporarily unavailable.'))));
      expect(find.text('Payments are temporarily unavailable.'), findsOneWidget);
    });

    testWidgets('SheenScrollEdge builds at both edges in both themes', (t) async {
      for (final b in Brightness.values) {
        await t.pumpWidget(
          app(const Stack(children: [SheenScrollEdge.top(height: 110), SheenScrollEdge.bottom(height: 150)]), b: b),
        );
        expect(find.byType(SheenScrollEdge), findsNWidgets(2));
      }
    });
  });
}
