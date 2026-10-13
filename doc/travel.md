# Travel

`import 'package:sheen/travel.dart';`

Hotel cards (and their loading skeleton), featured cards, tour and cruise cards with their itinerary, city tiles with the visa rule, price blocks, cancellation
lines, score badges, deal badges with the price before the deal struck through, and map price pins, as widgets and as
bitmaps for native map markers. Prices and words are always yours.

![Travel](https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/09-travel.webp)

## Deals

![Deals](https://raw.githubusercontent.com/Marzipane/sheen/main/doc/screenshots/11-deals.webp)

`SheenHotelCard`, `SheenPremiumCard` and `SheenPriceBlock` take a deal: `deal` is the badge on the photo ("−15%"),
`wasTotal` the price before the deal, struck through, and `dealNote` a line such as "Ends Sun 18 Oct". On the hotel
card the struck price sits under the total, so a long hotel name keeps its width. `SheenDealBadge` and `SheenWasPrice`
are the same parts on their own, for a price bar or a map card.

Show a struck price only when it is the same stay without the deal: a struck "list price" the guest was never charged
misleads.

```dart
const SheenPriceBlock(total: 'AED 1,186.01', caption: '1 night', wasTotal: 'AED 1,210.21');

Row(children: [SheenDealBadge('−15%', small: true), SizedBox(width: 6), SheenWasPrice('AED 1,210.21')]);
```

## Tours and cruises

`SheenTripCard` is the size of `SheenPremiumCard`, for a carousel of tours or cruises: the photo (or a placeholder
with a compass or a ship), a tag on it such as the cruise line, a small line above the title (the operator or the
ship), the facts and the lowest price with what it is for. `SheenTripCard.heightFor` gives the row height at the
user's text size. On a deal, `deal` puts a badge on the photo and `wasPrice` strikes the usual price under the
price (`dealNote` follows it); pass `heightFor(scaler, note: true)` for a row with such a card. `SheenItinerary` lists a tour's days or a cruise's ports on a line of numbered dots; a quiet stop,
such as a day at sea, has a hollow dot.

```dart
SheenTripCard(
  title: 'Greek Isles',
  eyebrow: 'Norwegian Viva',
  facts: '7 nights · from Piraeus',
  price: 'from AED 6,000',
  priceLabel: 'a person',
  tag: 'NCL',
  placeholderIcon: SheenIcons.ship,
  onTap: () {},
);

const SheenItinerary(stops: [
  SheenItineraryStop(marker: '1', title: 'Piraeus (Athens)', trailing: '— 17:00'),
  SheenItineraryStop(marker: '2', title: 'At sea', quiet: true),
]);
```
