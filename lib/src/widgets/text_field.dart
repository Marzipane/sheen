import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';

/// A labelled text field (C2 TextField): label above, 50 high, radius 14, hairline ring; focused = 2 pt accent ring;
/// error = red ring and the app's own message under it. A password hides its text ([obscureText]) and can carry a
/// trailing button (show/hide); a picker field ([readOnly]) opens its picker through [onTap] and takes no typing.
class SheenTextField extends StatefulWidget {
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

  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? error;

  /// At the end of the label's line: a quiet note (Optional) or a small action (Clear).
  final Widget? labelTrailing;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  /// Field ground; by default s1 on the page ground and s2 inside a sheet ([SheenNested]).
  final Color? fill;

  final bool obscureText;

  /// A button at the end of the field (show/hide password, clear).
  final Widget? trailing;

  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
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
