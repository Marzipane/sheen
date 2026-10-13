import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A card for a carousel of tours or cruises: a photo with an optional tag (a cruise line, "Guaranteed"), a small line
/// above the title (the operator or the ship), the title, the facts ("8 days · Turkey") and the price from, with what
/// it is for ("a person"). 232 points wide by default, the size of [SheenPremiumCard]; [heightFor] gives the row
/// height for a text size.
///
/// {@category Travel}
class SheenTripCard extends StatelessWidget {
  /// A card for the trip [title].
  const SheenTripCard({
    super.key,
    required this.title,
    required this.onTap,
    this.eyebrow,
    this.facts,
    this.price,
    this.priceLabel,
    this.photo,
    this.noPhotoLabel,
    this.placeholderIcon = SheenIcons.compass,
    this.tag,
    this.width = 232,
  });

  /// The trip's name.
  final String title;

  /// A short line above [title]: who runs it or the ship.
  final String? eyebrow;

  /// The length and where: "8 days · Turkey", "7 nights · from Piraeus".
  final String? facts;

  /// The lowest price, formatted with "from": "from AED 2,872".
  final String? price;

  /// What [price] is for, after it: "a person", "a cabin".
  final String? priceLabel;

  /// The photo; the placeholder with [placeholderIcon] when null.
  final Widget? photo;

  /// The placeholder's label.
  final String? noPhotoLabel;

  /// The placeholder's glyph: [SheenIcons.compass] for tours, [SheenIcons.ship] for cruises.
  final String placeholderIcon;

  /// A chip on the photo, top start: the cruise line ("NCL") or a word such as "Guaranteed".
  final String? tag;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// The card width.
  final double width;

  /// The height a carousel row needs for these cards at the user's text size: the 154 pt photo, the 10 pt gap, the
  /// eyebrow, the title, the facts and the price line at their scaled line heights.
  static double heightFor(TextScaler scaler) {
    double line(double size, double height) => scaler.scale(size) * height;
    final priceRow = line(15, 1.2) > line(12, 1.25) ? line(15, 1.2) : line(12, 1.25);
    return (154 + 10 + line(12, 1.3) + 2 + line(16, 1.25) + 3 + line(13, 1.3) + 3 + priceRow).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final summary = [
      title,
      eyebrow,
      tag,
      facts,
      if (price != null) [price, priceLabel].whereType<String>().join(' '),
    ].whereType<String>().join(', ');
    return SheenPressable(
      onTap: onTap,
      semanticLabel: summary,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 154,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExcludeSemantics(
                      child: photo ?? SheenImagePlaceholder(label: noPhotoLabel, icon: placeholderIcon, iconSize: 30),
                    ),
                    if (tag != null)
                      PositionedDirectional(start: 8, top: 8, child: ExcludeSemantics(child: SheenTripTag(tag!))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // the eyebrow's line is kept when empty, so cards of a row line up
                    Text(
                      eyebrow ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.type.caption.copyWith(
                        color: t.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .2,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.type.sized(t.type.headline, 16).copyWith(color: t.colors.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      facts ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.type.footnote.copyWith(color: t.colors.textSecondary, height: 1.3),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      strutStyle: StrutStyle.fromTextStyle(t.type.sized(t.type.price, 15), forceStrutHeight: true),
                      TextSpan(
                        style: t.type.sized(t.type.price, 15).copyWith(color: t.colors.text),
                        children: [
                          TextSpan(text: price ?? ''),
                          if (price != null && priceLabel != null) ...[
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: priceLabel,
                              style: t.type.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: t.colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small dark chip for a photo: a cruise line, "Guaranteed". Readable on any photo in both looks.
///
/// {@category Travel}
class SheenTripTag extends StatelessWidget {
  /// A chip that says [label].
  const SheenTripTag(this.label, {super.key});

  /// The words on the chip.
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xCC0B0F17), borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.type.caption.copyWith(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// One stop of a [SheenItinerary]: a day of a tour or a port of a cruise.
///
/// {@category Travel}
@immutable
class SheenItineraryStop {
  /// A stop called [title], marked with [marker] ("1", "Day 1").
  const SheenItineraryStop({
    required this.marker,
    required this.title,
    this.subtitle,
    this.detail,
    this.trailing,
    this.quiet = false,
  });

  /// What the dot says, short: the day's number.
  final String marker;

  /// The place or the day's heading.
  final String title;

  /// A line under [title]: the country, "Tender port".
  final String? subtitle;

  /// The day's description; shown in full.
  final String? detail;

  /// At the end of the title's line: "08:00 – 17:00".
  final String? trailing;

  /// A quieter stop, such as a day at sea: a hollow dot and muted words.
  final bool quiet;
}

/// A tour's days or a cruise's ports, top to bottom, on a line that joins numbered dots.
///
/// {@category Travel}
class SheenItinerary extends StatelessWidget {
  /// The [stops] in order.
  const SheenItinerary({super.key, required this.stops});

  /// The days or ports, first to last.
  final List<SheenItineraryStop> stops;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stops.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stops[i].quiet ? null : t.colors.accent,
                          border: stops[i].quiet ? Border.all(color: t.colors.textSecondary, width: 1.5) : null,
                        ),
                        child: ExcludeSemantics(
                          child: Text(
                            stops[i].marker,
                            maxLines: 1,
                            style: t.type.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: stops[i].quiet ? t.colors.textSecondary : t.colors.onAccent,
                            ),
                          ),
                        ),
                      ),
                      if (i < stops.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            color: t.colors.separator,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3, bottom: i < stops.length - 1 ? 18 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                stops[i].title,
                                style: t.type.headline.copyWith(
                                  color: stops[i].quiet ? t.colors.textSecondary : t.colors.text,
                                ),
                              ),
                            ),
                            // the times wrap rather than push the place out at large text sizes
                            if (stops[i].trailing != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  stops[i].trailing!,
                                  textAlign: TextAlign.end,
                                  style: t.type.footnote.copyWith(
                                    color: t.colors.textSecondary,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (stops[i].subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(stops[i].subtitle!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
                        ],
                        if (stops[i].detail != null) ...[
                          const SizedBox(height: 6),
                          Text(stops[i].detail!, style: t.type.body.copyWith(color: t.colors.text)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The glyph for a trip kind, for lists and buttons: a compass for tours, a ship for cruises.
///
/// {@category Travel}
class SheenTripIcon extends StatelessWidget {
  /// A [cruise] ship or a tour's compass, [size] points.
  const SheenTripIcon({super.key, this.cruise = false, this.size = 22, this.color});

  /// A ship when true, else a compass.
  final bool cruise;

  /// The glyph size in points.
  final double size;

  /// The colour; the text colour when null.
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      SheenIcon(cruise ? SheenIcons.ship : SheenIcons.compass, size: size, color: color ?? context.sheen.colors.text);
}
