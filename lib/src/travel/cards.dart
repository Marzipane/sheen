import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';
import 'package:sheen/travel.dart';

/// A hotel in a list of results: a photo pager with Save; the name and the total; a headline and the price per night;
/// the score, a recommendation share and the board; the cancellation line.
///
/// Every text but [name] and [total] is optional and simply left out when you do not have it. The whole card is one
/// button; Save is its own. Prices and labels are the caller's, formatted and translated.
/// ```dart
/// SheenHotelCard(
///   name: 'Hotel Aurora',
///   total: '€ 1,448',
///   perNight: '€ 724 a night',
///   headline: 'Old Town · 0.4 km to the centre',
///   score: '9.1',
///   cancellation: 'Free cancellation until 12 Oct',
///   refundable: true,
///   photoCount: photos.length,
///   photoBuilder: (context, i) => Image.network(photos[i], fit: BoxFit.cover),
///   noPhotoLabel: 'No photo',
///   saveLabel: 'Save',
///   onTap: open,
/// )
/// ```
/// {@category Travel}
class SheenHotelCard extends StatelessWidget {
  /// A result card for the hotel [name].
  const SheenHotelCard({
    super.key,
    required this.name,
    required this.total,
    required this.photoCount,
    required this.photoBuilder,
    required this.noPhotoLabel,
    required this.saveLabel,
    required this.onTap,
    this.perNight,
    this.headline,
    this.score,
    this.recommend,
    this.board,
    this.cancellation,
    this.refundable = false,
    this.saved = false,
    this.onSave,
  });

  /// The hotel name.
  final String name;

  /// The total price, formatted.
  final String total;

  /// The price per night, formatted with its words ("€ 724 a night").
  final String? perNight;

  /// A line about the place, such as the area and a distance.
  final String? headline;

  /// The guest score, shown on a [SheenScoreBadge].
  final String? score;

  /// A recommendation share, such as "92 % recommend".
  final String? recommend;

  /// The meal plan, such as "Breakfast included".
  final String? board;

  /// The cancellation terms, such as "Free cancellation until 12 Oct" or "Non-refundable".
  final String? cancellation;

  /// Colours [cancellation] as good news.
  final bool refundable;

  /// The number of photos; 0 shows the placeholder.
  final int photoCount;

  /// Builds the photo at an index.
  final IndexedWidgetBuilder photoBuilder;

  /// The placeholder's label when there is no photo.
  final String noPhotoLabel;

  /// Whether the hotel is saved.
  final bool saved;

  /// The Save button's label for screen readers.
  final String saveLabel;

