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

  test('premium cards say how tall a carousel row must be for the text size', () {
    expect(
      SheenPremiumCard.heightFor(const TextScaler.linear(2)),
      greaterThan(SheenPremiumCard.heightFor(TextScaler.noScaling)),
    );
  });
}
