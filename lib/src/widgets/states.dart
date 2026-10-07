import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A placeholder block for content that is loading, swept by a soft highlight every 1.2 seconds; still with Reduce
/// Motion. Without a [width] it fills the width it is given.
///
/// {@category Feedback}
class SheenSkeleton extends StatefulWidget {
  /// A placeholder block.
  const SheenSkeleton({super.key, this.width, this.height, this.radius = 8});

  /// The width; the available width when null.
  final double? width;

  /// The height.
  final double? height;

  /// The corner radius.
  final double radius;

  @override
  State<SheenSkeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<SheenSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (SheenMotion.reduced(context)) {
      _sweep
        ..stop()
        ..value = .5;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    // dark sweeps from the muted surface up to the track colour; light from the track down to the muted surface
    final base = t.isDark ? t.colors.surfaceMuted : t.colors.track;
    final high = t.isDark ? t.colors.track : t.colors.surfaceMuted;
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (context, _) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [base, high, base],
              stops: const [0, .4, .8],
              transform: _Slide(_sweep.value * 2 - 1),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * t, 0, 0);
}

/// An empty list or a dead end: a glyph in a glass circle, a title and your message. [compact] is the small form for
/// sheets and side panes.
/// ```dart
/// const SheenEmptyState(icon: SheenIcons.search, title: 'No results', message: 'Try fewer filters.')
/// ```
/// {@category Feedback}
class SheenEmptyState extends StatelessWidget {
  /// An empty state titled [title].
  const SheenEmptyState({super.key, required this.icon, required this.title, this.message, this.compact = false});

  /// The glyph ([SheenIcons]).
  final String icon;

  /// What happened, briefly.
  final String title;

  /// What to do next.
  final String? message;

  /// Uses the small form.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final circle = compact ? 52.0 : 72.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheenGlass(
          shape: const CircleBorder(),
          child: SizedBox.square(
            dimension: circle,
            child: Center(
              child: SheenIcon(icon, size: compact ? 24 : 32, stroke: 2, color: t.colors.textSecondary),
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 16),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: (compact ? t.type.subhead.copyWith(fontWeight: FontWeight.w700) : t.type.sized(t.type.title, 24))
                .copyWith(color: t.colors.text),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: (compact ? t.type.footnote : t.type.subhead.copyWith(height: 1.45)).copyWith(
              color: t.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A way out of an empty state ("Try instead"): a title, an optional line under it and a chevron.
///
/// {@category Feedback}
class SheenSuggestionCard extends StatelessWidget {
  /// A suggestion titled [title].
  const SheenSuggestionCard({super.key, required this.title, this.subtitle, required this.onTap});

  /// The suggestion.
  final String title;

  /// A line under it, such as a count.
  final String? subtitle;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return SheenPressable(
      onTap: onTap,
      semanticLabel: subtitle == null ? title : '$title, $subtitle',
      child: SheenCard(
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: t.type
                            .sized(t.type.body, 16)
                            .copyWith(fontWeight: FontWeight.w600, color: t.colors.text),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: t.type.footnote.copyWith(color: t.colors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SheenIcon(SheenIcons.chevron, size: 18, stroke: 2, color: t.colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wait the user can see, such as "Checking live prices": a glass capsule with a spinner and a label, announced to
/// screen readers as a live region.
///
/// {@category Feedback}
class SheenProgressCapsule extends StatelessWidget {
  /// A capsule showing [label].
  const SheenProgressCapsule({super.key, required this.label, this.compact = false});

  /// What is happening.
  final String label;

  /// Uses the small form.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: compact ? 38 : 48),
        child: SheenGlass(
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 14, end: compact ? 14 : 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SheenSpinner(
                  size: compact ? 16 : 20,
                  stroke: compact ? 2 : 2.5,
                  color: t.colors.accentText,
                  trackColor: t.colors.text.withValues(alpha: .18),
                ),
                SizedBox(width: compact ? 8 : 10),
                Flexible(
                  child: Text(
                    label,
                    style: (compact ? t.type.footnote : t.type.subhead).copyWith(
                      fontWeight: FontWeight.w600,
                      color: t.colors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
