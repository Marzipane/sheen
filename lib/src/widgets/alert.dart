import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// Shows a decision alert on glass and returns true for the primary action, false for the secondary and null when
/// dismissed.
///
/// It scales from 1.1 to 1 as iOS alerts do, and only fades with Reduce Motion. It keeps the theme of the screen that
/// opens it.
/// ```dart
/// final again = await showSheenAlert(
///   context: context,
///   title: 'Time is up',
///   message: 'The offer has expired. Start again?',
///   primaryLabel: 'Start again',
///   secondaryLabel: 'Not now',
/// );
/// ```
/// {@category Feedback}
Future<bool?> showSheenAlert({
  required BuildContext context,
  required String title,
  required String message,
  required String primaryLabel,
  String? secondaryLabel,
  bool barrierDismissible = false,
}) {
  final reduced = SheenMotion.reduced(context);
  // the dialog route sits above the screen's theme; carry it over, as showDialog does
  final themes = InheritedTheme.capture(from: context, to: Navigator.of(context, rootNavigator: true).context);
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: secondaryLabel ?? primaryLabel,
    barrierColor: const Color.fromRGBO(0, 0, 0, .4),
    transitionDuration: reduced ? SheenMotion.reducedFade : SheenMotion.smoothSettle,
    pageBuilder: (c, a, b) => themes.wrap(
      SheenAlert(
        title: title,
        message: message,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        onPrimary: () => Navigator.of(c).pop(true),
        onSecondary: () => Navigator.of(c).pop(false),
      ),
    ),
    transitionBuilder: (c, a, b, child) {
      final fade = CurvedAnimation(parent: a, curve: SheenMotion.easeOut);
      if (reduced) return FadeTransition(opacity: fade, child: child);
      final scale = Tween(
        begin: 1.1,
        end: 1.0,
      ).animate(CurvedAnimation(parent: a, curve: SheenMotion.curveOf(SheenMotion.smooth)));
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

/// The alert that [showSheenAlert] shows, for apps that present it themselves.
///
/// {@category Feedback}
class SheenAlert extends StatelessWidget {
  /// An alert titled [title].
  const SheenAlert({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  /// The title.
  final String title;

  /// The message.
  final String message;

  /// The primary button's label.
  final String primaryLabel;

  /// Called by the primary button.
  final VoidCallback onPrimary;

  /// The secondary button's label; null shows only the primary button.
  final String? secondaryLabel;

  /// Called by the secondary button.
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    // D19: actions stack, each at least 48 pt and growing with the text; the title and message scroll when the user's
    // text size makes the alert taller than the screen, so the actions stay reachable.
    Widget action(String label, VoidCallback? onTap, bool primary) {
      final text = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: t.type.headline.copyWith(color: primary ? t.colors.onAccent : t.colors.text),
        ),
      );
      return SheenPressable(
        onTap: onTap,
        semanticLabel: label,
        minSize: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: double.infinity),
          child: primary
              ? SheenGlass(
                  variant: SheenGlassVariant.prominent,
                  child: Center(heightFactor: 1, child: text),
                )
              : DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: t.isDark ? const Color.fromRGBO(255, 255, 255, .08) : t.colors.surfaceMuted,
                  ),
                  child: Center(heightFactor: 1, child: text),
                ),
        ),
      );
    }

    final screen = MediaQuery.sizeOf(context);
    return Center(
      child: DefaultTextStyle(
        style: t.type.body.copyWith(color: t.colors.text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 310, maxHeight: screen.height - 96),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: SheenGlass(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: t.type.headline.copyWith(color: t.colors.text),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: t.type
                                    .sized(t.type.subhead, 14)
                                    .copyWith(height: 1.4, color: t.colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      action(primaryLabel, onPrimary, true),
                      if (secondaryLabel != null) ...[
                        const SizedBox(height: 8),
                        action(secondaryLabel!, onSecondary, false),
                      ],
                    ],
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

/// A notice in a glass row with a glyph, such as "Payments are temporarily unavailable", with an optional action.
///
/// {@category Feedback}
class SheenStatusNotice extends StatelessWidget {
  /// A notice showing [message].
  const SheenStatusNotice({super.key, required this.message, this.icon = SheenIcons.info, this.action});

  /// The notice.
  final String message;

  /// The glyph ([SheenIcons]).
  final String icon;

  /// An action at the end, such as a [SheenTextLink].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Semantics(
      liveRegion: true,
      child: SheenGlass(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SheenIcon(icon, size: 18, stroke: 2, color: t.colors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: t.type.footnote.copyWith(color: t.colors.text)),
              ),
              if (action != null) ...[const SizedBox(width: 10), action!],
            ],
          ),
        ),
      ),
    );
  }
}
