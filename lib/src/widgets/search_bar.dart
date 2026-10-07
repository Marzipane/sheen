import 'package:flutter/material.dart';

import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';

/// The tab bar in search mode (C1 SheenTabBar, search active; D03): the tab you came from as a circle and the search
/// field that dropped to the bottom. While the field has text its trailing button clears it. No dictation button: the
/// app has no dictation of its own (the keyboard's microphone covers it).
class SheenSearchBar extends StatefulWidget {
  const SheenSearchBar({
    super.key,
    required this.leadingIcon,
    required this.leadingLabel,
    required this.onLeading,
    required this.controller,
    required this.placeholder,
    required this.clearLabel,
    this.focusNode,
    this.onSubmitted,
  });

  /// The filled glyph of the tab search was opened from.
  final String leadingIcon;
  final String leadingLabel;
  final VoidCallback onLeading;
  final TextEditingController controller;
  final String placeholder;
  final String clearLabel;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  static const double height = 52;

  @override
  State<SheenSearchBar> createState() => _SheenSearchBarState();
}

class _SheenSearchBarState extends State<SheenSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(SheenSearchBar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() {
    final has = widget.controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(child: Builder(builder: _build));

  // A bar: its text stays at the system size, as the tab bar's does.
  Widget _build(BuildContext context) {
    final t = context.sheen;
    const h = SheenSearchBar.height;
    return SizedBox(
      height: h,
      child: Row(
        children: [
          SheenPressable(
            onTap: widget.onLeading,
            semanticLabel: widget.leadingLabel,
            minSize: 0,
            child: SheenGlass(
              shape: const CircleBorder(),
              child: SizedBox.square(
                dimension: h,
                child: Center(child: SheenIcon(widget.leadingIcon, filled: true, size: 24, color: t.colors.text)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SheenGlass(
              child: SizedBox(
                height: h,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16, end: _hasText ? 7 : 16),
                  child: Row(
                    children: [
                      SheenIcon(SheenIcons.search, size: 20, stroke: 2.2, color: t.colors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SheenMaterialBridge(
                          child: TextField(
                            keyboardAppearance: t.brightness,
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            onSubmitted: widget.onSubmitted,
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            cursorColor: t.colors.accentText,
                            style: t.type.body.copyWith(color: t.colors.text),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: widget.placeholder,
                              hintStyle: t.type.body.copyWith(color: t.colors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      if (_hasText)
                        SheenPressable(
                          onTap: widget.controller.clear,
                          semanticLabel: widget.clearLabel,
                          minSize: 38,
                          child: SizedBox.square(
                            dimension: 38,
                            child: Center(
                              child: SheenIcon(SheenIcons.xCircle, size: 19, stroke: 2, color: t.colors.textTertiary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
