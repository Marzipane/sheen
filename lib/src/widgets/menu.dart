import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// One item of a [showSheenMenu] menu.
///
/// {@category Selection}
@immutable
class SheenMenuItem<T> {
  /// An item that returns [value], labelled [label].
  const SheenMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  /// What choosing the item returns.
  final T value;

  /// The label.
  final String label;

  /// A glyph at the end of the row ([SheenIcons]), as iOS menus show them.
  final String? icon;

  /// Shows the item in the danger colour, for actions that delete or cannot be undone.
  final bool destructive;

  /// Whether the item can be chosen.
  final bool enabled;
}

/// Opens a glass pull-down menu next to an anchor and returns the chosen item's value, or null when it is dismissed
/// (a tap outside, Escape, the back gesture).
///
/// The menu opens below the anchor when it fits, else above, aligned with the anchor's start edge and kept on screen.
/// Give the anchor's [anchorKey] (a `GlobalKey` on the button) or its [anchorRect] in global coordinates.
///
/// ```dart
/// final action = await showSheenMenu<String>(
///   context,
///   anchorKey: moreKey,
///   items: const [
///     SheenMenuItem(value: 'share', label: 'Share', icon: SheenIcons.share),
///     SheenMenuItem(value: 'delete', label: 'Delete', icon: SheenIcons.trash, destructive: true),
///   ],
/// );
/// ```
///
/// {@category Selection}
Future<T?> showSheenMenu<T>(
  BuildContext context, {
  required List<SheenMenuItem<T>> items,
  GlobalKey? anchorKey,
  Rect? anchorRect,
  double width = 250,
}) {
  assert(anchorKey != null || anchorRect != null, 'Give the anchor\'s key or its rect');
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  var rect = anchorRect;
  if (rect == null) {
    final box = anchorKey!.currentContext!.findRenderObject()! as RenderBox;
    rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  }
  return navigator.push(
    _SheenMenuRoute<T>(
      anchor: rect,
      items: items,
      width: width,
      reduceMotion: SheenMotion.reduced(context),
      barrierLabel: SheenStrings.of(context).close,
      direction: Directionality.of(context),
      themes: InheritedTheme.capture(from: context, to: navigator.context),
    ),
  );
}

class _SheenMenuRoute<T> extends PopupRoute<T> {
  _SheenMenuRoute({
    required this.anchor,
    required this.items,
    required this.width,
    required this.reduceMotion,
    required this.barrierLabel,
    required this.direction,
    required this.themes,
  });

  final Rect anchor;
  final List<SheenMenuItem<T>> items;
  final double width;
  final bool reduceMotion;
  final TextDirection direction;
  final CapturedThemes themes;

  /// Where the menu sits, set by its layout: below the anchor or above it.
  bool below = true;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => reduceMotion ? SheenMotion.reducedFade : SheenMotion.smoothSettle;

  @override
  Duration get reverseTransitionDuration => reduceMotion ? SheenMotion.reducedFade : SheenMotion.fadeOut;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final pad = MediaQuery.paddingOf(context);
    return themes.wrap(
      CustomSingleChildLayout(
        delegate: _MenuLayout(route: this, padding: pad),
        child: SizedBox(
          width: width,
          child: _SheenMenu<T>(items: items),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: SheenMotion.easeOut, reverseCurve: SheenMotion.easeIn);
    if (reduceMotion) return FadeTransition(opacity: fade, child: child);
    final start = direction == TextDirection.rtl ? 1.0 : -1.0;
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        // grows out of the anchor's corner
        alignment: Alignment(start, below ? -1 : 1),
        scale: Tween(begin: .6, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: SheenMotion.curveOf(SheenMotion.smooth),
            reverseCurve: SheenMotion.easeIn,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout({required this.route, required this.padding});

  final _SheenMenuRoute<dynamic> route;
  final EdgeInsets padding;

  static const double _gap = 6, _margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => BoxConstraints.loose(
    Size(constraints.maxWidth - 2 * _margin, constraints.maxHeight - padding.vertical - 2 * _margin),
  );

  @override
  Offset getPositionForChild(Size size, Size child) {
    final a = route.anchor;
    final rtl = route.direction == TextDirection.rtl;
    final x = (rtl ? a.right - child.width : a.left)
        .clamp(_margin, math.max(_margin, size.width - child.width - _margin))
        .toDouble();
    final fitsBelow = a.bottom + _gap + child.height <= size.height - padding.bottom - _margin;
    final fitsAbove = a.top - _gap - child.height >= padding.top + _margin;
    route.below = fitsBelow || !fitsAbove;
    final y = route.below
        ? math.min(a.bottom + _gap, size.height - padding.bottom - _margin - child.height)
        : a.top - _gap - child.height;
    return Offset(x, math.max(padding.top + _margin, y));
  }

  @override
  bool shouldRelayout(_MenuLayout old) => old.route.anchor != route.anchor || old.padding != padding;
}

class _SheenMenu<T> extends StatelessWidget {
  const _SheenMenu({required this.items});

  final List<SheenMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: SheenGlass(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, item) in items.indexed) ...[
                if (i > 0) Container(height: .5, color: t.colors.separator),
                _row(context, item),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, SheenMenuItem<T> item) {
    final t = context.sheen;
    final color = item.destructive ? t.colors.danger : t.colors.text;
    return Opacity(
      opacity: item.enabled ? 1 : .4,
      child: SheenPressable(
        pressedScale: 1,
        onTap: item.enabled
            ? () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop(item.value);
              }
            : null,
        semanticLabel: item.label,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SheenSpace.hit),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(item.label, style: t.type.body.copyWith(color: color)),
                ),
                if (item.icon != null) ...[
                  const SizedBox(width: 12),
                  SheenIcon(item.icon!, size: 19, stroke: 2, color: color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
