import 'package:flutter/material.dart';

import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';

/// One choice of a [SheenChoiceList]: its [value], how it reads, and a short [tag] before it (a currency's code).
///
/// {@category Selection}
@immutable
class SheenChoice<T> {
  /// A choice of [value] titled [title].
  const SheenChoice({required this.value, required this.title, this.detail, this.tag});

  /// What picking the choice returns.
  final T value;

  /// The choice's name.
  final String title;

  /// A second line under the title.
  final String? detail;

  /// A short code before the title, such as "EUR".
  final String? tag;
}

/// Opens a sheet with a [SheenChoiceList] and returns the picked value, or null when the sheet is closed.
///
/// Use it for languages, currencies, countries, sort orders: any single choice from a list. Long lists get a filter
/// field; [suggested] values come first under [suggestedLabel], the whole list under [allLabel], and [note] closes the
/// list.
///
/// ```dart
/// final code = await showSheenChoiceSheet<String>(
///   context,
///   title: 'Currency',
///   current: 'EUR',
///   choices: [for (final c in currencies) SheenChoice(value: c.code, title: c.name, tag: c.code)],
/// );
/// ```
///
/// {@category Selection}
Future<T?> showSheenChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheenChoice<T>> choices,
  T? current,
  List<T> suggested = const [],
  String? suggestedLabel,
  String? allLabel,
  String? note,
}) => showSheenCustomSheet<T>(
  context: context,
  builder: (sheetContext, scroll) => SheenSheetBody(
    title: title,
    onCancel: () => Navigator.of(sheetContext).pop(),
    child: SheenChoiceList<T>(
      choices: choices,
      current: current,
      suggested: suggested,
      suggestedLabel: suggestedLabel,
      allLabel: allLabel,
      note: note,
      scroll: scroll,
      onPick: (v) => Navigator.of(sheetContext).pop(v),
    ),
  ),
);

/// A list of choices with the current one ticked, as [showSheenChoiceSheet] shows it; usable on its own in a page.
///
/// A list longer than [filterFrom] gets a filter field that matches the title, the detail or the tag. While nothing
/// is typed, [suggested] values come first under [suggestedLabel], then the whole list under [allLabel], then [note].
///
/// {@category Selection}
class SheenChoiceList<T> extends StatefulWidget {
  /// A list of [choices].
  const SheenChoiceList({
    super.key,
    required this.choices,
    required this.onPick,
    this.current,
    this.scroll,
    this.suggested = const [],
    this.suggestedLabel,
    this.allLabel,
    this.note,
    this.filterHint,
  });

  /// The choices, in the order to show them.
  final List<SheenChoice<T>> choices;

  /// The current value, ticked.
  final T? current;

  /// Values shown first while nothing is typed, such as the current and the recently picked ones.
  final List<T> suggested;

  /// The heading over [suggested].
  final String? suggestedLabel;

  /// The heading over the whole list when there are suggestions.
  final String? allLabel;

  /// A line after the list.
  final String? note;

  /// The filter field's hint; [SheenStrings.search] when null.
  final String? filterHint;

  /// Called with the tapped choice's value.
  final ValueChanged<T> onPick;

  /// The list's scroll controller (a sheet's, inside [showSheenCustomSheet]).
  final ScrollController? scroll;

  /// A list longer than this gets the filter field.
  static const int filterFrom = 12;

  /// The choices whose title, detail or tag contains [query], case aside.
  static List<SheenChoice<T>> filter<T>(List<SheenChoice<T>> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return [
      for (final c in all)
        if ([c.title, c.detail, c.tag].whereType<String>().any((s) => s.toLowerCase().contains(q))) c,
    ];
  }

  @override
  State<SheenChoiceList<T>> createState() => _SheenChoiceListState<T>();
}

