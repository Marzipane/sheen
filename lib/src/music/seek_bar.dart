import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// A time as a player shows it: `1:30`, `0:05`, `1:02:03`, or `-2:27` for time left.
///
/// {@category Music}
String formatSheenDuration(Duration d) {
  final neg = d.isNegative && d.inSeconds != 0;
  final s = d.inSeconds.abs();
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  final body = h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}'
      : '$m:${sec.toString().padLeft(2, '0')}';
  return neg ? '-$body' : body;
}

/// The seek line of a player: a thin track that thickens under the finger, the played part in the text colour, the
/// buffered part fainter, and the time played and the time left under it in tabular figures.
///
/// A tap jumps; a drag previews (the times follow the finger and [onSeek] fires as it moves) and [onSeekEnd] fires
/// once on release, which is when to tell the player. A screen reader moves it 10 seconds at a time. In right-to-left
/// text the start is at the right.
///
/// ```dart
/// SheenSeekBar(
///   position: state.position,
///   duration: state.duration,
///   buffered: state.buffered,
///   onSeekEnd: player.seek,
/// )
/// ```
///
/// {@category Music}
class SheenSeekBar extends StatefulWidget {
  /// A seek bar at [position] of [duration].
  const SheenSeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.buffered = Duration.zero,
    this.onSeek,
    this.onSeekEnd,
    this.showTimes = true,
    this.color,
    this.semanticLabel,
  });

  /// Where the song is.
  final Duration position;

  /// How long the song is; zero when not yet known.
  final Duration duration;

  /// How far the song is loaded.
  final Duration buffered;

  /// Called while the finger moves, with the time under it.
  final ValueChanged<Duration>? onSeek;

  /// Called once when a tap or drag ends, with the chosen time.
  final ValueChanged<Duration>? onSeekEnd;

  /// Shows the times under the line.
  final bool showTimes;

  /// The played part and the times; the theme's text colour by default (white on a cover glow works too).
  final Color? color;

  /// What a screen reader calls it; [SheenMusicStrings.position] by default.
  final String? semanticLabel;

  @override
  State<SheenSeekBar> createState() => _SheenSeekBarState();
}

class _SheenSeekBarState extends State<SheenSeekBar> {
  double? _drag; // 0..1 while the finger is down

  bool get _enabled => (widget.onSeek != null || widget.onSeekEnd != null) && widget.duration > Duration.zero;

  double _fraction(Duration d) =>
      widget.duration.inMilliseconds <= 0 ? 0 : (d.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0);

  Duration _at(double f) => Duration(milliseconds: (widget.duration.inMilliseconds * f.clamp(0.0, 1.0)).round());

  double _fromLocal(Offset local, double width) {
    final f = (local.dx / width).clamp(0.0, 1.0);
    return Directionality.of(context) == TextDirection.rtl ? 1 - f : f;
  }

  void _move(double f) {
    setState(() => _drag = f);
    widget.onSeek?.call(_at(f));
  }

  void _end() {
    final f = _drag;
    setState(() => _drag = null);
    if (f != null) {
      HapticFeedback.selectionClick();
      widget.onSeekEnd?.call(_at(f));
    }
  }

  void _step(int seconds) {
    final next = widget.position + Duration(seconds: seconds);
    final clamped = next < Duration.zero ? Duration.zero : (next > widget.duration ? widget.duration : next);
    widget.onSeek?.call(clamped);
    widget.onSeekEnd?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final ink = widget.color ?? t.colors.text;
    final shown = _drag != null ? _at(_drag!) : widget.position;
    final played = _drag ?? _fraction(widget.position);
    final buffered = _fraction(widget.buffered);
    final active = _drag != null;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final timeStyle = t.type.caption.copyWith(
      color: ink.withValues(alpha: active ? .9 : .6),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final strings = SheenMusicStrings.of(context);

    final line = LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (d) => setState(() => _drag = _fromLocal(d.localPosition, w)) : null,
          onTapUp: _enabled ? (_) => _end() : null,
          onTapCancel: _enabled ? () => setState(() => _drag = null) : null,
          onHorizontalDragStart: _enabled ? (d) => _move(_fromLocal(d.localPosition, w)) : null,
          onHorizontalDragUpdate: _enabled ? (d) => _move(_fromLocal(d.localPosition, w)) : null,
          onHorizontalDragEnd: _enabled ? (_) => _end() : null,
          onHorizontalDragCancel: _enabled ? () => setState(() => _drag = null) : null,
          child: SizedBox(
            key: const ValueKey('sheen-seek-track'),
            height: SheenSpace.hit * .6,
            child: Center(
              child: AnimatedContainer(
                duration: SheenMotion.fadeIn,
                curve: SheenMotion.easeOut,
                height: active ? 9 : 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: ink.withValues(alpha: .16)),
                      FractionallySizedBox(
                        alignment: rtl ? Alignment.centerRight : Alignment.centerLeft,
                        widthFactor: buffered,
                        child: ColoredBox(color: ink.withValues(alpha: .14)),
                      ),
                      FractionallySizedBox(
                        alignment: rtl ? Alignment.centerRight : Alignment.centerLeft,
                        widthFactor: played,
                        child: ColoredBox(color: ink.withValues(alpha: active ? 1 : .85)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      slider: true,
      label: widget.semanticLabel ?? strings.position,
      value: formatSheenDuration(shown),
      increasedValue: formatSheenDuration(shown + const Duration(seconds: 10)),
      decreasedValue: formatSheenDuration(shown - const Duration(seconds: 10) < Duration.zero ? Duration.zero : shown - const Duration(seconds: 10)),
      onIncrease: _enabled ? () => _step(10) : null,
      onDecrease: _enabled ? () => _step(-10) : null,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            line,
            if (widget.showTimes)
              Row(
                children: [
                  Text(formatSheenDuration(shown), style: timeStyle, textDirection: TextDirection.ltr),
                  const Spacer(),
                  Text(formatSheenDuration(shown - widget.duration), style: timeStyle, textDirection: TextDirection.ltr),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
