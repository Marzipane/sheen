import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A one-time-code field: one box per digit, the next box ringed in the accent while the field has focus.
///
/// It takes digits only, offers one-time-code autofill (the code from a text message on iOS and Android) and calls
/// [onCompleted] once each time the code reaches [length] digits. The boxes shrink to fit narrow screens, always left
/// to right. Screen readers read it as one field with [semanticLabel].
///
/// ```dart
/// SheenCodeField(controller: code, length: 6, semanticLabel: 'Enter the 6-digit code', onCompleted: verify)
/// ```
///
/// {@category Inputs}
class SheenCodeField extends StatefulWidget {
  /// A code field of [length] digits over [controller].
  const SheenCodeField({
    super.key,
    required this.controller,
    required this.semanticLabel,
    this.length = 6,
    this.onCompleted,
    this.autofocus = true,
  }) : assert(length > 0);

  /// Holds the code.
  final TextEditingController controller;

  /// What a screen reader says for the field, such as "Enter the 6-digit code".
  final String semanticLabel;

  /// The number of digits.
  final int length;

  /// Called with the code when it reaches [length] digits.
  final ValueChanged<String>? onCompleted;

  /// Focuses the field (and shows the keyboard) when it appears.
  final bool autofocus;

  @override
  State<SheenCodeField> createState() => _SheenCodeFieldState();
}

class _SheenCodeFieldState extends State<SheenCodeField> {
  final FocusNode _focus = FocusNode();
  late String _last = widget.controller.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    _focus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(SheenCodeField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
      _last = widget.controller.text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _changed() {
    final v = widget.controller.text;
    if (v == _last) return;
    _last = v;
    _refresh();
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final v = widget.controller.text;
    final n = widget.length;
    final next = v.length.clamp(0, n - 1);
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final width = box.maxWidth.isFinite ? ((box.maxWidth - gap * n) / n).clamp(28.0, 56.0) : 56.0;
        final height = width * 64 / 56;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _focus.requestFocus,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // the real field: invisible, under the boxes
              Opacity(
                opacity: 0,
                child: SizedBox(
                  height: height,
                  child: EditableText(
                    controller: widget.controller,
                    focusNode: _focus,
                    autofocus: widget.autofocus,
                    style: t.type.title,
                    cursorColor: const Color(0x00000000),
                    backgroundCursorColor: const Color(0x00000000),
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: t.brightness,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(n)],
                  ),
                ),
              ),
              Semantics(
                label: widget.semanticLabel,
                value: v,
                textField: true,
                focused: _focus.hasFocus,
                onTap: _focus.requestFocus,
                child: ExcludeSemantics(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < n; i++)
                          Container(
                            key: ValueKey('sheen-code-box-$i'),
                            width: width,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: gap / 2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: SheenNested.of(context) ? t.colors.surfaceMuted : t.colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _focus.hasFocus && i == next ? t.colors.accentText : t.colors.separator,
                                width: _focus.hasFocus && i == next ? 2 : 1,
                              ),
                            ),
                            child: Text(i < v.length ? v[i] : '', style: t.type.title.copyWith(color: t.colors.text)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
