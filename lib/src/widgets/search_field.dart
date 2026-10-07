import 'package:flutter/material.dart';

import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';

/// A search field in a glass capsule: the search glyph, the field and, while it has text, a clear button.
///
/// The clear button empties the field, reports the empty text through [onChanged] and keeps the keyboard up, so the
/// person can type again at once. It shows whenever the controller has text, whoever put it there.
///
/// ```dart
/// SheenSearchField(controller: query, hint: 'Search 803 stays by name', onChanged: filter)
/// ```
///
/// {@category Inputs}
class SheenSearchField extends StatefulWidget {
  /// A search field over [controller].
  const SheenSearchField({
    super.key,
    required this.controller,
    this.hint,
    this.clearLabel,
    this.onChanged,
    this.onSubmitted,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  /// Holds the search text.
  final TextEditingController controller;

  /// The hint shown while the field is empty; [SheenStrings.search] when null.
  final String? hint;

  /// The clear button's label for screen readers; [SheenStrings.clear] when null.
  final String? clearLabel;

  /// Called on every change, the clear button's empty text included.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard's search button is pressed; the keyboard is put away either way.
  final ValueChanged<String>? onSubmitted;

  /// Whether the keyboard corrects spelling; off by default, since searches are often names.
  final bool autocorrect;

  /// How the keyboard capitalises.
  final TextCapitalization textCapitalization;

  /// The field's focus node.
  final FocusNode? focusNode;

  @override
  State<SheenSearchField> createState() => _SheenSearchFieldState();
}

class _SheenSearchFieldState extends State<SheenSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(SheenSearchField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final strings = SheenStrings.of(context);
    final has = widget.controller.text.isNotEmpty;
    return MediaQuery.withNoTextScaling(
      child: SheenGlass(
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 14, end: has ? 2 : 14),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: SheenIcon(SheenIcons.search, size: 18, stroke: 2.2, color: t.colors.textSecondary),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SheenMaterialBridge(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      textInputAction: TextInputAction.search,
                      autocorrect: widget.autocorrect,
                      enableSuggestions: widget.autocorrect,
                      textCapitalization: widget.textCapitalization,
                      keyboardAppearance: t.brightness,
                      cursorColor: t.colors.accentText,
                      style: t.type.subhead.copyWith(color: t.colors.text, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: widget.hint ?? strings.search,
                        hintMaxLines: 1,
                        hintStyle: t.type.subhead.copyWith(color: t.colors.textSecondary),
                      ),
                      onChanged: widget.onChanged,
                      onSubmitted: (v) {
                        FocusScope.of(context).unfocus();
                        widget.onSubmitted?.call(v);
                      },
                    ),
                  ),
                ),
                if (has)
                  SheenPressable(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                    semanticLabel: widget.clearLabel ?? strings.clear,
                    minSize: 40,
                    child: SizedBox.square(
                      dimension: 40,
                      child: Center(
                        child: SheenIcon(SheenIcons.xCircle, size: 18, stroke: 2, color: t.colors.textTertiary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
