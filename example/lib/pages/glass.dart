import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../backdrops.dart';

/// Glass over a photo: the toolbar, glass and lens, the three kinds of glass, the tab bar.
class GlassShowcase extends StatefulWidget {
  const GlassShowcase({super.key});

  @override
  State<GlassShowcase> createState() => _GlassShowcaseState();
}

class _GlassShowcaseState extends State<GlassShowcase> {
  int _tab = 0, _segment = 1;
  bool _saved = true, _minimized = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final pad = MediaQuery.paddingOf(context);
    final inset = context.contentInset;
    return Stack(
      children: [
        const Positioned.fill(child: GeneratedPhoto(seed: 0)),
        Positioned(
          left: inset,
          right: inset,
          top: pad.top + 7,
          child: SheenToolbar(
            padding: EdgeInsets.zero,
            leading: SheenIconButton(
              icon: SheenIcons.back,
              semanticLabel: 'Back',
              variant: SheenGlassVariant.clear,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            center: SheenToolbarSummary(title: 'Lisbon', subtitle: '20–22 Oct · 2 guests', onTap: () {}),
            trailing: SheenButtonGroup(
              variant: SheenGlassVariant.clear,
              items: [
                SheenButtonGroupItem(icon: SheenIcons.share, semanticLabel: 'Share', onTap: () {}),
                SheenButtonGroupItem(
                  icon: SheenIcons.heart,
                  filled: _saved,
                  semanticLabel: 'Save',
                  color: _saved ? SheenTint.red : null,
                  onTap: () => setState(() => _saved = !_saved),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: inset,
          right: inset,
          top: pad.top + 84,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheenGlass(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Casa do Rio', style: t.type.title.copyWith(color: t.colors.text)),
                    const SizedBox(height: 2),
                    Text(
                      'Riverside · 0.4 km to the old town',
                      style: t.type.subhead.copyWith(color: t.colors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    SheenSegmentedControl(
                      segments: const [SheenSegment('Rooms'), SheenSegment('Details'), SheenSegment('Reviews')],
                      index: _segment,
                      onChanged: (i) => setState(() => _segment = i),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SheenGlass(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text('Regular', style: t.type.subhead.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  SheenGlass(
                    variant: SheenGlassVariant.clear,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Clear',
                      style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: SheenOnPhoto.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SheenGlass(
                    variant: SheenGlassVariant.prominent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Prominent',
                      style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: t.colors.onAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: SheenFloatingButton(
                  label: _minimized ? 'Show the full bar' : 'Minimise the bar',
                  icon: SheenIcons.swap,
                  onPressed: () => setState(() => _minimized = !_minimized),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: inset,
          right: inset,
          bottom: pad.bottom + 12,
          child: Center(
            child: SheenTabBar(
              items: const [
                SheenTabItem(icon: 'home', label: 'Home'),
                SheenTabItem(icon: 'map', label: 'Map'),
                SheenTabItem(icon: 'heart', label: 'Saved', badge: '2'),
                SheenTabItem(icon: 'user', label: 'Profile'),
              ],
              index: _tab,
              onSelect: (i) => setState(() => _tab = i),
              onSearch: () {},
              minimized: _minimized,
              accessory: _minimized
                  ? const SheenTabAccessory(
                      title: 'Room held',
                      subtitle: 'Casa do Rio',
                      trailing: SheenCountdownPill(
                        remaining: Duration(minutes: 12, seconds: 48),
                        semanticLabel: 'Held for',
                      ),
                    )
                  : null,
              onRestore: () => setState(() => _minimized = false),
            ),
          ),
        ),
      ],
    );
  }
}
