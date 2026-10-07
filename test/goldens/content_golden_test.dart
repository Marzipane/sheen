import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

import 'variants.dart';

void main() {
  familyGoldens('content', [
    (
      'SheenHotelCard',
      () => SizedBox(
        width: 358,
        child: SheenHotelCard(
          name: 'Casa do Rio',
          total: 'USD 1,422.17',
          perNight: '711.09 a night',
          headline: 'Near the river',
          score: '4.8',
          recommend: '94% recommend',
          board: 'Room only',
          cancellation: 'Free cancellation until Sat 17 Oct',
          refundable: true,
          photoCount: 5,
          photoBuilder: fakePhoto,
          noPhotoLabel: 'No photo yet',
          saveLabel: 'Save',
          onSave: () {},
          onTap: () {},
        ),
      ),
    ),
    (
      'SheenHotelCard · no photo',
      () => SizedBox(
        width: 358,
        child: SheenHotelCard(
          name: 'Hotel Sol',
          total: 'USD 1,453.61',
          perNight: '726.81 a night',
          headline: 'Near the old market',
          score: '3.0',
          board: 'Room only',
          cancellation: 'Non-refundable',
          photoCount: 0,
          photoBuilder: fakePhoto,
          noPhotoLabel: 'No photo yet',
          saveLabel: 'Save',
          onSave: () {},
          onTap: () {},
        ),
      ),
    ),
    ('SheenHotelCardSkeleton', () => const SizedBox(width: 358, child: SheenHotelCardSkeleton())),
    (
      'SheenPremiumCard · SheenCityTile',
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          SheenPremiumCard(
            name: 'Hotel Aurora',
            headline: 'Near the park',
            score: '4.7',
            total: 'USD 2,770.80',
            nightsLabel: '2 nights',
            photo: Builder(builder: (c) => fakePhoto(c, 1)),
            saveLabel: 'Save',
            onSave: () {},
            onTap: () {},
          ),
          SheenCityTile(
            name: 'Istanbul',
            rule: 'Visa-free',
            kind: SheenVisaKind.free,
            photo: Builder(builder: (c) => fakePhoto(c, 2)),
            width: 112,
            onTap: () {},
          ),
          SheenCityTile(
            name: 'London',
            rule: 'eTA',
            kind: SheenVisaKind.eta,
            photo: Builder(builder: (c) => fakePhoto(c, 3)),
            width: 112,
            onTap: () {},
          ),
          SheenCityTile(
            name: 'New York',
            rule: 'Visa required',
            kind: SheenVisaKind.required,
            width: 112,
            onTap: () {},
          ),
        ],
      ),
    ),
    (
      'Score · Price · Cancellation',
      () => const SizedBox(
        width: 340,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SheenScoreBadge('4.7', size: SheenScoreSize.small),
                SizedBox(width: 10),
                SheenScoreBadge('4.7'),
                SizedBox(width: 10),
                SheenScoreBadge('4.7', size: SheenScoreSize.large),
                SizedBox(width: 10),
                SheenStarRating(count: 5, semanticLabel: '5 stars'),
              ],
            ),
            SizedBox(height: 12),
            SheenScoreBar(label: 'Cleanliness', value: '4.8', fraction: .96),
            SizedBox(height: 16),
            SheenPriceBlock(total: 'USD 2,770.80', caption: 'Total for 2 nights', perNight: '1,385.40 a night'),
            SizedBox(height: 10),
            SheenCancellationLine(text: 'Free cancellation until Wed 14 Oct', refundable: true),
            SizedBox(height: 6),
            SheenCancellationLine(text: 'Non-refundable', refundable: false),
          ],
        ),
      ),
    ),
    (
      'SheenStepsLine',
      () => const SizedBox(
        width: 340,
        child: Column(
          children: [
            SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 0),
            SizedBox(height: 20),
            SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 1),
            SizedBox(height: 20),
            SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 2),
          ],
        ),
      ),
    ),
    (
      'SheenListGroup',
      () => SizedBox(
        width: 358,
        child: SheenListGroup(
          children: [
            SheenListRow(title: 'Bookings', icon: 'suitcase', iconColor: const Color(0xFF1F6FEB), onTap: () {}),
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
    ),
    (
      'Empty · Progress · Pins',
      () => SizedBox(
        width: 358,
        child: Column(
          children: [
            const SheenEmptyState(
              icon: 'search',
              title: 'No Results',
              message: 'Unfortunately, there are no hotels available matching your search criteria.',
            ),
            const SizedBox(height: 14),
            SheenSuggestionCard(title: 'Clear all filters', subtitle: 'All 234 stays', onTap: () {}),
            const SizedBox(height: 14),
            overPhoto(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SheenProgressCapsule(label: 'Checking live prices', compact: true),
                  const SizedBox(width: 8),
                  SheenPricePin(label: '1,448', selected: false, onTap: () {}),
                  const SizedBox(width: 6),
                  SheenPricePin(label: '1,422', selected: true, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ]);
}
