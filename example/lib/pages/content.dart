import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../backdrops.dart';
import '../demo.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _card = 0, _faq = 0, _total = 1448;
  bool _wifi = true;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPage(
      title: 'Content',
      children: [
        Demo(
          title: 'Grouped list',
          child: SheenListGroup(
            children: [
              SheenListRow(title: 'Bookings', icon: SheenIcons.suitcase, iconColor: SheenTint.blue, onTap: () {}),
              SheenListRow(
                title: 'Currency',
                value: 'EUR',
                icon: SheenIcons.coin,
                iconColor: SheenTint.teal,
                onTap: () {},
              ),
              SheenListRow(
                title: 'Wi-Fi only',
                subtitle: 'Download maps on Wi-Fi',
                icon: SheenIcons.wifi,
                iconColor: SheenTint.green,
                trailing: SheenSwitch(
                  value: _wifi,
                  semanticLabel: 'Wi-Fi only',
                  onChanged: (v) => setState(() => _wifi = v),
                ),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Card with photos',
          child: SheenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      SheenPhotoPager(count: 4, photoBuilder: (_, i) => GeneratedPhoto(seed: i + 1)),
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: SheenSaveButton(saved: true, onTap: () {}, semanticLabel: 'Save'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text('Swipe the photos', style: t.type.headline.copyWith(color: t.colors.text)),
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Card swiper',
          note: 'Swipe sideways for the next card.',
          child: SheenCardSwiper(
            count: 4,
            index: _card,
            onChanged: (i) => setState(() => _card = i),
            itemBuilder: (_, i) => SheenCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SheenAvatar(name: ['Ada Lovelace', 'Grace Hopper', 'Alan Turing', 'Katherine Johnson'][i]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Card ${i + 1} of 4', style: t.type.headline.copyWith(color: t.colors.text)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Demo(
          title: 'Accordion',
          child: Column(
            children: [
              for (final (i, (q, a)) in [
                ('Can I cancel?', 'Yes, for free until the day before arrival.'),
                ('Is breakfast included?', 'Only where the offer says so.'),
                ('When do I pay?', 'Now, or at the hotel when the offer allows it.'),
              ].indexed)
                SheenAccordion(
                  title: q,
                  open: _faq == i,
                  onChanged: (o) => setState(() => _faq = o ? i : -1),
                  child: Text(a),
                ),
            ],
          ),
        ),
        const Demo(
          title: 'Details',
          child: SheenKeyValueCard(
            rows: [
              SheenKeyValue('Reference', 'RT-20418'),
              SheenKeyValue('Check-in', 'Mon 20 Oct, from 15:00'),
              SheenKeyValue('Check-out', 'Wed 22 Oct, until 11:00'),
              SheenKeyValue('Guests', '2 adults'),
            ],
          ),
        ),
        const Demo(
          title: 'Avatars, ratings and steps',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(
                children: [
                  SheenAvatar(name: 'Ada Lovelace'),
                  SheenAvatar(name: 'Grace Hopper'),
                  SheenAvatar(name: 'Alan Turing', size: 32),
                  SheenAvatar(),
                  SheenStarRating(count: 4, semanticLabel: '4 stars'),
                ],
              ),
              SizedBox(height: 14),
              SheenScoreBar(label: 'Cleanliness', value: '9.2', fraction: .92),
              SizedBox(height: 14),
              SheenStepsLine(steps: ['Room', 'Guests', 'Payment'], current: 1),
            ],
          ),
        ),
        Demo(
          title: 'Rolling digits',
          child: Row(
            children: [
              SheenRollingDigits('€ $_total', style: t.type.sized(t.type.price, 24).copyWith(color: t.colors.text)),
              const Spacer(),
              SheenTextLink(label: 'Add a night', onPressed: () => setState(() => _total += 724)),
            ],
          ),
        ),
      ],
    );
  }
}
