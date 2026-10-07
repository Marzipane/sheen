import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A whole screen that explains a state the app is in: offline, under maintenance, an update needed, a section
/// closed, a booking confirmed.
///
/// A glyph in a soft circle of its [tone], a title, the [message], optional [details], and up to two actions at the
/// bottom. It scrolls when the text is large, so nothing is cut.
///
/// ```dart
/// SheenStatusScreen(
///   icon: SheenIcons.wrench,
///   tone: SheenTone.warning,
///   title: 'We are updating',
///   message: 'Back in a few minutes.',
///   primaryLabel: 'Try again',
///   onPrimary: retry,
/// )
/// ```
///
/// {@category Feedback}
class SheenStatusScreen extends StatelessWidget {
  /// A status screen titled [title].
  const SheenStatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone = SheenTone.info,
    this.details = const [],
    this.primaryLabel,
    this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondary,
  });

  /// The glyph ([SheenIcons]).
  final String icon;

  /// What the state is, briefly.
  final String title;

  /// What it means and what to do.
  final String message;

  /// The colour of the glyph and its circle.
  final SheenTone tone;

  /// More lines under the message, such as when a service is back.
  final List<Widget> details;

  /// The primary action's label; no button when null.
  final String? primaryLabel;

  /// Called by the primary action.
  final VoidCallback? onPrimary;

  /// Shows a spinner in the primary action and ignores taps.
  final bool primaryLoading;

  /// The secondary action's label; no button when null.
  final String? secondaryLabel;

  /// A glyph before the secondary label.
  final String? secondaryIcon;

  /// Called by the secondary action.
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final pad = MediaQuery.paddingOf(context);
    final inset = context.contentInset + 4;
    final color = tone.color(t.colors);
    return ColoredBox(
      color: t.colors.background,
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(inset, pad.top + 24, inset, pad.bottom + 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - pad.top - pad.bottom - 40),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: color.withValues(alpha: .14), shape: BoxShape.circle),
                    child: Center(child: SheenIcon(icon, size: 32, stroke: 2, color: color)),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: t.type.title.copyWith(color: t.colors.text),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: t.type.body.copyWith(color: t.colors.textSecondary, height: 1.45),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    DefaultTextStyle.merge(
                      textAlign: TextAlign.center,
                      style: t.type.headline.copyWith(color: t.colors.text),
                      child: Column(children: details),
                    ),
                  ],
                  const Spacer(flex: 3),
                  const SizedBox(height: 24),
                  if (primaryLabel != null)
                    SheenPrimaryButton(
                      label: primaryLabel!,
                      expand: true,
                      height: 54,
                      loading: primaryLoading,
                      onPressed: primaryLoading ? null : onPrimary,
                    ),
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 12),
                    SheenSecondaryButton(label: secondaryLabel!, icon: secondaryIcon, onPressed: onSecondary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
