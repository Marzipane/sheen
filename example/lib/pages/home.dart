import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../backdrops.dart';
import '../catalog.dart';
import 'settings_sheet.dart';

/// The gallery's first page: a glass preview and the list of pages.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'sheen',
    subtitle: 'A glass design system for Flutter',
    trailing: SheenIconButton(
      icon: SheenIcons.sliders,
      semanticLabel: 'Gallery settings',
      onTap: () => showGallerySettings(context),
    ),
    children: [
      SheenPressable(
        onTap: () => Navigator.of(context).pushNamed('/glass'),
        semanticLabel: 'Open the glass showcase',
        pressedScale: .98,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SheenRadius.card),
          child: SizedBox(
            height: 180,
            child: Stack(
              children: [
                const GeneratedPhoto(seed: 2),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: SheenGlass(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            'Frosted glass, springs and 80+ widgets',
                            style: context.sheen.type.subhead.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SheenIconButton(
                        icon: SheenIcons.chevron,
                        semanticLabel: 'Open',
                        variant: SheenGlassVariant.prominent,
                        onTap: () => Navigator.of(context).pushNamed('/glass'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SheenSectionLabel('Widgets'),
      SheenListGroup(
        children: [
          for (final p in catalog)
            SheenListRow(
              title: p.title,
              subtitle: p.subtitle,
              icon: p.icon,
              iconColor: p.tint,
              onTap: () => Navigator.of(context).pushNamed('/${p.id}'),
            ),
        ],
      ),
      const SheenSectionNote('Everything here is drawn by Flutter: no images, no platform views, no Material.'),
    ],
  );
}
