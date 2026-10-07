import 'package:flutter/widgets.dart';

/// A row of chips that scrolls sideways and never wraps, its edges fading only where more chips wait.
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
  });

  /// The chips.
  final List<Widget> children;

  /// The space between chips.
  final double spacing;

  /// The space before the first chip and after the last.
  final EdgeInsetsGeometry padding;

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
          start: _before,
          end: _after,
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

/// Fades the [start] and [end] edges of a horizontal [child] to transparent over [width] points, to say that it
/// scrolls on. Use it around any sideways list; [SheenChipRow] does.
///
/// {@category Layout}
class SheenEdgeFade extends StatelessWidget {
  /// Fades the chosen edges of [child].
  const SheenEdgeFade({super.key, required this.child, this.start = false, this.end = true, this.width = 24});

  /// The content, usually a horizontal scroll view.
  final Widget child;

  /// Fades the leading edge.
  final bool start;

  /// Fades the trailing edge.
  final bool end;

  /// The width of each fade.
  final double width;

  @override
  Widget build(BuildContext context) {
    if (!start && !end) return child;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final left = rtl ? end : start, right = rtl ? start : end;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) {
        final f = rect.width <= 0 ? 0.0 : (width / rect.width).clamp(0.0, .5);
        return LinearGradient(
          colors: [
            Color(left ? 0x00000000 : 0xFF000000),
            const Color(0xFF000000),
            const Color(0xFF000000),
            Color(right ? 0x00000000 : 0xFF000000),
          ],
          stops: [0, f, 1 - f, 1],
        ).createShader(rect);
      },
      child: child,
    );
  }
}
