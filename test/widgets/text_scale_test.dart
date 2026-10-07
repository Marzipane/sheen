import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';

import '../helpers.dart';

/// Dynamic Type: bars keep their text at the system size, as UIKit's tab, navigation and tool bars do; everything else
/// grows with the user's text size and must not overflow.
Widget app(Widget child, double scale) => host(
  Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox(width: 390, child: child),
  ),
  brightness: Brightness.dark,
  textScale: scale,
);

const tabs = [
  SheenTabItem(icon: 'home', label: 'Home'),
  SheenTabItem(icon: 'map', label: 'Map'),
  SheenTabItem(icon: 'compass', label: 'Explore'),
  SheenTabItem(icon: 'user', label: 'Profile'),
];

double fontOf(WidgetTester t, String text) {
  final rich = t.widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)));
  return rich.textScaler.scale(rich.text.style!.fontSize!);
}

void main() {
  for (final scale in [2.0, 3.0]) {
    group('text scale $scale', () {
      testWidgets('tab bar labels stay at 10 pt and the bar at 62', (t) async {
        await t.pumpWidget(
          app(SheenTabBar(items: tabs, index: 0, onSelect: (_) {}, onSearch: () {}, searchLabel: 'Search'), scale),
        );
        expect(t.takeException(), isNull);
        expect(fontOf(t, 'Home'), 10);
        expect(t.getSize(find.byType(SheenTabBar)).height, 62);
      });

      testWidgets('minimized bar with the hold accessory keeps its 52 pt', (t) async {
        await t.pumpWidget(
          app(
            SheenTabBar(
              items: tabs,
              index: 0,
              onSelect: (_) {},
              onSearch: () {},
              searchLabel: 'Search',
              minimized: true,
              accessory: const SheenTabAccessory(
                title: 'Room held',
                subtitle: 'Hotel Aurora',
                trailing: SheenCountdownPill(remaining: Duration(minutes: 12), semanticLabel: 'Room held'),
              ),
            ),
            scale,
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(fontOf(t, 'Room held'), 14);
      });

      testWidgets('toolbar summary keeps its 44 pt capsule', (t) async {
        await t.pumpWidget(
          app(
            SheenToolbar(
              leading: SheenIconButton(icon: 'back', semanticLabel: 'Back', onTap: () {}),
              center: SheenToolbarSummary(title: 'Lisbon', subtitle: '20–22 Oct · 2 adults', onTap: () {}),
              trailing: SheenIconButton(icon: 'sliders', semanticLabel: 'Filters', onTap: () {}),
            ),
            scale,
          ),
        );
        expect(t.takeException(), isNull);
        expect(fontOf(t, 'Lisbon'), 15);
      });

      testWidgets('action bar keeps its 72 pt', (t) async {
        await t.pumpWidget(
          app(
            SheenActionBar(
              value: 'USD 2,770.80',
              caption: 'Total for 2 nights',
              actionLabel: 'Choose a room',
              onAction: () {},
            ),
            scale,
          ),
        );
        expect(t.takeException(), isNull);
        expect(t.getSize(find.byType(SheenActionBar)).height, 72);
      });

      testWidgets('the notice grows with the text', (t) async {
        await t.pumpWidget(app(const SheenStatusNotice(message: 'Payments are temporarily unavailable.'), scale));
        expect(t.takeException(), isNull);
        expect(fontOf(t, 'Payments are temporarily unavailable.'), 13 * scale);
      });

      testWidgets('the alert grows with the text, scrolls its message and keeps its buttons reachable', (t) async {
        await t.pumpWidget(
          app(
            Builder(
              builder: (c) => GestureDetector(
                onTap: () => showSheenAlert(
                  context: c,
                  title: 'Booking Time Over',
                  message: 'The time for booking has expired. Please choose an option to proceed.',
                  primaryLabel: 'Book Again',
                  secondaryLabel: 'Go Back',
                ),
                child: const Text('open'),
              ),
            ),
            scale,
          ),
        );
        await t.tap(find.text('open'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(fontOf(t, 'Booking Time Over'), 17 * scale);
        final screen = Offset.zero & t.view.physicalSize / t.view.devicePixelRatio;
        expect(t.getRect(find.text('Go Back')).bottom, lessThanOrEqualTo(screen.bottom));
      });

      testWidgets('segmented control keeps its 48 pt with counts, as UISegmentedControl does', (t) async {
        await t.pumpWidget(
          app(
            SheenSegmentedControl(
              segments: const [
                SheenSegment('Visa-free', count: '126'),
                SheenSegment('On arrival', count: '41'),
                SheenSegment('eTA', count: '6'),
              ],
              index: 0,
              onChanged: (_) {},
            ),
            scale,
          ),
        );
        expect(t.takeException(), isNull);
        expect(t.getSize(find.byType(SheenSegmentedControl)).height, 48);
      });

      for (final (name, build) in <(String, Widget Function())>[
        (
          'chips',
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SheenChip(label: 'Lowest total', selected: true, menu: true, onTap: () {}),
                SheenChip(label: '3', selected: false, trailingIcon: 'star', onTap: () {}),
              ],
            ),
          ),
        ),
        (
          'stepper',
          () => Row(
            children: [
              const Expanded(child: Text('Adults')),
              SheenStepper(value: 2, onChanged: (_) {}, decreaseLabel: 'Fewer', increaseLabel: 'More'),
            ],
          ),
        ),
        ('text field', () => const SheenTextField(label: 'First name', placeholder: 'As in the passport')),
        (
          'hold timer',
          () => const Center(
            child: SheenCountdownPill(remaining: Duration(minutes: 12, seconds: 5), semanticLabel: 'Room held'),
          ),
        ),
        (
          'buttons',
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheenPrimaryButton(label: 'Choose a room', subLabel: 'USD 2,770.80', expand: true, onPressed: () {}),
              SheenSecondaryButton(label: 'Pay with card', icon: 'card', onPressed: () {}),
              SheenFloatingButton(label: 'Map', icon: 'map', onPressed: () {}),
            ],
          ),
        ),
        (
          'calendar',
          () => SheenDateRangeCalendar(
            month: DateTime(2026, 10),
            today: DateTime(2026, 10, 3),
            weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            start: DateTime(2026, 10, 20),
            end: DateTime(2026, 10, 22),
            onDay: (_) {},
          ),
        ),
      ]) {
        testWidgets('$name: no overflow', (t) async {
          await t.pumpWidget(app(SingleChildScrollView(child: build()), scale));
          expect(t.takeException(), isNull);
        });
      }
    });
  }
}
