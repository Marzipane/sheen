# Travel

`import 'package:sheen/travel.dart';`

Hotel cards (and their loading skeleton), featured cards, city tiles with the visa rule, price blocks, cancellation
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
