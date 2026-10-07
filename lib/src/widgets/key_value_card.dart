import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// One row of a [SheenKeyValueCard].
///
/// {@category Content}
@immutable
class SheenKeyValue {
  /// A row naming [label] with [value].
  const SheenKeyValue(this.label, this.value, {this.onTap});

  /// What the row is, such as "Check-in".
  final String label;

  /// Its value, such as "Mon 20 Oct, from 15:00".
  final String value;

  /// Makes the value a link, in the accent colour.
  final VoidCallback? onTap;
}

/// A card of label and value rows with hairlines between them, such as a booking's details or a receipt.
///
/// An optional [header] (a photo, a title) sits on top. Each row reads as "label, value".
///
/// ```dart
/// SheenKeyValueCard(rows: const [
///   SheenKeyValue('Reference', 'RT-20418'),
///   SheenKeyValue('Check-in', 'Mon 20 Oct, from 15:00'),
/// ])
/// ```
///
/// {@category Content}
class SheenKeyValueCard extends StatelessWidget {
  /// A card of [rows].
  const SheenKeyValueCard({super.key, required this.rows, this.header});

  /// The rows.
  final List<SheenKeyValue> rows;

  /// Content above the rows.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final style = t.type.sized(t.type.subhead, 14);
    return SheenCard(
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Column(
              children: [
                for (final (i, r) in rows.indexed)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: i == 0 ? null : Border(top: BorderSide(color: t.colors.separator, width: .5)),
                    ),
                    child: SheenPressable(
                      onTap: r.onTap,
                      pressedScale: 1,
                      semanticLabel: '${r.label}, ${r.value}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.label, style: style.copyWith(color: t.colors.textSecondary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.value,
                                textAlign: TextAlign.end,
                                style: style.copyWith(
                                  color: r.onTap == null ? t.colors.text : t.colors.accentText,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
