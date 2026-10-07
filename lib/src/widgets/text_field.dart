import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';

/// A labelled text field: the label above, a 50-point field with 14-point corners and a hairline ring; focused, a
/// 2-point accent ring; with an [error], a red ring and the message under it.
///
/// A password hides its text ([obscureText]) and can carry a show/hide button in [trailing]; a picker field
/// ([readOnly]) opens its picker through [onTap] and takes no typing.
/// ```dart
/// SheenTextField(
///   label: 'Email',
///   controller: email,
///   keyboardType: TextInputType.emailAddress,
///   autofillHints: const [AutofillHints.email],
///   error: emailError,
/// )
/// ```
/// It is built on Flutter's `TextField` and works under `MaterialApp`, `CupertinoApp` and `WidgetsApp`.
///
/// {@category Inputs}
class SheenTextField extends StatefulWidget {
  /// A text field labelled [label].
  const SheenTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.error,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.words,
    this.focusNode,
    this.enabled = true,
    this.inputFormatters,
    this.fill,
    this.obscureText = false,
    this.trailing,
    this.readOnly = false,
    this.onTap,
    this.onSubmitted,
    this.autocorrect = true,
    this.labelTrailing,
  });

  /// The label above the field.
  final String label;

  /// The hint shown while the field is empty.
  final String? placeholder;

  /// Holds the text; the field makes its own when null.
  final TextEditingController? controller;

  /// An error message; it turns the ring red and shows under the field.
  final String? error;

  /// At the end of the label's line: a quiet note (Optional) or a small action (Clear).
  final Widget? labelTrailing;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// The keyboard to show.
  final TextInputType? keyboardType;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// What the system may autofill (see `AutofillHints`).
  final Iterable<String>? autofillHints;

  /// How the keyboard capitalises.
  final TextCapitalization textCapitalization;

  /// The field's focus node; the field makes its own when null.
  final FocusNode? focusNode;

  /// Whether the field takes input.
  final bool enabled;

  /// Formatters applied to typed text.
  final List<TextInputFormatter>? inputFormatters;

  /// The field colour; [SheenColors.surface] on the page and [SheenColors.surfaceMuted] inside a sheet ([SheenNested])
  /// when null.
  final Color? fill;

  /// Hides the text, for passwords.
  final bool obscureText;

  /// A button at the end of the field (show/hide password, clear).
  final Widget? trailing;

  /// Takes no typing; use [onTap] to open a picker.
  final bool readOnly;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Called when the keyboard's action button is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Whether the keyboard corrects spelling (always off for passwords).
  final bool autocorrect;

  @override
  State<SheenTextField> createState() => _SheenTextFieldState();
}

class _SheenTextFieldState extends State<SheenTextField> {
  late FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(SheenTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      _focus.removeListener(_onFocus);
      if (old.focusNode == null) _focus.dispose();
      _focus = widget.focusNode ?? FocusNode();
      _focus.addListener(_onFocus);
    }
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final errorRing = t.isDark ? const Color(0xFFFF6B6B) : t.colors.danger;
    final errorText = t.isDark ? const Color(0xFFFF8A8A) : t.colors.danger;
    // at rest the field looks like the surfaces beside it: on the page ground a white card (its shadow in light), in a
    // sheet the flat nested grey; focus and errors draw a ring
    final nested = SheenNested.of(context);
    final ring = hasError
        ? BorderSide(color: errorRing, width: 1.5)
        : _focus.hasFocus
        ? BorderSide(color: t.colors.accentText, width: 2)
        : widget.fill != null
        ? BorderSide(color: t.colors.separator, width: 1)
        : BorderSide.none;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelTrailing == null)
          Text(widget.label, style: t.type.footnote.copyWith(color: t.colors.textSecondary))
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(widget.label, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
              ),
              widget.labelTrailing!,
            ],
          ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: AlignmentDirectional.centerStart,
          decoration: ShapeDecoration(
            color: widget.fill ?? (nested ? t.colors.surfaceMuted : t.colors.surface),
            shadows: widget.fill != null || nested || t.isDark ? null : SheenCard.lightShadow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SheenRadius.field), side: ring),
          ),
          child: Row(
            children: [
              Expanded(
                child: SheenMaterialBridge(
                  child: TextField(
                    keyboardAppearance: t.brightness,
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onTap: widget.onTap,
                    readOnly: widget.readOnly,
                    obscureText: widget.obscureText,
                    autocorrect: widget.autocorrect && !widget.obscureText,
                    enableSuggestions: !widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    autofillHints: widget.autofillHints,
                    textCapitalization: widget.textCapitalization,
                    inputFormatters: widget.inputFormatters,
                    cursorColor: t.colors.accentText,
                    style: t.type.body.copyWith(color: t.colors.text),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.placeholder,
                      hintStyle: t.type.body.copyWith(color: t.colors.textTertiary),
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Text(widget.error!, style: t.type.caption.copyWith(color: errorText)),
          ),
        ],
      ],
    );
  }
}
