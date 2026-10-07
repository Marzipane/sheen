import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

import '../glass/painters.dart';

/// Opens a sheet with a header: a grabber, a close button, the [title] and, when [doneLabel] is given, a prominent
/// Done button. It has two heights (detents), [medium] and [large] (fractions of the screen), snaps between them
/// and closes when dragged down or when the dim behind it is tapped.
///
/// [builder] gets the sheet's scroll controller: give it to the sheet's list so that scrolling and dragging the sheet
/// work together.
///
/// ```dart
/// final picked = await showSheenSheet<String>(
///   context: context,
///   title: 'Sort by',
///   builder: (context, scroll) => ListView(
///     controller: scroll,
///     children: [
///       SheenListRow(title: 'Price', onTap: () => Navigator.pop(context, 'price')),
///     ],
///   ),
/// );
/// ```
///
/// Returns the value the sheet was popped with, or null. The labels default to [SheenStrings].
///
/// {@category Sheets}
Future<T?> showSheenSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext context, ScrollController scroll) builder,
  String? cancelLabel,
  String? doneLabel,
  VoidCallback? onDone,
  String? subtitle,
  double medium = .55,
  double large = .92,
  bool startLarge = true,
}) => showSheenCustomSheet<T>(
  context: context,
  medium: medium,
  large: large,
  startLarge: startLarge,
  builder: (sheetContext, scroll) => SheenSheetBody(
    title: title,
    subtitle: subtitle,
    cancelLabel: cancelLabel,
    doneLabel: doneLabel,
    onCancel: () => Navigator.of(sheetContext).pop(),
    onDone: doneLabel == null
        ? null
        : () {
            onDone?.call();
            Navigator.of(sheetContext).pop();
          },
    child: builder(sheetContext, scroll),
  ),
);

/// Opens a sheet whose whole surface [builder] draws, usually a [SheenSheetBody] whose header it controls itself (for
/// example a Done button that waits for a valid choice). The presentation is that of [showSheenSheet].
///
/// {@category Sheets}
Future<T?> showSheenCustomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext sheetContext, ScrollController scroll) builder,
  double medium = .55,
  double large = .92,
  bool startLarge = true,
  bool useRootNavigator = false,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(
    SheenSheetRoute<T>(
      builder: builder,
      medium: medium,
      large: large,
      startLarge: startLarge,
      reduceMotion: SheenMotion.reduced(context),
      barrierLabel: SheenStrings.of(context).close,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
    ),
  );
}

/// The route behind [showSheenSheet] and [showSheenCustomSheet], for apps that push routes themselves.
///
/// On a wide window the sheet stays a column of at most [SheenLayout.sheet] points, centred.
///
/// {@category Sheets}
class SheenSheetRoute<T> extends PopupRoute<T> {
  /// A sheet route whose surface [builder] draws.
  SheenSheetRoute({
    required this.builder,
    this.medium = .55,
    this.large = .92,
    this.startLarge = true,
    this.reduceMotion = false,
    this.barrierLabel,
    this.themes,
    super.settings,
  }) : assert(0 < medium && medium <= large && large <= 1);

  /// Builds the sheet's surface; give the scroll controller to its list.
  final Widget Function(BuildContext context, ScrollController scroll) builder;

  /// The lower detent, as a fraction of the screen height.
  final double medium;

  /// The upper detent, as a fraction of the screen height.
  final double large;

  /// Opens at [large] rather than [medium].
  final bool startLarge;

  /// Cross-fades instead of sliding (pass `SheenMotion.reduced(context)`).
  final bool reduceMotion;

  /// The themes of the screen that opened the sheet (`InheritedTheme.capture`), so the sheet looks like it.
  final CapturedThemes? themes;

  /// The lowest the sheet goes before it closes.
  static const double closeExtent = .25;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => const Color.fromRGBO(0, 0, 0, .45);

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => reduceMotion ? SheenMotion.reducedFade : SheenMotion.smoothSettle;

  @override
  Duration get reverseTransitionDuration => reduceMotion ? SheenMotion.reducedFade : const Duration(milliseconds: 250);

  bool _closeAtBottom(DraggableScrollableNotification n) {
    if (n.extent <= n.minExtent + .001 && n.shouldCloseOnMinExtent && isCurrent && !animation!.isAnimating) {
      navigator?.pop();
    }
    return false;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final initial = startLarge ? large : medium;
    final sheet = Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SheenLayout.sheet),
        child: SheenDetentHaptics(
          detents: [medium, large],
          initial: initial,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: _closeAtBottom,
            child: DraggableScrollableSheet(
              snap: true,
              initialChildSize: initial,
              minChildSize: closeExtent,
              maxChildSize: large,
              snapSizes: [if (medium < large) medium],
              builder: (c, scroll) =>
                  Semantics(scopesRoute: true, namesRoute: true, explicitChildNodes: true, child: builder(c, scroll)),
            ),
          ),
        ),
      ),
    );
    return themes?.wrap(sheet) ?? sheet;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion) return FadeTransition(opacity: animation, child: child);
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: SheenMotion.curveOf(SheenMotion.smooth),
        reverseCurve: SheenMotion.easeIn,
      ),
    );
    return SlideTransition(position: slide, child: child);
  }
}

