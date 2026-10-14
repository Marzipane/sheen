import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import 'artwork.dart';

/// A cover with one or two lines under it, for a shelf of albums, mixes or artists. Artists are [round] and centred.
///
/// {@category Music}
class SheenArtworkTile extends StatelessWidget {
  /// A tile for [title].
  const SheenArtworkTile({
    super.key,
    required this.title,
    this.subtitle,
    this.artwork,
    this.size = 144,
    this.round = false,
    this.onTap,
    this.onLongPress,
  });

  /// The first line.
  final String title;

  /// The second line.
  final String? subtitle;

  /// The cover.
  final ImageProvider? artwork;

  /// The cover's side; the tile is as wide.
  final double size;

  /// A round cover with centred text, for artists.
  final bool round;

  /// Opens it.
  final VoidCallback? onTap;

  /// A menu, for example.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.4);
    final align = round ? TextAlign.center : TextAlign.start;
    return SheenPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: round ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SheenArtwork(image: artwork, size: size, round: round, radius: 14),
            const SizedBox(height: SheenSpace.s),
            Text(title, textDirection: sheenTextDirectionOf(title), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: align, textScaler: scaler, style: t.type.subhead.copyWith(color: t.colors.text, fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle!, textDirection: sheenTextDirectionOf(subtitle!), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: align, textScaler: scaler, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// A titled row of tiles that scrolls sideways, with an optional "See all" link, as on a music home page.
///
/// {@category Music}
class SheenShelf extends StatelessWidget {
  /// A shelf called [title] holding [children].
  const SheenShelf({
    super.key,
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
    this.spacing = SheenSpace.m,
    this.padding = const EdgeInsetsDirectional.symmetric(horizontal: SheenSpace.l),
  });

  /// The heading.
  final String title;

  /// The tiles.
  final List<Widget> children;

  /// The link at the end of the heading.
  final String? actionLabel;

  /// Called by the link.
  final VoidCallback? onAction;

  /// The gap between tiles.
  final double spacing;

  /// The inset of the heading and of the first and last tile.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(child: Semantics(header: true, child: Text(title, style: t.type.title.copyWith(color: t.colors.text)))),
              if (actionLabel != null) SheenTextLink(label: actionLabel!, onPressed: onAction, size: 15),
            ],
          ),
        ),
        const SizedBox(height: SheenSpace.m),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: spacing), children[i]],
            ],
          ),
        ),
      ],
    );
  }
}
