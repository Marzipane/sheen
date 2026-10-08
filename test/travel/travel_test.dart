import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheen/travel.dart';

import '../helpers.dart';

Widget photo(BuildContext c, int i) => ColoredBox(color: Color(0xFF203040 + i * 0x101010));

final cases = <String, Widget>{
  'hotel card': SheenHotelCard(
    name: 'Hotel Aurora del Mar and Residences',
    total: 'USD 12,448.00',
    perNight: 'USD 6,224.00 a night',
    headline: 'Old Town · 0.4 km to the cathedral square',
    score: '9.1',
    recommend: '94% recommend',
    board: 'Breakfast included',
    cancellation: 'Free cancellation until Sat 17 Oct',
    refundable: true,
    photoCount: 3,
    photoBuilder: photo,
    noPhotoLabel: 'No photo',
    saveLabel: 'Save',
    onSave: () {},
    onTap: () {},
  ),
  'hotel card skeleton': const SheenHotelCardSkeleton(),
  'premium card': SheenPremiumCard(
    name: 'Casa do Rio',
    total: 'USD 2,770.80',
    nightsLabel: '2 nights',
    score: '9.4',
    headline: 'Near the river',
    saveLabel: 'Save',
    onSave: () {},
    onTap: () {},
  ),
  'city tile': SheenCityTile(
    name: 'Istanbul',
    distance: '3 h 40 min',
    rule: 'Visa-free · 90 days',
    kind: SheenVisaKind.free,
    onTap: () {},
  ),
  'price block': const SheenPriceBlock(
    total: 'USD 1,448.00',
    caption: 'Total for 2 nights',
    perNight: 'USD 724.00 a night',
  ),
  'cancellation': const SheenCancellationLine(text: 'Non-refundable', refundable: false),
  'score badges': const Row(
    children: [
      SheenScoreBadge('9.1', size: SheenScoreSize.small),
      SheenScoreBadge('9.1'),
      SheenScoreBadge('9.1', size: SheenScoreSize.large),
    ],
  ),
  'price pins': Row(
    children: [
      SheenPricePin(label: '1,422', selected: false, onTap: () {}),
      SheenPricePin(label: '1,448', selected: true, onTap: () {}),
    ],
  ),
};

void main() {
  for (final MapEntry(key: name, value: widget) in cases.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('$name at ${(scale * 100).round()} % text, right to left, does not overflow', (t) async {
        t.view.physicalSize = const Size(1170, 2532);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          host(
            SingleChildScrollView(child: SizedBox(width: 358, child: widget)),
            direction: TextDirection.rtl,
            textScale: scale,
            brightness: Brightness.dark,
          ),
        );
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets("a screen reader hears the score as the card's scoreLabel says it; the badge still shows the number", (
    t,
  ) async {
    await t.pumpWidget(
      host(
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 358,
                child: SheenHotelCard(
                  name: 'Aurora',
                  total: 'USD 1,448.00',
                  score: '4.4',
                  scoreLabel: 'Guest score 4.4 out of 5',
                  recommend: 'Very good · 92% recommend',
                  photoCount: 0,
                  photoBuilder: photo,
                  noPhotoLabel: 'No photo',
                  saveLabel: 'Save',
                  onTap: () {},
                ),
              ),
              SheenPremiumCard(
                name: 'Casa',
                total: 'USD 770.80',
                nightsLabel: '2 nights',
                score: '4.8',
                scoreLabel: 'Guest score 4.8 out of 5',
                saveLabel: 'Save',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Aurora, USD 1,448\.00, Guest score 4\.4 out of 5, Very good')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'Casa, Guest score 4\.8 out of 5, USD 770\.80')), findsOneWidget);
    expect(find.text('4.4'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
  });

  testWidgets('the score line is never cut for the board: the board moves under it when both do not fit', (t) async {
    const words = 'Wonderful · 87% recommend', board = 'Room only';
    Widget card(double width) => host(
      SizedBox(
        width: width,
        child: SheenHotelCard(
          name: 'Aurora',
          total: 'AED 1,448.00',
          score: '4.7',
          recommend: words,
          board: board,
          photoCount: 0,
          photoBuilder: photo,
          noPhotoLabel: 'No photo',
          saveLabel: 'Save',
          onTap: () {},
        ),
      ),
    );
    bool cut(String text) => t.renderObject<RenderParagraph>(find.text(text)).didExceedMaxLines;

    // with room for both, the board stays on the score's line, at its end
    await t.pumpWidget(card(780));
    expect(t.getCenter(find.text(board)).dy, closeTo(t.getCenter(find.text('4.7')).dy, 1));
    expect(t.getTopRight(find.text(board)).dx, closeTo(t.getTopRight(find.byType(SheenHotelCard)).dx - 16, 1));

    // room for the score and its words, not for the board beside them
    final cardLeft = t.getTopLeft(find.byType(SheenHotelCard)).dx;
    final badgeLeft = t.getTopLeft(find.byType(SheenScoreBadge)).dx;
    final padding = badgeLeft - cardLeft;
    await t.pumpWidget(card(padding + t.getTopRight(find.text(words)).dx - badgeLeft + 4 + padding));
    expect(cut(words), isFalse);
    expect(cut(board), isFalse);
    expect(t.getTopLeft(find.text(board)).dy, greaterThan(t.getBottomLeft(find.text(words)).dy));
  });

  test('premium cards say how tall a carousel row must be for the text size', () {
    expect(
      SheenPremiumCard.heightFor(const TextScaler.linear(2)),
      greaterThan(SheenPremiumCard.heightFor(TextScaler.noScaling)),
    );
  });
}
