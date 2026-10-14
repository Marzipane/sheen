import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// A list whose rows can be dragged by a handle into a new order and swiped away, as a queue or a playlist is edited.
///
/// [itemBuilder] gets a ready drag handle to place in the row (usually at its end). [onReorder] receives the row's index
/// before the move and its index after it. A swipe towards the start removes a row and calls [onRemove].
///
/// ```dart
/// SheenReorderList<Track>(
///   items: queue,
///   keyOf: (t) => ValueKey(t.id),
///   onReorder: player.move,
///   onRemove: player.removeAt,
///   itemBuilder: (context, t, i, handle) => SheenTrackRow(title: t.title, trailing: handle),
/// )
/// ```
///
/// {@category Music}
class SheenReorderList<T> extends StatelessWidget {
  /// A reorderable list of [items].
  const SheenReorderList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    this.onReorder,
    this.onRemove,
    this.removeLabel,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  /// The rows' items.
  final List<T> items;

  /// A stable key per item.
  final Key Function(T item) keyOf;

  /// Builds a row; place `handle` in it.
  final Widget Function(BuildContext context, T item, int index, Widget handle) itemBuilder;

  /// Called after a drag with the old and the new index.
  final void Function(int from, int to)? onReorder;

  /// Called after a swipe with the removed index; rows cannot be swiped when null.
  final ValueChanged<int>? onRemove;

  /// What the swipe's background says; [SheenMusicStrings.remove] by default.
  final String? removeLabel;

  /// Sizes the list to its rows, for a list inside another scroll view.
  final bool shrinkWrap;

  /// The scroll physics.
  final ScrollPhysics? physics;

  /// Space around the rows.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    return ReorderableList(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      onReorderStart: (_) => HapticFeedback.selectionClick(),
      onReorder: (from, to) {
        final dest = to > from ? to - 1 : to;
        if (dest != from) onReorder?.call(from, dest);
      },
      proxyDecorator: (child, _, a) => AnimatedBuilder(
        animation: a,
        builder: (context, child) => Transform.scale(scale: 1 + .02 * a.value, child: child),
        child: SheenGlass(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: child,
        ),
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final handle = ReorderableDragStartListener(
          index: i,
          child: Semantics(
            label: s.reorder,
            button: true,
            child: SizedBox.square(
              dimension: SheenSpace.hit,
              child: Center(child: SheenIcon(SheenIcons.grip, size: 20, color: t.colors.textTertiary)),
            ),
          ),
        );
        final row = itemBuilder(context, item, i, handle);
        if (onRemove == null) return KeyedSubtree(key: keyOf(item), child: row);
        return Dismissible(
          key: keyOf(item),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            onRemove!(i);
          },
          background: ColoredBox(
            color: t.colors.danger,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: SheenSpace.xl),
                child: Text(removeLabel ?? s.remove, style: t.type.headline.copyWith(color: const Color(0xFFFFFFFF))),
              ),
            ),
          ),
          child: row,
        );
      },
    );
  }
}
