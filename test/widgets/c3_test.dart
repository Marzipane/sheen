import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

import '../helpers.dart';

Widget app(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  double scale = 1,
  Brightness b = Brightness.dark,
  bool reduced = false,
}) => host(
  Center(child: child),
  brightness: b,
  direction: dir,
  textScale: scale,
  reduceMotion: reduced,
);

Widget photo(BuildContext c, int i) => ColoredBox(color: Color(0xFF203040 + i * 0x101010));

SheenHotelCard aurora({int photos = 3, double scale = 1, VoidCallback? onTap, VoidCallback? onSave}) => SheenHotelCard(
  name: 'Hotel Aurora',
  total: 'USD 1,448',
  perNight: 'USD 724 a night',
  headline: 'Baixa · 0.4 km to Rossio',
  score: '4.7',
  recommend: '98% recommend',
  board: 'Room only',
  cancellation: 'Free cancellation until 12 Oct',
  refundable: true,
  photoCount: photos,
  photoBuilder: photo,
  noPhotoLabel: 'No photo yet',
  saved: false,
  saveLabel: 'Save',
  onSave: onSave ?? () {},
  onTap: onTap ?? () {},
);

void main() {
  testWidgets('SheenHotelCard: photo pager with dots and Save; the card and Save are separate buttons', (t) async {
    var opened = 0, saved = 0;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 358,
          child: aurora(onTap: () => opened++, onSave: () => saved++),
        ),
      ),
    );
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(SheenPagerDots), findsOneWidget);
    expect(find.text('USD 1,448'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Save'));
    expect(saved, 1);
    expect(opened, 0);
    await t.tap(find.text('Room only'));
    expect(opened, 1);
    final save = t.getSize(
      find.ancestor(of: find.byType(SheenGlass).first, matching: find.byType(SheenPressable)).first,
    );
    expect(save.width, greaterThanOrEqualTo(44));
    expect(find.bySemanticsLabel(RegExp('Hotel Aurora, USD 1,448')), findsOneWidget);
  });

  testWidgets('SheenHotelCard: a swipe moves the active dot', (t) async {
    await t.pumpWidget(app(SizedBox(width: 358, child: aurora())));
    expect(t.widget<SheenPagerDots>(find.byType(SheenPagerDots)).index, 0);
    await t.drag(find.byType(PageView), const Offset(-300, 0));
    await t.pumpAndSettle();
    expect(t.widget<SheenPagerDots>(find.byType(SheenPagerDots)).index, 1);
  });

  testWidgets('SheenHotelCard: no photo shows the bed and the passed-in label, no pager', (t) async {
    await t.pumpWidget(app(SizedBox(width: 358, child: aurora(photos: 0))));
    expect(find.byType(PageView), findsNothing);
    expect(find.text('No photo yet'), findsOneWidget);
    expect(
      t.widget<SheenIcon>(find.byWidgetPredicate((w) => w is SheenIcon && w.name == 'heart')).color,
      SheenColors.dark().text,
    );
  });

  testWidgets('SheenHotelCard: missing optional fields are left out, never invented', (t) async {
    await t.pumpWidget(
      app(
        SizedBox(
          width: 358,
          child: SheenHotelCard(
            name: 'Hotel',
            total: 'USD 900',
            photoCount: 1,
            photoBuilder: photo,
            noPhotoLabel: 'No photo yet',
            saveLabel: 'Save',
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(SheenScoreBadge), findsNothing);
    expect(find.byType(SheenCancellationLine), findsNothing);
    expect(find.byType(SheenPagerDots), findsNothing);
    expect(find.bySemanticsLabel('Save'), findsNothing);
  });

  testWidgets('SheenHotelCard fits at text scale 2', (t) async {
    await t.pumpWidget(app(SizedBox(width: 358, child: aurora()), scale: 2));
    expect(t.takeException(), isNull);
  });

  testWidgets('SheenHotelCard Save sits at the end edge and mirrors in RTL', (t) async {
    await t.pumpWidget(app(SizedBox(width: 358, child: aurora()), dir: TextDirection.rtl));
    final card = t.getRect(find.byType(SheenHotelCard));
    final save = t.getRect(find.bySemanticsLabel('Save'));
    expect(save.center.dx, lessThan(card.center.dx));
  });

  testWidgets('SheenHotelCardSkeleton is static when motion is reduced', (t) async {
    await t.pumpWidget(app(const SizedBox(width: 358, child: SheenHotelCardSkeleton()), reduced: true));
    await t.pump();
    expect(find.byType(SheenSkeleton), findsWidgets);
    expect(t.getSize(find.byType(SheenSkeleton).first), const Size(358, 196));
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('SheenSkeleton without a width fills the width it is given, like the CSS block', (t) async {
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 200,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SheenSkeleton(height: 60)]),
        ),
      ),
    );
    expect(t.getSize(find.byType(SheenSkeleton)), const Size(200, 60));
  });

  testWidgets('SheenSkeleton shimmers otherwise', (t) async {
    await t.pumpWidget(app(const SheenSkeleton(width: 120, height: 12)));
    await t.pump(const Duration(milliseconds: 100));
    expect(t.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('SheenPremiumCard: name, score, headline and total with the nights label', (t) async {
    var n = 0;
    await t.pumpWidget(
      app(
        SheenPremiumCard(
          name: 'Hotel Mirador',
          total: 'USD 6,120',
          nightsLabel: '2 nights',
          score: '4.8',
          headline: 'Old Town',
          photo: const ColoredBox(color: Color(0xFF334455)),
          saveLabel: 'Save',
          onSave: () {},
          onTap: () => n++,
        ),
      ),
    );
    expect(t.getSize(find.byType(SheenPremiumCard)).width, 232);
    expect(find.textContaining('2 nights', findRichText: true), findsOneWidget);
    expect(t.widget<SheenScoreBadge>(find.byType(SheenScoreBadge)).size, SheenScoreSize.small);
    await t.tap(find.text('Old Town'));
    expect(n, 1);
  });

  for (final scale in [1.0, 1.5, 2.0, 3.0]) {
    testWidgets('SheenPremiumCard fits the carousel height it asks for at text scale $scale', (t) async {
      final h = SheenPremiumCard.heightFor(TextScaler.linear(scale));
      await t.pumpWidget(
        app(
          SizedBox(
            height: h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SheenPremiumCard(
                  name: 'Hotel Mirador',
                  total: 'USD 5,521.47',
                  nightsLabel: '2 nights',
                  score: '4.7',
                  headline: 'Near Lost Chambers Aquarium',
                  saveLabel: 'Save',
                  onTap: () {},
                ),
              ],
            ),
          ),
          scale: scale,
        ),
      );
      expect(t.takeException(), isNull);
      if (scale == 1) expect(h, lessThan(240));
    });
  }

  testWidgets('SheenCityTile: the visa rule dot takes its colour from the kind; no photo gives a plain card', (
    t,
  ) async {
    await t.pumpWidget(
      app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenCityTile(
              name: 'Istanbul',
              distance: '3,000 km',
              rule: 'Visa-free',
              kind: SheenVisaKind.free,
              photo: const ColoredBox(color: Color(0xFF445566)),
              onTap: () {},
            ),
            SheenCityTile(name: 'London', rule: 'eTA', kind: SheenVisaKind.eta, onTap: () {}),
            SheenCityTile(name: 'New York', rule: 'Visa required', kind: SheenVisaKind.required, onTap: () {}),
          ],
        ),
      ),
    );
    Color dot(int i) =>
        (t.widget<DecoratedBox>(find.byKey(const ValueKey('visa-dot')).at(i)).decoration as BoxDecoration).color!;
    expect(dot(0), SheenColors.dark().success);
    expect(dot(1), SheenColors.dark().warning);
    expect(dot(2), SheenColors.dark().danger);
    expect(find.bySemanticsLabel(RegExp('Istanbul, 3,000 km, Visa-free')), findsOneWidget);
  });

  testWidgets('SheenCityTile over a photo keeps the bright dot colours in the light theme', (t) async {
    await t.pumpWidget(
      app(
        SheenCityTile(
          name: 'Istanbul',
          rule: 'Visa-free',
          kind: SheenVisaKind.free,
          photo: const ColoredBox(color: Color(0xFF445566)),
          onTap: () {},
        ),
        b: Brightness.light,
      ),
    );
    expect(
      (t.widget<DecoratedBox>(find.byKey(const ValueKey('visa-dot'))).decoration as BoxDecoration).color,
      SheenColors.dark().success,
    );
  });

  testWidgets('SheenScoreBadge sizes, SheenStarRating count and label, SheenScoreBar fraction', (t) async {
    await t.pumpWidget(
      app(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenScoreBadge('4.7', size: SheenScoreSize.small),
            SheenScoreBadge('4.7'),
            SheenScoreBadge('4.7', size: SheenScoreSize.large),
            SheenStarRating(count: 5, semanticLabel: '5 stars'),
            SizedBox(
              width: 280,
              child: SheenScoreBar(label: 'Cleanliness', value: '4.8', fraction: .96),
            ),
          ],
        ),
      ),
    );
    final h = find.byType(SheenScoreBadge).evaluate().map((e) => t.getSize(find.byWidget(e.widget)).height).toList();
    expect(h, [20, 24, 40]);
    expect(find.bySemanticsLabel('5 stars'), findsOneWidget);
    expect(find.byType(SheenIcon), findsNWidgets(5));
    final fill = t.getSize(find.byKey(const ValueKey('score-bar-fill')));
    expect(fill.width, closeTo(280 * .96, .5));
    expect(fill.height, 6);
  });

  testWidgets('SheenPriceBlock and both cancellation lines', (t) async {
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheenPriceBlock(total: 'USD 1,448', caption: 'Total for 2 nights', perNight: 'USD 724 a night'),
              SheenCancellationLine(text: 'Free cancellation until 12 Oct', refundable: true),
              SheenCancellationLine(text: 'Non-refundable', refundable: false),
            ],
          ),
        ),
      ),
    );
    final icons = t.widgetList<SheenIcon>(find.byType(SheenIcon)).map((i) => i.name).toList();
    expect(icons, ['check', 'x-circle']);
    expect(t.widget<Text>(find.text('Free cancellation until 12 Oct')).style!.color, SheenColors.dark().success);
    expect(t.widget<Text>(find.text('Non-refundable')).style!.color, SheenColors.dark().textSecondary);
  });

  testWidgets('SheenStepsLine: done shows a check, current is selected, next is muted', (t) async {
    // The test font draws every glyph as a square, so give it the room real text would need.
    await t.pumpWidget(
      app(const SizedBox(width: 420, child: SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 1))),
    );
    expect(find.byType(SheenIcon), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(t.widget<Text>(find.text('Payment')).style!.color, SheenColors.dark().textSecondary);
    expect(t.widget<Text>(find.text('Guests')).style!.color, SheenColors.dark().text);
    final guests = t.getSemantics(find.text('Guests'));
    expect(guests.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('SheenStepsLine lights the lines up to the current step, as the boards do', (t) async {
    Color lineColor(WidgetTester t, int i) {
      final lines = t.widgetList<Container>(
        find.descendant(
          of: find.byType(SheenStepsLine),
          matching: find.byWidgetPredicate((w) => w is Container && w.margin != null),
        ),
      );
      return (lines.elementAt(i).decoration! as BoxDecoration).color!;
    }

    await t.pumpWidget(
      app(const SizedBox(width: 420, child: SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 1))),
    );
    expect(lineColor(t, 0), SheenThemeData.dark().colors.accentText);
    expect(lineColor(t, 1), SheenThemeData.dark().colors.track);
    await t.pumpWidget(
      app(const SizedBox(width: 420, child: SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 2))),
    );
    expect(lineColor(t, 1), SheenThemeData.dark().colors.accentText);
  });

  testWidgets('SheenStepsLine keeps only the current label when the labels do not fit', (t) async {
    await t.pumpWidget(
      app(
        const SizedBox(width: 300, child: SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 1)),
        scale: 2.4,
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('Payment'), findsNothing);
  });

  testWidgets('SheenListGroup rows: icon tile, value, chevron; tap; the chevron mirrors in RTL', (t) async {
    var n = 0;
    Widget group(TextDirection d) => app(
      SizedBox(
        width: 358,
        child: SheenListGroup(
          children: [
            SheenListRow(title: 'Bookings', icon: 'suitcase', iconColor: const Color(0xFF1F6FEB), onTap: () => n++),
            SheenListRow(
              title: 'Currency',
              icon: 'card',
              iconColor: const Color(0xFF0090A8),
              value: 'USD',
              onTap: () {},
            ),
            SheenListRow(
              title: 'Notifications',
              icon: 'bell',
              iconColor: const Color(0xFF30A46C),
              trailing: SheenSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Notifications'),
            ),
          ],
        ),
      ),
      dir: d,
    );
    await t.pumpWidget(group(TextDirection.ltr));
    expect(find.text('USD'), findsOneWidget);
    // The value and the chevron sit at the end edge, not after a half-width title.
    final row = t.getRect(find.byType(SheenListRow).at(1));
    expect(
      t.getRect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == 'chevron').at(1)).right,
      closeTo(row.right - 14, .5),
    );
    expect(find.byType(SheenSwitch), findsOneWidget);
    expect(t.getSize(find.byType(SheenListRow).first).height, greaterThanOrEqualTo(50));
    await t.tap(find.text('Bookings'));
    expect(n, 1);
    final mid = t.getRect(find.byType(SheenListGroup)).center.dx;
    final chevLtr = t.getRect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == 'chevron').first);
    await t.pumpWidget(group(TextDirection.rtl));
    final chevRtl = t.getRect(find.byWidgetPredicate((w) => w is SheenIcon && w.name == 'chevron').first);
    expect(chevLtr.center.dx, greaterThan(mid));
    expect(chevRtl.center.dx, lessThan(mid));
  });

  testWidgets('SheenListRow subtitle: a second line under the title, read with it; none keeps the one-line row', (
    t,
  ) async {
    var n = 0;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 358,
          child: SheenListGroup(
            children: [
              SheenListRow(
                title: 'Privacy Policy',
                subtitle: 'Updated 4 October 2026',
                icon: 'shield',
                onTap: () => n++,
              ),
              SheenListRow(title: 'Terms', icon: 'document', onTap: () {}),
            ],
          ),
        ),
      ),
    );
    final title = t.getRect(find.text('Privacy Policy')), sub = t.getRect(find.text('Updated 4 October 2026'));
    expect(sub.top, greaterThanOrEqualTo(title.bottom));
    expect(sub.left, title.left);
    expect(find.bySemanticsLabel('Privacy Policy, Updated 4 October 2026'), findsOneWidget);
    expect(t.getSize(find.byType(SheenListRow).last).height, 50);
    await t.tap(find.text('Updated 4 October 2026'));
    expect(n, 1);
  });

  testWidgets('SheenListGroup: s1 on the page ground as cards, s2 inside a sheet, or the colour it is given', (
    t,
  ) async {
    final light = SheenThemeData.of(Brightness.light).colors;
    Color ground() =>
        (t
                    .widget<Container>(
                      find.descendant(of: find.byType(SheenCard), matching: find.byType(Container)).first,
                    )
                    .decoration!
                as BoxDecoration)
            .color!;
    await t.pumpWidget(
      app(
        const SheenListGroup(children: [SheenListRow(title: 'Guest 1')]),
        b: Brightness.light,
      ),
    );
    expect(ground(), light.surface);
    await t.pumpWidget(
      app(
        const SheenNested(
          child: SheenListGroup(children: [SheenListRow(title: 'Guest 1')]),
        ),
        b: Brightness.light,
      ),
    );
    expect(ground(), light.surfaceMuted);
    await t.pumpWidget(
      app(
        SheenListGroup(
          color: light.track,
          children: const [SheenListRow(title: 'Guest 1')],
        ),
        b: Brightness.light,
      ),
    );
    expect(ground(), light.track);
    await t.pumpWidget(
      app(
        SizedBox(
          width: 390,
          height: 400,
          child: SheenSheetBody(
            title: 'Room 1 · Guest 1',
            cancelLabel: 'Cancel',
            onCancel: () {},
            child: const SheenListGroup(children: [SheenListRow(title: 'Mira')]),
          ),
        ),
        b: Brightness.light,
      ),
    );
    BoxDecoration box() =>
        t
                .widget<Container>(find.descendant(of: find.byType(SheenCard), matching: find.byType(Container)).first)
                .decoration!
            as BoxDecoration;
    expect(
      (box().color, box().boxShadow),
      (light.surfaceMuted, null),
      reason: 'a sheet body makes its content nested: grey and flat',
    );
    await t.pumpWidget(
      app(
        const SheenListGroup(children: [SheenListRow(title: 'Guest 1')]),
        b: Brightness.light,
      ),
    );
    expect(
      (box().color, box().boxShadow?.length),
      (light.surface, 2),
      reason: 'on the page ground: white with the card shadow',
    );
  });

  testWidgets('SheenEmptyState, SheenSuggestionCard, SheenProgressCapsule and SheenPricePin', (t) async {
    var picked = 0;
    await t.pumpWidget(
      app(
        SizedBox(
          width: 358,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheenEmptyState(
                icon: 'search',
                title: 'No Results',
                message: 'Unfortunately, there are no hotels available.',
              ),
              SheenSuggestionCard(title: 'Clear all filters', subtitle: 'All 234 stays', onTap: () => picked++),
              const SheenProgressCapsule(label: 'Checking live prices'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SheenPricePin(label: '1,448', selected: false, onTap: () {}),
                  SheenPricePin(label: '1,422', selected: true, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('No Results'), findsOneWidget);
    await t.tap(find.text('Clear all filters'));
    expect(picked, 1);
    expect(find.byType(SheenSpinner), findsOneWidget);
    expect(find.bySemanticsLabel('Checking live prices'), findsOneWidget);
    final pins = find.byType(SheenPricePin);
    expect(t.getSize(find.descendant(of: pins.at(0), matching: find.byType(SheenGlass))).height, 30);
    expect(t.getSize(find.descendant(of: pins.at(1), matching: find.byType(SheenGlass))).height, 34);
    expect(
      t.widget<SheenGlass>(find.descendant(of: pins.at(1), matching: find.byType(SheenGlass))).variant,
      SheenGlassVariant.prominent,
    );
  });

  testWidgets('SheenEmptyState fits at text scale 2', (t) async {
    await t.pumpWidget(
      app(
        const SizedBox(
          width: 334,
          child: SheenEmptyState(
            icon: 'search',
            title: 'No Results',
            message: 'Unfortunately, there are no hotels available.',
          ),
        ),
        scale: 2,
      ),
    );
    expect(t.takeException(), isNull);
  });
}