class _SheenChoiceListState<T> extends State<SheenChoiceList<T>> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final strings = SheenStrings.of(context);
    final w = widget;
    final typed = _query.text.trim().isNotEmpty;
    final shown = SheenChoiceList.filter(w.choices, _query.text);
    final first = typed
        ? <SheenChoice<T>>[]
        : [
            for (final v in w.suggested)
              for (final c in w.choices.where((c) => c.value == v).take(1)) c,
          ];
    // one flat list of headings, rows and the note: the suggestions, then everything, while nothing is typed
    final items = <Object>[
      if (first.isNotEmpty) ...[
        if (w.suggestedLabel != null) _Heading(w.suggestedLabel!),
        ...first,
        if (w.allLabel != null) _Heading(w.allLabel!),
      ],
      ...shown,
      if (w.note != null && !typed) _Note(w.note!),
    ];
    return Column(
      children: [
        if (w.choices.length > SheenChoiceList.filterFrom)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Container(
              height: 40,
              padding: EdgeInsetsDirectional.only(start: 12, end: _query.text.isEmpty ? 12 : 2),
              decoration: BoxDecoration(color: t.colors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  SheenIcon(SheenIcons.search, size: 18, stroke: 2.2, color: t.colors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SheenMaterialBridge(
                      child: TextField(
                        controller: _query,
                        onChanged: (_) => setState(() {}),
                        autocorrect: false,
                        textInputAction: TextInputAction.search,
                        keyboardAppearance: t.brightness,
                        cursorColor: t.colors.accentText,
                        style: t.type.body.copyWith(color: t.colors.text),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: w.filterHint ?? strings.search,
                          hintStyle: t.type.body.copyWith(color: t.colors.textTertiary),
                        ),
                      ),
                    ),
                  ),
                  // a clear button once there is text; the keyboard stays
                  if (_query.text.isNotEmpty)
                    SheenPressable(
                      onTap: () => setState(_query.clear),
                      semanticLabel: strings.clear,
                      minSize: 40,
                      child: SizedBox.square(
                        dimension: 36,
                        child: Center(
                          child: SheenIcon(SheenIcons.xCircle, size: 18, stroke: 2, color: t.colors.textTertiary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: w.scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              if (item is _Heading) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, i == 0 ? 4 : 18, 20, 6),
                  child: Semantics(
                    header: true,
                    child: Text(
                      item.text,
                      style: t.type.footnote.copyWith(color: t.colors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }
              if (item is _Note) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(item.text, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
                );
              }
              final c = item as SheenChoice<T>;
              final on = c.value == w.current;
              return SheenPressable(
                pressedScale: 1,
                selected: on,
                semanticLabel: [c.title, if (c.detail != null) c.detail!].join(', '),
                onTap: () => w.onPick(c.value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        if (c.tag != null) ...[
                          SizedBox(
                            width: 44,
                            child: Text(
                              c.tag!,
                              style: t.type
                                  .sized(t.type.footnote, 13)
                                  .copyWith(color: t.colors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: t.type.body.copyWith(color: t.colors.text)),
                              if (c.detail != null)
                                Text(c.detail!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
                            ],
                          ),
                        ),
                        if (on) SheenIcon(SheenIcons.check, size: 18, stroke: 2.4, color: t.colors.accentText),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Heading {
  const _Heading(this.text);
  final String text;
}

class _Note {
  const _Note(this.text);
  final String text;
}

/// A pull-down link: a short label in the accent colour with a chevron, such as "USD ▾" next to a list of prices, that
/// opens a choice (usually [showSheenChoiceSheet]). A 44-point target.
///
/// Give it a [semanticLabel] that says what it changes, such as "Prices in USD. Change the currency".
///
/// {@category Selection}
class SheenPullDownLink extends StatelessWidget {
  /// A link showing [label].
  const SheenPullDownLink({super.key, required this.label, required this.onTap, this.semanticLabel});

  /// The current value, short.
  final String label;

  /// Called on a tap.
  final VoidCallback onTap;

  /// What a screen reader says; [label] when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onTap,
      minSize: 44,
      semanticLabel: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: t.type.footnote.copyWith(color: t.colors.accentText, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 3),
                SheenIcon(SheenIcons.chevronDown, size: 13, stroke: 2.4, color: t.colors.accentText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
