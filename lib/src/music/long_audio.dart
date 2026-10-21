import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'artwork.dart';
import 'seek_bar.dart';
import 'strings.dart';

/// A "back 15" or "forward 30" button for long audio: a circular arrow with the number of [seconds] inside.
///
/// Like the other media controls it keeps its direction in right-to-left text. [SheenTransportControls] shows a pair
/// when given `onSkipBack` and `onSkipForward`.
///
/// ```dart
/// SheenSkipButton(seconds: 15, forward: false, onPressed: () => player.seekBy(-15))
/// ```
///
/// {@category Music}
class SheenSkipButton extends StatelessWidget {
  /// A button that skips [seconds] ahead when [forward], else back.
  const SheenSkipButton({
    super.key,
    required this.seconds,
    required this.forward,
    required this.onPressed,
    this.size = 56,
    this.color,
  });

  /// How far it skips, shown inside the arrow.
  final int seconds;

  /// Ahead (true) or back.
  final bool forward;

  /// Called on a tap; null disables it.
  final VoidCallback? onPressed;

  /// The hit area; the glyph is about 60 % of it.
  final double size;

  /// The glyph colour; the theme's text colour by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    final ink = color ?? t.colors.text;
    final glyph = size * .6;
    return SheenPressable(
      semanticLabel: (forward ? s.skipForward : s.skipBack).replaceAll('{n}', '$seconds'),
      onTap: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      minSize: size,
      child: SizedBox.square(
        dimension: size,
        child: ExcludeSemantics(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SheenIcon(forward ? SheenIcons.skipForward : SheenIcons.skipBack, size: glyph, color: ink, stroke: 2),
              Padding(
                padding: EdgeInsets.only(top: glyph * .08),
                child: Text(
                  '$seconds',
                  textDirection: TextDirection.ltr,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: glyph * .32,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A playback speed as a player shows it: `1×`, `1.25×`, `0.8×`.
///
/// {@category Music}
String formatSheenSpeed(double speed) {
  var s = speed.toStringAsFixed(2);
  while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
    s = s.substring(0, s.length - 1);
  }
  return '$s×';
}

/// The playback speed choice of long audio: one row of equal buttons, the chosen one filled.
///
/// ```dart
/// SheenSpeedPicker(value: state.speed, onChanged: player.setSpeed)
/// ```
///
/// {@category Music}
class SheenSpeedPicker extends StatelessWidget {
  /// Speeds from [speeds], [value] chosen.
  const SheenSpeedPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.speeds = const [.8, 1, 1.25, 1.5, 2],
  });

  /// The speed in use.
  final double value;

  /// Called with the speed tapped.
  final ValueChanged<double>? onChanged;

  /// The speeds offered, slowest first.
  final List<double> speeds;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    return Semantics(
      container: true,
      label: s.speed,
      // one row of equal buttons; under large text a button grows taller, never the row wider
      child: Row(
        children: [
          for (final (i, v) in speeds.indexed) ...[
            if (i > 0) const SizedBox(width: SheenSpace.s),
            Expanded(
              child: Builder(
                builder: (context) {
                  final on = (v - value).abs() < .001;
                  final label = formatSheenSpeed(v);
                  return SheenPressable(
                    selected: on,
                    semanticLabel: label,
                    onTap: onChanged == null
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            onChanged!(v);
                          },
                    child: AnimatedContainer(
                      duration: SheenMotion.reduced(context) ? Duration.zero : SheenMotion.fadeIn,
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(horizontal: SheenSpace.xs, vertical: SheenSpace.s),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? t.colors.text : t.colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExcludeSemantics(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            textDirection: TextDirection.ltr,
                            style: t.type.subhead.copyWith(
                              fontWeight: FontWeight.w600,
                              color: on ? t.colors.background : t.colors.textSecondary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One chapter of a long recording: its [title] and where it [start]s.
///
/// {@category Music}
@immutable
class SheenChapter {
  /// A chapter called [title] starting at [start].
  const SheenChapter(this.title, this.start);

  /// What the chapter is called.
  final String title;

  /// Where it starts.
  final Duration start;

  @override
  bool operator ==(Object other) => other is SheenChapter && other.title == title && other.start == start;

  @override
  int get hashCode => Object.hash(title, start);

  @override
  String toString() => 'SheenChapter($title, $start)';
}

/// The index of the chapter that holds [position] in [chapters] (sorted by start), or -1 when there are none or
/// [position] is before the first.
///
/// {@category Music}
int currentSheenChapter(List<SheenChapter> chapters, Duration position) {
  var at = -1;
  for (var i = 0; i < chapters.length; i++) {
    if (chapters[i].start <= position) at = i;
  }
  return at;
}

/// The chapters of a long recording as rows: the title and its start time, the chapter playing in the accent colour,
/// the ones already heard dimmed. A tap picks a chapter.
///
/// It is a column, not a scroll view: put it in the sheet or page that scrolls.
///
/// ```dart
/// SheenChapterList(chapters: book.chapters, position: state.position, onSelected: (c) => player.seek(c.start))
/// ```
///
/// {@category Music}
class SheenChapterList extends StatelessWidget {
  /// [chapters] with the one holding [position] marked.
  const SheenChapterList({super.key, required this.chapters, required this.position, this.onSelected});

  /// The chapters, sorted by start.
  final List<SheenChapter> chapters;

  /// Where playback is.
  final Duration position;

  /// Called with the chapter tapped.
  final ValueChanged<SheenChapter>? onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final now = currentSheenChapter(chapters, position);
    final hours = chapters.isNotEmpty && chapters.last.start >= const Duration(hours: 1);
    String time(Duration d) {
      final f = formatSheenDuration(d);
      return hours && d < const Duration(hours: 1) ? '0:${f.padLeft(5, '0')}' : f;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < chapters.length; i++)
          SheenPressable(
            selected: i == now,
            pressedScale: 1,
            onTap: onSelected == null ? null : () => onSelected!(chapters[i]),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: SheenSpace.l, vertical: SheenSpace.m),
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: t.colors.separator, width: .5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chapters[i].title,
                      textDirection: sheenTextDirectionOf(chapters[i].title),
                      style: t.type.body.copyWith(
                        fontWeight: i == now ? FontWeight.w600 : null,
                        color: i == now
                            ? t.colors.accentText
                            : i < now
                            ? t.colors.textSecondary
                            : t.colors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: SheenSpace.m),
                  ExcludeSemantics(
                    child: Text(
                      time(chapters[i].start),
                      textDirection: TextDirection.ltr,
                      style: t.type.subhead.copyWith(
                        color: t.colors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The "Continue listening" card of long audio: the cover, the title, what is left, a progress line and a play
/// button. Show it while a book or episode is unfinished.
///
/// ```dart
/// SheenResumeCard(
///   image: NetworkImage(book.cover),
///   title: book.title,
///   subtitle: 'Chapter 7 · 6 h 20 min left',
///   progress: book.progress,
///   onPlay: () => player.resume(book),
///   onTap: () => openBook(book),
/// )
/// ```
///
/// {@category Music}
class SheenResumeCard extends StatelessWidget {
  /// A card for [title], [progress] of the way through.
  const SheenResumeCard({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.progress = 0,
    this.label,
    this.onPlay,
    this.onTap,
  });

  /// What is being listened to.
  final String title;

  /// Where you are and what is left.
  final String? subtitle;

  /// The cover, drawn as a book.
  final ImageProvider? image;

  /// How far through, 0 to 1.
  final double progress;

  /// The heading; [SheenMusicStrings.continueListening] by default.
  final String? label;

  /// Plays from where it stopped.
  final VoidCallback? onPlay;

  /// Opens it.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenMusicStrings.of(context);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6);
    return SheenPressable(
      onTap: onTap,
      pressedScale: .98,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(SheenSpace.m, SheenSpace.m, SheenSpace.s, SheenSpace.m),
        decoration: BoxDecoration(color: t.colors.surfaceMuted, borderRadius: BorderRadius.circular(SheenRadius.group)),
        child: Row(
          children: [
            SheenArtwork(image: image, size: 58, book: true),
            const SizedBox(width: SheenSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label ?? s.continueListening,
                    textScaler: scaler,
                    style: t.type.caption.copyWith(
                      color: t.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .5,
                    ),
                  ),
                  Text(
                    title,
                    textDirection: sheenTextDirectionOf(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: scaler,
                    style: t.type.headline,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaler: scaler,
                      style: t.type.subhead.copyWith(color: t.colors.textSecondary),
                    ),
                  const SizedBox(height: SheenSpace.s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: t.colors.separator),
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: ColoredBox(color: t.colors.accentText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onPlay != null) ...[
              const SizedBox(width: SheenSpace.s),
              SheenPressable(
                semanticLabel: s.play,
                onTap: onPlay,
                child: SheenGlass(
                  shape: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 46,
                    child: Center(child: SheenIcon(SheenIcons.playFill, size: 20, filled: true, color: t.colors.text)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One small label of a [SheenTagRow]; its [tone] picks the text colour (neutral by default).
///
/// {@category Music}
@immutable
class SheenTag {
  /// A tag reading [label].
  const SheenTag(this.label, {this.tone = SheenTone.neutral});

  /// What it says.
  final String label;

  /// What it means: success for a good sign ("Whole book"), neutral for plain facts.
  final SheenTone tone;
}

/// Small facts under a row, as rounded labels that wrap: "Whole book · Ukrainian · 2 parts joined".
///
/// ```dart
/// SheenTagRow(tags: [SheenTag('Whole book', tone: SheenTone.success), SheenTag('Ukrainian')])
/// ```
///
/// {@category Music}
class SheenTagRow extends StatelessWidget {
  /// A row of [tags].
  const SheenTagRow({super.key, required this.tags});

  /// The tags, in reading order.
  final List<SheenTag> tags;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6);
    return Wrap(
      spacing: SheenSpace.xs + 2,
      runSpacing: SheenSpace.xs + 2,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SheenSpace.s, vertical: SheenSpace.xs),
            decoration: BoxDecoration(color: t.colors.surfaceMuted, borderRadius: BorderRadius.circular(999)),
            child: Text(
              tag.label,
              textScaler: scaler,
              style: t.type.caption.copyWith(
                color: tag.tone == SheenTone.neutral ? t.colors.textSecondary : tag.tone.color(t.colors),
              ),
            ),
          ),
      ],
    );
  }
}
