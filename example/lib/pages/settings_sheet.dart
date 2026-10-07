import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../settings.dart';

/// The gallery's switches, in a sheet: appearance, direction, text size, transparency, motion and accent.
Future<void> showGallerySettings(BuildContext context) => showSheenCustomSheet<void>(
  context: context,
  startLarge: false,
  builder: (sheetContext, scroll) => SheenSheetBody(
    title: 'Gallery settings',
    onCancel: () => Navigator.of(sheetContext).pop(),
    child: ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: const [_Settings()],
    ),
  ),
);

class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) {
    final scope = GallerySettingsScope.of(context);
    final s = scope.settings;
    void set(GallerySettings next) => scope.update(next);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheenSectionLabel('Appearance', top: 4),
        SheenSegmentedControl(
          segments: const [SheenSegment('System'), SheenSegment('Light'), SheenSegment('Dark')],
          index: switch (s.brightness) {
            null => 0,
            Brightness.light => 1,
            Brightness.dark => 2,
          },
          onChanged: (i) => set(s.copyWith(brightness: () => [null, Brightness.light, Brightness.dark][i])),
        ),
        const SheenSectionLabel('Text size'),
        SheenSegmentedControl(
          segments: const [SheenSegment('100 %'), SheenSegment('150 %'), SheenSegment('200 %')],
          index: [1.0, 1.5, 2.0].indexOf(s.textScale).clamp(0, 2),
          onChanged: (i) => set(s.copyWith(textScale: [1.0, 1.5, 2.0][i])),
        ),
        const SheenSectionLabel('Accessibility'),
        SheenListGroup(
          children: [
            SheenListRow(
              title: 'Right to left',
              trailing: SheenSwitch(
                value: s.rtl,
                semanticLabel: 'Right to left',
                onChanged: (v) => set(s.copyWith(rtl: v)),
              ),
            ),
            SheenListRow(
              title: 'Reduce transparency',
              trailing: SheenSwitch(
                value: s.reduceTransparency,
                semanticLabel: 'Reduce transparency',
                onChanged: (v) => set(s.copyWith(reduceTransparency: v)),
              ),
            ),
            SheenListRow(
              title: 'Reduce motion',
              trailing: SheenSwitch(
                value: s.reduceMotion,
                semanticLabel: 'Reduce motion',
                onChanged: (v) => set(s.copyWith(reduceMotion: v)),
              ),
            ),
          ],
        ),
        const SheenSectionLabel('Accent'),
        Wrap(
          spacing: 12,
          children: [
            for (final MapEntry(key: name, value: (light, dark)) in GallerySettings.accents.entries)
              SheenPressable(
                onTap: () => set(s.copyWith(accent: name)),
                semanticLabel: '$name accent',
                selected: s.accent == name,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (context.sheen.isDark ? dark : light) ??
                        (context.sheen.isDark ? SheenColors.defaultDarkAccent : SheenColors.defaultLightAccent),
                    border: s.accent == name ? Border.all(color: context.sheen.colors.text, width: 3) : null,
                  ),
                ),
              ),
          ],
        ),
        const SheenSectionNote('One accent recolours prominent glass, buttons, selection, switches and links.'),
      ],
    );
  }
}
