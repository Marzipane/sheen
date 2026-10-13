import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

import '../backdrops.dart';
import '../demo.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  /// `--dart-define=OPEN=deals` puts the deals first (the pub.dev screenshot).
  static const String _open = String.fromEnvironment('OPEN');

  bool _saved = false;
  bool _dealSaved = false;
  int _pin = 1;

  /// A stay on a deal: the badge on the photo, the price before the deal struck through, and when it ends.
  Widget _deals(BuildContext context) => Demo(
    title: 'On a deal',
    note: 'Show the struck price only for the same stay without the deal.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheenHotelCard(
          name: 'Palace Downtown',
          total: 'AED 1,186.01',
          wasTotal: 'AED 1,210.21',
          wasLabel: 'was AED 1,210.21',
          deal: '−15%',
          dealNote: 'Ends Sun 18 Oct',
          headline: '4.0 km from the centre',
          score: '9.4',
          recommend: '98% recommend',
          board: 'Room only',
          photoCount: 3,
          photoBuilder: (_, i) => GeneratedPhoto(seed: i + 6),
          noPhotoLabel: 'No photo',
          saveLabel: 'Save',
          saved: _dealSaved,
          onSave: () => setState(() => _dealSaved = !_dealSaved),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: SheenPremiumCard.heightFor(MediaQuery.textScalerOf(context), note: true),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final (i, (name, total, was, deal)) in [
                ('Hotel Mirador', '€ 2,355.18', '€ 2,770.80', '−15%'),
                ('Casa do Rio', '€ 1,303.20', '€ 1,448.00', '−10%'),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: 12),
                SheenPremiumCard(
                  name: name,
                  total: total,
                  wasTotal: was,
                  deal: deal,
                  dealNote: 'Ends Wed 21 Oct',
                  nightsLabel: '2 nights',
                  score: '9.2',
                  headline: 'Old town',
                  photo: GeneratedPhoto(seed: i + 2),
                  saveLabel: 'Save',
                  onSave: () {},
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SheenPriceBlock(total: 'AED 1,186.01', caption: '1 night', wasTotal: 'AED 1,210.21'),
        const SizedBox(height: 10),
        const Gap(
          children: [SheenDealBadge('−15%'), SheenDealBadge('−15%', small: true), SheenWasPrice('AED 1,210.21')],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Travel',
    subtitle: 'import \'package:sheen/travel.dart\'',
    children: [
      if (_open == 'deals') _deals(context),
      Demo(
        title: 'Hotel card',
        child: SheenHotelCard(
          name: 'Casa do Rio',
          total: '€ 1,448.00',
          perNight: '€ 724.00 a night',
          headline: 'Riverside · 0.4 km to the old town',
          score: '9.1',
          recommend: '94% recommend',
          board: 'Breakfast included',
          cancellation: 'Free cancellation until Sat 17 Oct',
          refundable: true,
          photoCount: 4,
          photoBuilder: (_, i) => GeneratedPhoto(seed: i),
          noPhotoLabel: 'No photo',
          saveLabel: 'Save',
          saved: _saved,
          onSave: () => setState(() => _saved = !_saved),
          onTap: () {},
        ),
      ),
      const Demo(title: 'While prices load', child: SheenHotelCardSkeleton()),
      Demo(
        title: 'Featured stays and destinations',
        child: SizedBox(
          height: SheenPremiumCard.heightFor(MediaQuery.textScalerOf(context)),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SheenPremiumCard(
                name: 'Hotel Mirador',
                total: '€ 2,770.80',
                nightsLabel: '2 nights',
                score: '9.4',
                headline: 'Old town',
                photo: const GeneratedPhoto(seed: 3),
                saveLabel: 'Save',
                onSave: () {},
                onTap: () {},
              ),
              const SizedBox(width: 12),
              SheenCityTile(
                name: 'Istanbul',
                distance: '3 h 40 min',
                rule: 'Visa-free',
                kind: SheenVisaKind.free,
                photo: const GeneratedPhoto(seed: 5),
                onTap: () {},
              ),
              const SizedBox(width: 12),
              SheenCityTile(
                name: 'London',
                rule: 'eTA',
                kind: SheenVisaKind.eta,
                photo: const GeneratedPhoto(seed: 1),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      const Demo(
        title: 'Price and terms',
        child: Column(
          children: [
            SheenPriceBlock(total: '€ 1,448.00', caption: 'Total for 2 nights', perNight: '€ 724.00 a night'),
            SizedBox(height: 10),
            SheenCancellationLine(text: 'Free cancellation until Wed 14 Oct', refundable: true),
            SheenCancellationLine(text: 'Non-refundable', refundable: false),
            SizedBox(height: 10),
            Gap(
              children: [
                SheenScoreBadge('9.1', size: SheenScoreSize.small),
                SheenScoreBadge('9.1'),
                SheenScoreBadge('9.1', size: SheenScoreSize.large),
              ],
            ),
          ],
        ),
      ),
      Demo(
        title: 'Map pins',
        note: 'For native maps, renderSheenPricePin draws the same pin as a bitmap.',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SheenRadius.card),
          child: SizedBox(
            height: 140,
            child: Stack(
              children: [
                const GeneratedPhoto(seed: 1),
                Center(
                  child: Gap(
                    children: [
                      for (final (i, p) in ['€ 724', '€ 1,448', '€ 512'].indexed)
                        SheenPricePin(label: p, selected: _pin == i, onTap: () => setState(() => _pin = i)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (_open != 'deals') _deals(context),
      _trips(context),
    ],
  );

  /// Tours and cruises: cards for a carousel and the days or ports of one.
  Widget _trips(BuildContext context) => Demo(
    title: 'Tours & cruises',
    note: 'Prices from the lowest departure; say what they are for.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: SheenTripCard.heightFor(MediaQuery.textScalerOf(context)),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SheenTripCard(
                title: 'Istanbul, Cappadocia and Ephesus',
                eyebrow: 'Europamundo',
                facts: '8 days · Turkey',
                price: 'from AED 2,872',
                priceLabel: 'a person',
                tag: 'Guaranteed',
                photo: const GeneratedPhoto(seed: 3),
                onTap: () {},
              ),
              const SizedBox(width: 12),
              SheenTripCard(
                title: 'Greek Isles',
                eyebrow: 'Norwegian Viva',
                facts: '7 nights · from Piraeus',
                price: 'from AED 6,000',
                priceLabel: 'a person',
                tag: 'NCL',
                placeholderIcon: SheenIcons.ship,
                noPhotoLabel: 'No photo yet',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SheenItinerary(
          stops: [
            SheenItineraryStop(marker: '1', title: 'Piraeus (Athens)', subtitle: 'Greece', trailing: '— 17:00'),
            SheenItineraryStop(marker: '2', title: 'At sea', quiet: true),
            SheenItineraryStop(
              marker: '3',
              title: 'Mykonos',
              subtitle: 'Tender port',
              trailing: '07:00 – 16:00',
              detail: 'Whitewashed lanes, windmills and the beaches of the south coast.',
            ),
          ],
        ),
      ],
    ),
  );
}
