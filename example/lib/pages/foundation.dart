import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final c = t.colors;
    final swatches = <(String, Color)>[
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceMuted', c.surfaceMuted),
      ('track', c.track),
      ('text', c.text),
      ('textSecondary', c.textSecondary),
      ('textTertiary', c.textTertiary),
      ('accent', c.accent),
      ('accentText', c.accentText),
      ('success', c.success),
      ('warning', c.warning),
      ('danger', c.danger),
      ('rating', c.rating),
    ];
    final styles = <(String, TextStyle)>[
      ('largeTitle', t.type.largeTitle),
      ('title', t.type.title),
      ('headline', t.type.headline),
      ('body', t.type.body),
      ('subhead', t.type.subhead),
      ('footnote', t.type.footnote),
      ('caption', t.type.caption),
      ('price', t.type.price),
    ];
    return SheenPage(
      title: 'Foundation',
      children: [
        Demo(
          title: 'Colours',
          note: 'context.sheen.colors. Every text colour reads at 4.5:1 on the background and on surfaces.',
          child: Gap(
            children: [
              for (final (name, color) in swatches)
                SizedBox(
                  width: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.separator),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(name, style: t.type.caption.copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Demo(
          title: 'Type',
          note: 'context.sheen.type. Sizes follow the reader\'s text size.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, style) in styles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(name, style: style.copyWith(color: c.text)),
                ),
            ],
          ),
        ),
        Demo(
          title: 'Icons',
          note: 'SheenIcons: ${SheenIcons.all.length} glyphs on a 24-point grid.',
          child: Gap(
            spacing: 14,
            children: [
              for (final n in SheenIcons.all)
                Semantics(
                  label: n,
                  child: SheenIcon(n, color: c.text),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
