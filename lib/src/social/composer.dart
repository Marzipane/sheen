import 'package:flutter/material.dart';
import 'package:sheen/sheen.dart';

import '../foundation/material_bridge.dart';
import 'strings.dart';

/// The bar at the bottom of a chat: a button to share music, a field that grows to five lines, and Send in the accent
/// (disabled while the field is empty). It sits above the keyboard and the home indicator.
///
/// ```dart
/// SheenComposer(
///   controller: text,
///   onSend: (message) => chat.send(message),
///   onAttach: () => showShareMusicSheet(context),
///   onTyping: () => chat.typing(),
/// )
/// ```
///
/// {@category Social}
class SheenComposer extends StatefulWidget {
  /// A composer writing into [controller].
  const SheenComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.onTyping,
    this.placeholder,
    this.maxLength = 2000,
    this.focusNode,
  });

  /// The text being written.
  final TextEditingController controller;

  /// Send was tapped with this text (trimmed, never empty); clearing the field is up to the app.
  final ValueChanged<String> onSend;

  /// Opens a way to share music; no button when null.
  final VoidCallback? onAttach;

  /// The text changed (at most once every few seconds is worth telling anyone).
  final VoidCallback? onTyping;

  /// The placeholder; [SheenSocialStrings.message] by default.
  final String? placeholder;

  /// The longest message.
  final int maxLength;

  /// The field's focus.
  final FocusNode? focusNode;

  @override
  State<SheenComposer> createState() => _SheenComposerState();
}

class _SheenComposerState extends State<SheenComposer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(SheenComposer old) {
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

  void _changed() => setState(() {});

  void _send() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    final can = widget.controller.text.trim().isNotEmpty;
    Widget round(String icon, String label, VoidCallback? onTap, {bool accent = false}) => SheenPressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedOpacity(
        opacity: onTap == null ? .4 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: accent ? t.colors.accent : t.colors.surfaceMuted, shape: BoxShape.circle),
          child: Center(
            child: SheenIcon(
              icon,
              size: 22,
              stroke: accent ? 2.2 : 1.8,
              color: accent ? t.colors.onAccent : t.colors.text,
            ),
          ),
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.background,
        border: Border(top: BorderSide(color: t.colors.separator)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.onAttach != null) ...[
                round(SheenIcons.plus, s.attach, widget.onAttach),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(SheenRadius.field),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: SheenMaterialBridge(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: widget.maxLength,
                          keyboardAppearance: t.brightness,
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: t.colors.accentText,
                          style: t.type.body.copyWith(color: t.colors.text, height: 1.3),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            counterText: '',
                            hintText: widget.placeholder ?? s.message,
                            hintStyle: t.type.body.copyWith(color: t.colors.textTertiary, height: 1.3),
                          ),
                          onChanged: (_) => widget.onTyping?.call(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              round(SheenIcons.arrowUp, s.send, can ? _send : null, accent: true),
            ],
          ),
        ),
      ),
    );
  }
}
