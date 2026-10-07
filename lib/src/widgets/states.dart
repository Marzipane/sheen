import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A placeholder block (C3 SheenSkeleton): the boards' gradient, swept every 1.2 s; static when motion is reduced. Without
/// a [width] it fills the width it is given, like the boards' block spans.
class SheenSkeleton extends StatefulWidget {
  const SheenSkeleton({super.key, this.width, this.height, this.radius = 8});

  final double? width;
  final double? height;
  final double radius;

  /// The boards' dark sweep (`.sk`): #141922 → #1C2230 at 40 % → #141922 at 80 %. Light uses s3 → s2 → s3.
  static const Color _darkBase = Color(0xFF141922), _darkHigh = Color(0xFF1C2230);

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
    final base = t.isDark ? SheenSkeleton._darkBase : t.colors.track;
    final high = t.isDark ? SheenSkeleton._darkHigh : t.colors.surfaceMuted;
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

class SheenEmptyState extends StatelessWidget {
  const SheenEmptyState({super.key, required this.icon, required this.title, this.message, this.compact = false});

  final String icon;
  final String title;
  final String? message;
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

/// A way out of an empty state (D20 "Try instead"): title, a count line, a chevron.
class SheenSuggestionCard extends StatelessWidget {
  const SheenSuggestionCard({super.key, required this.title, this.subtitle, required this.onTap});

  final String title;
  final String? subtitle;
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

/// A wait the user can see (C3 SheenProgressCapsule, D18 "Checking live prices"): glass capsule, spinner, label. Announced
/// as a live region.
class SheenProgressCapsule extends StatelessWidget {
  const SheenProgressCapsule({super.key, required this.label, this.compact = false});

  final String label;
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
