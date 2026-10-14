import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// Three small bars that rise and fall while a song plays, in the accent colour, as the playing row of a list shows.
///
/// They stand still when [playing] is false and under Reduce Motion, where they keep a fixed, uneven shape.
///
/// ```dart
/// SheenPlayingBars(playing: player.playing)
/// ```
///
/// {@category Music}
class SheenPlayingBars extends StatefulWidget {
  /// Bars that move while [playing].
  const SheenPlayingBars({super.key, this.playing = true, this.color, this.size = 14, this.semanticLabel});

  /// Whether the bars move.
  final bool playing;

  /// The bar colour; the theme's accent text colour by default.
  final Color? color;

  /// The height of the tallest bar; the group is as wide as it is high.
  final double size;

  /// What a screen reader says; [SheenMusicStrings.nowPlaying] by default.
  final String? semanticLabel;

  @override
  State<SheenPlayingBars> createState() => _SheenPlayingBarsState();
}

class _SheenPlayingBarsState extends State<SheenPlayingBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  static const _rest = [.55, .9, .4];
  static const _phase = [0.0, 2.1, 4.2];

  bool _moving(BuildContext context) => widget.playing && !SheenMotion.reduced(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SheenPlayingBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (_moving(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.sheen.colors.accentText;
    final s = widget.size;
    final barW = s * .2;
    return Semantics(
      label: widget.semanticLabel ?? SheenMusicStrings.of(context).nowPlaying,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: s,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    key: ValueKey('sheen-bar-$i'),
                    width: barW,
                    height:
                        s *
                        (_moving(context)
                            ? .25 + .75 * (.5 + .5 * math.sin(_c.value * 2 * math.pi + _phase[i]))
                            : _rest[i]),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(barW / 2)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
