import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A short message at the top of the screen, above every page, sheet and the keyboard: a glass capsule with a glyph in
/// the colour of its [SheenTone].
///
/// Screen readers hear it; a tap closes it; a new toast replaces the one shown. It stays for its [readingTime], and
/// while the app is inactive (a system alert over it) its time does not run.
///
/// ```dart
/// SheenToast.show(context, 'Saved to your list', tone: SheenTone.success);
/// ```
///
/// {@category Feedback}
abstract final class SheenToast {
  static OverlayEntry? _entry;
  static Timer? _timer;
  static AppLifecycleListener? _lifecycle;

  /// Long enough to read: about a word a quarter second, 3 to 7 seconds.
  static Duration readingTime(String message) => Duration(milliseconds: (2000 + message.length * 45).clamp(3000, 7000));

  /// Shows [message] in the root overlay above [context]; false when there is no overlay or no message.
  ///
  /// [icon] replaces the tone's glyph; [duration] replaces the reading time.
  static bool show(
    BuildContext context,
    String message, {
    SheenTone tone = SheenTone.info,
    String? icon,
    Duration? duration,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || !overlay.mounted || message.trim().isEmpty) return false;
    hide();
    final themes = InheritedTheme.capture(from: context, to: overlay.context);
    final entry = OverlayEntry(
      builder: (_) => themes.wrap(_SheenToastView(message: message, tone: tone, icon: icon, onTap: hide)),
    );
    _entry = entry;
    overlay.insert(entry);
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    SemanticsService.sendAnnouncement(View.of(context), message, direction);
    void run() {
      _timer?.cancel();
      _timer = Timer(duration ?? readingTime(message), hide);
    }

    _lifecycle = AppLifecycleListener(onInactive: () => _timer?.cancel(), onResume: run);
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) run();
    return true;
  }

  /// Removes the toast shown, if any.
  static void hide() {
    _timer?.cancel();
    _timer = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    _entry?.remove();
    _entry = null;
  }
}

class _SheenToastView extends StatefulWidget {
  const _SheenToastView({required this.message, required this.tone, required this.icon, required this.onTap});

  final String message;
  final SheenTone tone;
  final String? icon;
  final VoidCallback onTap;

  @override
  State<_SheenToastView> createState() => _SheenToastViewState();
}

class _SheenToastViewState extends State<_SheenToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
    ..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final mq = MediaQuery.of(context);
    // a wide window has its tabs at the top: the toast comes under them
    final top = mq.padding.top + 8 + (SheenLayout.isWide(mq.size.width) ? SheenTopTabBar.height + 8 : 0);
    final glyph =
        widget.icon ??
        switch (widget.tone) {
          SheenTone.success => SheenIcons.check,
          SheenTone.danger => SheenIcons.xCircle,
          _ => SheenIcons.info,
        };
    final reduced = SheenMotion.reduced(context);
    final curve = CurvedAnimation(parent: _in, curve: SheenMotion.easeOut);
    return Positioned(
      left: 16,
      right: 16,
      top: top,
      // its own text style: the overlay may sit outside any SheenScope, where the app's error style would show
      child: DefaultTextStyle(
        style: t.type.body.copyWith(color: t.colors.text),
        child: Center(
          child: FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween(begin: reduced ? Offset.zero : const Offset(0, -.4), end: Offset.zero).animate(curve),
              child: Semantics(
                container: true,
                button: true,
                label: widget.message,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: ConstrainedBox(
                    key: const ValueKey('sheen-toast'),
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SheenGlass(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SheenIcon(glyph, size: 16, color: widget.tone.color(t.colors), stroke: 2.6),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              widget.message,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: t.type.subhead.copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
