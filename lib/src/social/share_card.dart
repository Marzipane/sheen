import 'package:flutter/widgets.dart';
import 'package:sheen/music.dart';
import 'package:sheen/sheen.dart';

import 'strings.dart';

/// One button under a [SheenShareCard] ("Like", "Play next", "Save a copy").
///
/// {@category Social}
@immutable
class SheenShareAction {
  /// A button labelled [label].
  const SheenShareAction({required this.label, required this.onTap});

  /// The label.
  final String label;

  /// What it does.
  final VoidCallback onTap;
}

/// Music shared in a chat: the cover with a play button, what it is ("Song · 3:12", "Playlist · 24 songs"), the title,
/// the artist, the sender's note and up to two actions.
///
/// [compact] lays it out as a row (albums and artists, which open a page when tapped).
///
/// ```dart
/// SheenShareCard(
///   kind: 'Song · 3:12',
///   title: 'Habibi',
///   subtitle: 'Sabi',
///   artwork: NetworkImage(thumb),
///   note: 'this one 🔥',
///   onPlay: () => player.play(song),
///   actions: [SheenShareAction(label: 'Like', onTap: like), SheenShareAction(label: 'Play next', onTap: next)],
/// )
/// ```
///
/// {@category Social}
class SheenShareCard extends StatelessWidget {
  /// A card for [title].
  const SheenShareCard({
    super.key,
    required this.kind,
    required this.title,
    this.subtitle,
    this.artwork,
    this.note,
    this.onPlay,
    this.onTap,
    this.actions = const [],
    this.compact = false,
    this.round = false,
    this.placeholderIcon = SheenIcons.music,
  });

  /// What is shared, small and in capitals.
  final String kind;

  /// Its title.
  final String title;

  /// The artist or owner.
  final String? subtitle;

  /// The cover.
  final ImageProvider? artwork;

  /// The sender's words.
  final String? note;

  /// Plays it (a button on the cover).
  final VoidCallback? onPlay;

  /// Opens it (the whole card).
  final VoidCallback? onTap;

  /// Buttons under it.
  final List<SheenShareAction> actions;

  /// A row instead of a card.
  final bool compact;

  /// A round cover (an artist).
  final bool round;

  /// The glyph when there is no cover.
  final String placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final s = SheenSocialStrings.of(context);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.4);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kind.toUpperCase(),
          textScaler: scaler,
          style: t.type.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: .6, color: t.colors.textTertiary),
        ),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textScaler: scaler,
          textDirection: sheenTextDirectionOf(title),
          style: t.type.headline.copyWith(color: t.colors.text),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: scaler,
            style: t.type.footnote.copyWith(color: t.colors.textSecondary),
          ),
      ],
    );
    final noteText = note == null || note!.isEmpty
        ? null
        : Text(
            note!,
            textDirection: sheenTextDirectionOf(note!),
            style: t.type.body.copyWith(color: t.colors.text, height: 1.35),
          );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SheenRadius.group),
      side: BorderSide(color: t.colors.separator),
    );

    if (compact) {
      return SheenPressable(
        onTap: onTap,
        semanticLabel: '$kind, $title',
        pressedScale: .98,
        child: Container(
          width: 264,
          padding: const EdgeInsets.all(SheenSpace.m),
          decoration: ShapeDecoration(color: t.colors.surface, shape: shape),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SheenArtwork(image: artwork, size: 48, radius: 10, round: round),
                  const SizedBox(width: SheenSpace.m),
                  Expanded(child: text),
                ],
              ),
              if (noteText != null) ...[const SizedBox(height: SheenSpace.s), noteText],
            ],
          ),
        ),
      );
    }

    return Container(
      width: 248,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: t.colors.surface, shape: shape),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheenPressable(
            onTap: onTap ?? onPlay,
            pressedScale: 1,
            child: SizedBox(
              height: artwork == null ? 96 : 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (artwork != null)
                    Image(
                      image: artwork!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(color: t.colors.surfaceMuted),
                    )
                  else
                    ColoredBox(
                      color: t.colors.surfaceMuted,
                      child: Center(child: SheenIcon(placeholderIcon, size: 28, color: t.colors.textSecondary)),
                    ),
                  if (onPlay != null)
                    PositionedDirectional(
                      end: 10,
                      bottom: 10,
                      child: SheenPressable(
                        onTap: onPlay,
                        semanticLabel: s.play,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.colors.accent,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Center(child: SheenIcon(SheenIcons.playFill, size: 18, color: t.colors.onAccent)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), child: text),
          if (noteText != null) Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 10), child: noteText),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: SheenPressable(
                        onTap: actions[i].onTap,
                        child: Container(
                          height: 34,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(color: t.colors.surfaceMuted, shape: const StadiumBorder()),
                          child: Text(
                            actions[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: scaler,
                            style: t.type.footnote.copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
