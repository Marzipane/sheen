import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A row of chips that scrolls sideways and never wraps, its edges fading into the page only where more chips wait.
///
/// ```dart
/// SheenChipRow(children: [
///   SheenChip(label: 'Price', menu: true, selected: false, onTap: sort),
///   SheenChip(label: 'Free cancellation', selected: free, onTap: toggleFree),
/// ])
/// ```
///
/// {@category Selection}
class SheenChipRow extends StatefulWidget {
  /// A scrolling row of [children].
  const SheenChipRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.fadeEdges = true,
  });

  /// The chips.
  final List<Widget> children;

  /// The space between chips.
  final double spacing;

  /// The space before the first chip and after the last.
  final EdgeInsetsGeometry padding;

  /// Fades the edges where more chips wait into the page background ([SheenEdgeFade]); turn it off over a photo.
  final bool fadeEdges;

  @override
  State<SheenChipRow> createState() => _SheenChipRowState();
}

class _SheenChipRowState extends State<SheenChipRow> {
  bool _before = false, _after = false;

  bool _onMetrics(ScrollMetrics m) {
    final before = m.extentBefore > .5, after = m.extentAfter > .5;
    if (before != _before || after != _after) {
      setState(() {
        _before = before;
        _after = after;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // the scroll view reports its extents once laid out, then on every scroll
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onMetrics(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onMetrics(n.metrics),
        child: SheenEdgeFade(
          start: widget.fadeEdges && _before,
          end: widget.fadeEdges && _after,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            child: Row(
              children: [
                for (final (i, c) in widget.children.indexed) ...[if (i > 0) SizedBox(width: widget.spacing), c],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the [start] and [end] edges of a horizontal [child] into [color] over [width] points, to say that it scrolls
/// on. Use it around any sideways list on a plain background; [SheenChipRow] does.
///
/// The fade is a gradient of the background colour laid over the edges, not a mask: a mask over glass would turn each
/// backdrop blur into a hard-edged band. Over a photo, where no single colour fades well, leave it out.
///
/// {@category Layout}
class SheenEdgeFade extends StatelessWidget {
  /// Fades the chosen edges of [child].
  const SheenEdgeFade({
    super.key,
    required this.child,
    this.start = false,
    this.end = true,
    this.width = 24,
    this.color,
  });

  /// The content, usually a horizontal scroll view.
  final Widget child;

  /// Fades the leading edge.
  final bool start;

  /// Fades the trailing edge.
  final bool end;

  /// The width of each fade.
  final double width;

  /// The colour the edges fade into; the theme's background when null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!start && !end) return child;
    final c = color ?? context.sheen.colors.background;
    Widget edge(bool atStart) => PositionedDirectional(
      start: atStart ? 0 : null,
      end: atStart ? null : 0,
      top: 0,
      bottom: 0,
      width: width,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: atStart ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
              end: atStart ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              colors: [c, c.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
    return Stack(children: [child, if (start) edge(true), if (end) edge(false)]);
  }
}
