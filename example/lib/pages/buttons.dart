import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../backdrops.dart';
import '../demo.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Buttons',
    children: [
      Demo(
        title: 'Primary',
        note: 'One per view. It darkens while pressed and shows a spinner while it works.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheenPrimaryButton(
              label: 'Continue',
              expand: true,
              loading: _loading,
              onPressed: () async {
                setState(() => _loading = true);
                await Future<void>.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _loading = false);
              },
            ),
            const SizedBox(height: 10),
            Gap(
              children: [
                SheenPrimaryButton(label: 'Pay', subLabel: '€ 1,448.00', onPressed: () {}),
                const SheenPrimaryButton(label: 'Disabled', onPressed: null),
              ],
            ),
          ],
        ),
      ),
      Demo(
        title: 'Secondary and text link',
        child: Gap(
          children: [
            SheenSecondaryButton(label: 'Pay with card', icon: SheenIcons.card, onPressed: () {}),
            SheenTextLink(label: 'See all 9', onPressed: () {}),
          ],
        ),
      ),
      Demo(
        title: 'Glass over a photo',
        note: 'Regular glass on bars, clear glass over photos, prominent glass for the one confirming action.',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SheenRadius.card),
          child: SizedBox(
            height: 150,
            child: Stack(
              children: [
                const GeneratedPhoto(seed: 4),
                Center(
                  child: Gap(
                    children: [
                      SheenIconButton(icon: SheenIcons.back, semanticLabel: 'Back', onTap: () {}),
                      SheenIconButton(
                        icon: SheenIcons.heart,
                        semanticLabel: 'Save',
                        variant: SheenGlassVariant.clear,
                        onTap: () {},
                      ),
                      SheenIconButton(
                        icon: SheenIcons.check,
                        semanticLabel: 'Done',
                        variant: SheenGlassVariant.prominent,
                        onTap: () {},
                      ),
                      SheenButtonGroup(
                        items: [
                          SheenButtonGroupItem(icon: SheenIcons.share, semanticLabel: 'Share', onTap: () {}),
                          SheenButtonGroupItem(icon: SheenIcons.more, semanticLabel: 'More', onTap: () {}),
                        ],
                      ),
                      SheenFloatingButton(label: 'Map', icon: SheenIcons.map, onPressed: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Demo(
        title: 'Action bar',
        child: SheenActionBar(value: '€ 1,448.00', caption: 'Total for 2 nights', actionLabel: 'Book', onAction: () {}),
      ),
    ],
  );
}
