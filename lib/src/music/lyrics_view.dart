import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

/// One timed line of lyrics.
///
/// {@category Music}
@immutable
class SheenLyricsLine {
  /// The line [text] that starts [at].
  const SheenLyricsLine(this.at, this.text);

  /// When the line starts.
  final Duration at;

  /// The words.
  final String text;
}

/// Synced lyrics: large lines, the one being sung bright and the rest dim, scrolling by themselves to keep the current
/// line in the upper third. A tap on a line jumps the song there. With no timed lines, [plain] lyrics show as text.
///
/// The view stops following the song for a few seconds after the user scrolls, so reading ahead is possible.
///
/// ```dart
/// SheenLyricsView(lines: lyrics.lines, position: state.position, onSeek: player.seek)
/// ```
///
/// {@category Music}
class SheenLyricsView extends StatefulWidget {
  /// Lyrics for [lines] at [position].
  const SheenLyricsView({
    super.key,
    required this.lines,
    this.position = Duration.zero,
    this.onSeek,
    this.plain,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: SheenSpace.xxl, vertical: SheenSpace.xxl),
  });

  /// The timed lines, in order.
  final List<SheenLyricsLine> lines;

  /// Where the song is.
  final Duration position;

  /// Called with a line's start when it is tapped.
  final ValueChanged<Duration>? onSeek;

  /// Untimed lyrics, shown when [lines] is empty.
  final String? plain;

  /// The text colour; the theme's text colour by default.
  final Color? color;

  /// Space around the lines.
  final EdgeInsetsGeometry padding;

  /// The index of the line being sung at [position], or -1 before the first.
  static int indexAt(List<SheenLyricsLine> lines, Duration position) {
    var lo = 0, hi = lines.length - 1, found = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lines[mid].at <= position) {
        found = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return found;
  }

  @override
  State<SheenLyricsView> createState() => _SheenLyricsViewState();
}

class _SheenLyricsViewState extends State<SheenLyricsView> {
  final _keys = <int, GlobalKey>{};
  DateTime _userScrolledAt = DateTime(0);
  int _shown = -2;

  GlobalKey _key(int i) => _keys.putIfAbsent(i, GlobalKey.new);

  @override
  void didUpdateWidget(SheenLyricsView old) {
    super.didUpdateWidget(old);
    if (!identical(old.lines, widget.lines)) _keys.clear();
    _follow();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _follow(jump: true));
  }

  void _follow({bool jump = false}) {
    final i = SheenLyricsView.indexAt(widget.lines, widget.position);
    if (i == _shown || i < 0) return;
    _shown = i;
    if (DateTime.now().difference(_userScrolledAt) < const Duration(seconds: 4)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _keys[i]?.currentContext;
      if (c == null || !mounted) return;
      Scrollable.ensureVisible(
        c,
        alignment: .3,
        duration: jump || SheenMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 450),
        curve: SheenMotion.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final ink = widget.color ?? t.colors.text;
    final style = t.type.sized(t.type.title, 26).copyWith(color: ink, height: 1.25, fontWeight: FontWeight.w700);
    if (widget.lines.isEmpty) {
      return SingleChildScrollView(
        padding: widget.padding,
        child: Text(widget.plain ?? '', style: style.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
      );
    }
    final current = SheenLyricsView.indexAt(widget.lines, widget.position);
    return NotificationListener<UserScrollNotification>(
      onNotification: (_) {
        _userScrolledAt = DateTime.now();
        return false;
      },
      child: SingleChildScrollView(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.lines.length; i++)
              Padding(
                key: _key(i),
                padding: const EdgeInsets.symmetric(vertical: SheenSpace.s),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSeek == null ? null : () => widget.onSeek!(widget.lines[i].at),
                  child: AnimatedOpacity(
                    duration: SheenMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 250),
                    opacity: i == current ? 1 : (i < current ? .3 : .45),
                    child: Text(widget.lines[i].text, textDirection: sheenTextDirectionOf(widget.lines[i].text), style: style),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
