import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Opens a long text, such as terms or a policy, in a large sheet with a close button.
///
/// Pass [text] for plain text, or [children] for your own content (headings, [SheenAccordion]s).
///
/// ```dart
/// showSheenDocumentSheet(context, title: 'Terms of use', text: terms);
/// ```
///
/// {@category Sheets}
Future<void> showSheenDocumentSheet(
  BuildContext context, {
  required String title,
  String? text,
  List<Widget> children = const [],
  String? closeLabel,
}) => showSheenCustomSheet<void>(
  context: context,
  builder: (sheetContext, scroll) => Builder(
    builder: (context) {
      final t = context.sheen;
      return SheenSheetBody(
        title: title,
        cancelLabel: closeLabel ?? SheenStrings.of(context).close,
        onCancel: () => Navigator.of(sheetContext).pop(),
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.paddingOf(context).bottom + 40),
          children: [
            if (text != null) Text(text, style: t.type.subhead.copyWith(color: t.colors.text, height: 1.45)),
            ...children,
          ],
        ),
      );
    },
  ),
);
