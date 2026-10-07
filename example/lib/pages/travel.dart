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
  bool _saved = false;
  int _pin = 1;

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Travel',
    subtitle: 'import \'package:sheen/travel.dart\'',
    children: [
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
    ],
  );
}