  /// Called by Save; null hides Save (for example when signed out).
  final VoidCallback? onSave;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// The height of the photo area.
  static const double photoHeight = 196;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final small = t.type.footnote.copyWith(color: t.colors.textSecondary);
    final summary = [
      name,
      total,
      perNight,
      headline,
      score,
      recommend,
      board,
      cancellation,
    ].whereType<String>().join(', ');
    return SheenPressable(
      onTap: onTap,
      semanticLabel: summary,
      pressedScale: .98,
      child: SheenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: photoHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: photoCount == 0
                        ? SheenImagePlaceholder(label: noPhotoLabel, icon: SheenIcons.bedFill)
                        : SheenPhotoPager(count: photoCount, photoBuilder: photoBuilder),
                  ),
                  if (onSave != null)
                    PositionedDirectional(
                      end: 7,
                      top: 7,
                      child: SheenSaveButton(
                        saved: saved,
                        onTap: onSave!,
                        semanticLabel: saveLabel,
                        onPhoto: photoCount > 0,
                      ),
                    ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
                // Prices never truncate: past 62 % of the width the total scales down and the nightly rate wraps.
                child: LayoutBuilder(
                  builder: (context, box) {
                    final priceMax = box.maxWidth * .62;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.type.sized(t.type.headline, 18, extraEm: -.01).copyWith(color: t.colors.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: priceMax),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerEnd,
                                child: Text(
                                  total,
                                  style: t.type.sized(t.type.price, 18).copyWith(color: t.colors.text),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (headline != null || perNight != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  headline ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.type.sized(t.type.subhead, 14).copyWith(color: t.colors.textSecondary),
                                ),
                              ),
                              if (perNight != null) ...[
                                const SizedBox(width: 12),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: priceMax),
                                  child: Text(
                                    perNight!,
                                    textAlign: TextAlign.end,
                                    style: small.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (score != null || recommend != null || board != null) ...[
                          const SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    if (score != null) SheenScoreBadge(score!),
                                    if (score != null && recommend != null) const SizedBox(width: 8),
                                    if (recommend != null)
                                      Flexible(
                                        child: Text(
                                          recommend!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: small,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (board != null) ...[
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    board!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: small,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (cancellation != null) ...[
                          const SizedBox(height: 7),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SheenCancellationLine(text: cancellation!, refundable: refundable),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card for a carousel of featured stays: a photo with Save, the name, score and headline, and the total with a
/// nights label. 232 points wide by default; [heightFor] gives the row height for a text size.
///
/// {@category Travel}
class SheenPremiumCard extends StatelessWidget {
  /// A featured card for the hotel [name].
  const SheenPremiumCard({
    super.key,
    required this.name,
    required this.total,
    required this.nightsLabel,
    required this.saveLabel,
    required this.onTap,
    this.photo,
    this.noPhotoLabel,
    this.score,
    this.headline,
    this.saved = false,
    this.onSave,
    this.width = 232,
  });

  /// The hotel name.
  final String name;

  /// The total price, formatted.
  final String total;

  /// The words after the total, such as "for 2 nights".
  final String nightsLabel;

  /// The photo; the placeholder when null.
  final Widget? photo;

  /// The placeholder's label.
  final String? noPhotoLabel;

  /// The guest score.
  final String? score;

  /// A line about the place.
  final String? headline;

  /// Whether the hotel is saved.
  final bool saved;

  /// The Save button's label for screen readers.
  final String saveLabel;

  /// Called by Save; null hides Save.
  final VoidCallback? onSave;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// The card width.
  final double width;

  /// The height a carousel row needs for these cards at the user's text size: the 154 pt photo, the 10 pt gap and
  /// the three text lines at their scaled line heights (the score badge keeps its 20 pt minimum).
  static double heightFor(TextScaler scaler) {
    double line(double size, double height) => scaler.scale(size) * height;
    final scoreRow = line(13, 1.3) > 20 ? line(13, 1.3) : 20.0;
    final priceRow = line(15, 1.2) > line(12, 1.25) ? line(15, 1.2) : line(12, 1.25);
    return (154 + 10 + line(16, 1.25) + 3 + scoreRow + 3 + priceRow).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final summary = [name, score, headline, '$total $nightsLabel'].whereType<String>().join(', ');
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
                      child:
                          photo ?? SheenImagePlaceholder(label: noPhotoLabel, icon: SheenIcons.bedFill, iconSize: 30),
                    ),
                    if (onSave != null)
                      PositionedDirectional(
                        end: 4,
                        top: 4,
                        child: SheenSaveButton(
                          saved: saved,
                          onTap: onSave!,
                          semanticLabel: saveLabel,
                          size: 36,
                          onPhoto: photo != null,
                        ),
                      ),
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
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.type.sized(t.type.headline, 16).copyWith(color: t.colors.text),
                    ),
                    if (score != null || headline != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (score != null) SheenScoreBadge(score!, size: SheenScoreSize.small),
                          if (score != null && headline != null) const SizedBox(width: 6),
                          if (headline != null)
                            Flexible(
                              child: Text(
                                headline!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.type.footnote.copyWith(color: t.colors.textSecondary),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text.rich(
                      // The root carries the price style, so the space between does not fall back to the ambient style.
                      // The line keeps the price's height whatever the script: a nights label in Arabic falls back to a font
                      // with other ascent and descent, and the mixed line grew past heightFor (R01).
                      strutStyle: StrutStyle.fromTextStyle(t.type.sized(t.type.price, 15), forceStrutHeight: true),
                      TextSpan(
                        style: t.type.sized(t.type.price, 15).copyWith(color: t.colors.text),
                        children: [
                          TextSpan(text: total),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: nightsLabel,
                            style: t.type.caption.copyWith(fontWeight: FontWeight.w500, color: t.colors.textSecondary),
                          ),
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

/// How a destination's visa rule reads for a passport; it picks the colour of the rule's dot on a [SheenCityTile].
///
/// {@category Travel}
enum SheenVisaKind {
  /// No visa needed.
  free,

  /// A visa is issued on arrival.
  onArrival,

  /// An electronic travel authorisation is needed before the trip.
  eta,

  /// A visa is needed before the trip.
  required,
}

/// A destination: a city photo with a darkened foot, the name and distance, and the visa rule with its coloured dot.
/// Without a photo it is a plain card with the same text.
///
/// {@category Travel}
class SheenCityTile extends StatelessWidget {
  /// A tile for the city [name].
  const SheenCityTile({
    super.key,
    required this.name,
    required this.onTap,
    this.distance,
    this.rule,
    this.kind,
    this.photo,
    this.width = 171,
    this.height = 150,
  });

  /// The city name.
  final String name;

  /// A distance or flight time, formatted.
  final String? distance;

  /// The visa rule in words, such as "Visa-free · 30 days".
  final String? rule;

  /// The kind of rule; it colours the dot before [rule].
  final SheenVisaKind? kind;

  /// The city photo; a plain card when null.
  final Widget? photo;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  /// The tile width.
  final double? width;

  /// The tile height.
  final double? height;

  static Color _dot(SheenColors c, SheenVisaKind k) => switch (k) {
    SheenVisaKind.free => c.success,
    SheenVisaKind.onArrival || SheenVisaKind.eta => c.warning,
    SheenVisaKind.required => c.danger,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final onPhoto = photo != null;
    // Over a photo the foot is always dark, so the text is white and the dots use the dark palette in both themes.
    final colors = onPhoto ? SheenColors.dark() : t.colors;
    final ink = onPhoto ? const Color(0xFFFFFFFF) : t.colors.text;
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: t.type.headline.copyWith(fontWeight: FontWeight.w700, color: ink),
    );
    final distanceText = distance == null
        ? null
        : Text(
            distance!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.type
                .sized(t.type.caption, 11)
                .copyWith(
                  color: ink.withValues(alpha: onPhoto ? .85 : 1),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          );
    // at large text sizes the distance takes its own line rather than squeezing the name
    final stacked = MediaQuery.textScalerOf(context).scale(10) > 13;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stacked) ...[
          nameText,
          ?distanceText,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: nameText),
              if (distanceText != null) ...[const SizedBox(width: 6), distanceText],
            ],
          ),
        if (rule != null) ...[
          const SizedBox(height: 1),
          Row(
            children: [
              if (kind != null) ...[
                SizedBox.square(
                  dimension: 7,
                  child: DecoratedBox(
                    key: const ValueKey('visa-dot'),
                    decoration: BoxDecoration(color: _dot(colors, kind!), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  rule!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.type.caption.copyWith(color: onPhoto ? ink : t.colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
    return SheenPressable(
      onTap: onTap,
      semanticLabel: [name, distance, rule].whereType<String>().join(', '),
      child: SizedBox(
        width: width,
        height: height,
        child: ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: t.colors.surfaceMuted,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (onPhoto) photo!,
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: onPhoto
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x00000000), Color(0xB8000000)],
                              )
                            : null,
                      ),
                      child: Padding(padding: const EdgeInsets.fromLTRB(12, 28, 12, 10), child: text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [SheenHotelCard] while results load: a photo block, name and price bars and two text lines, shimmering (still with
/// Reduce Motion).
///
/// {@category Travel}
class SheenHotelCardSkeleton extends StatelessWidget {
  /// A loading placeholder for a hotel card.
  const SheenHotelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SheenCard(
      child: SizedBox(
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheenSkeleton(height: 196, radius: 0),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: SheenSkeleton(width: 170, height: 18)),
                      SizedBox(width: 12),
                      Flexible(child: SheenSkeleton(width: 110, height: 18)),
                    ],
                  ),
                  SizedBox(height: 10),
                  SheenSkeleton(width: 130, height: 13),
                  SizedBox(height: 12),
                  SheenSkeleton(width: 210, height: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