/// A light tap when a dragged sheet reaches one of its detents, as iOS sheets give; nothing while it opens.
///
/// {@category Sheets}
class SheenDetentHaptics extends StatefulWidget {
  /// Watches the `DraggableScrollableSheet` in [child] for [detents].
  const SheenDetentHaptics({super.key, required this.detents, required this.initial, required this.child});

  /// The sheet sizes that give a tap when reached.
  final List<double> detents;

  /// The size the sheet opens at (no tap for it).
  final double initial;

  /// The subtree holding the sheet.
  final Widget child;

  @override
  State<SheenDetentHaptics> createState() => _DetentHapticsState();
}

class _DetentHapticsState extends State<SheenDetentHaptics> {
  late double? _at = widget.initial;

  bool _onExtent(DraggableScrollableNotification n) {
    double? at;
    for (final d in widget.detents) {
      if ((n.extent - d).abs() < .003) at = d;
    }
    if (at != null && at != _at) HapticFeedback.lightImpact();
    _at = at;
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<DraggableScrollableNotification>(onNotification: _onExtent, child: widget.child);
}

/// Marks a subtree on a raised ground, such as a sheet: lists and fields inside it take
/// [SheenColors.surfaceMuted] instead of [SheenColors.surface], so they stay apart from the ground.
///
/// {@category Sheets}
class SheenNested extends InheritedWidget {
  /// Marks [child] as nested.
  const SheenNested({super.key, required super.child});

  /// Whether [context] is inside a [SheenNested].
  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SheenNested>() != null;

  @override
  bool updateShouldNotify(SheenNested oldWidget) => false;
}

/// The surface of a sheet: the grabber, a header with a close button, the title and Done (or [trailing]), and the
/// content, marked [SheenNested]. For [showSheenCustomSheet].
///
/// {@category Sheets}
class SheenSheetBody extends StatelessWidget {
  /// A sheet surface titled [title] around [child].
  const SheenSheetBody({
    super.key,
    required this.title,
    this.cancelLabel,
    required this.onCancel,
    required this.child,
    this.doneLabel,
    this.onDone,
    this.trailing,
    this.subtitle,
  });

  /// The title in the header.
  final String title;

  /// A second line under the title, such as "172 results · 20–22 Oct".
  final String? subtitle;

  /// The close button's label for screen readers; [SheenStrings.cancel] when null.
  final String? cancelLabel;

  /// Shows a prominent Done (check) button with this label; null shows none.
  final String? doneLabel;

  /// Called by the close button.
  final VoidCallback onCancel;

  /// Called by Done; null shows Done dimmed and inert, for a choice that is not valid yet.
  final VoidCallback? onDone;

  /// Shown in place of Done: a text action such as Reset.
  final Widget? trailing;

  /// The content, usually a list using the sheet's scroll controller.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final cancel = cancelLabel ?? SheenStrings.of(context).cancel;
    const shape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SheenRadius.sheet)));
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: t.colors.sheet),
      child: CustomPaint(
        foregroundPainter: SheenGlassEdgePainter(
          shape: shape,
          rim: const [Color(0x00FFFFFF), Color(0x00FFFFFF)],
          rimStops: const [0, 1],
          rimAngle: 180,
          innerTop: t.isDark ? const Color.fromRGBO(255, 255, 255, .12) : const Color.fromRGBO(0, 0, 0, .06),
          innerTopWidth: 1,
        ),
        child: ClipPath(
          clipper: const ShapeBorderClipper(shape: shape),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Semantics(
                label: cancel,
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: t.colors.textTertiary.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 5, 12, 8),
                child: Row(
                  children: [
                    SheenIconButton(icon: SheenIcons.close, semanticLabel: cancel, stroke: 2.2, onTap: onCancel),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.type.headline.copyWith(color: t.colors.text),
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.type.caption.copyWith(color: t.colors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      ConstrainedBox(constraints: const BoxConstraints(minWidth: 44), child: trailing)
                    else if (doneLabel != null)
                      // without [onDone] Done waits for a valid choice: dimmed and inert (SheenIconButton's disabled state)
                      SheenIconButton(
                        icon: SheenIcons.check,
                        semanticLabel: doneLabel!,
                        stroke: 2.6,
                        variant: SheenGlassVariant.prominent,
                        onTap: onDone,
                      )
                    else
                      const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(child: SheenNested(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}
