import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';

/// The photo you tapped becomes the next page's photo (like iOS's zoom transition): give the card's photo and the
/// page's photo the same [tag]. In flight the card's photo shows (it is already loaded), its corners turning from the
/// card's [radius] into the page's. With Reduce Motion there is no flight: the page changes as its route does.
///
/// The flight needs a `HeroController`: `MaterialApp` and `CupertinoApp` add one; with a `WidgetsApp`, pass
/// `navigatorObservers: [HeroController()]`.
///
/// {@category Motion}
class SheenPhotoHero extends StatelessWidget {
  /// A photo that flies to the photo with the same [tag] on the next route.
  const SheenPhotoHero({super.key, required this.tag, required this.child, this.radius = BorderRadius.zero});

  /// Pairs this photo with the one on the other route.
  final Object tag;

  /// The photo.
  final Widget child;

  /// The corners the photo has where it sits (the card's clip).
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    if (SheenMotion.reduced(context)) return child;
    return Hero(
      tag: tag,
      flightShuttleBuilder: _shuttle,
      child: _HeroPhoto(radius: radius, child: child),
    );
  }

  static Widget _shuttle(
    BuildContext flight,
    Animation<double> a,
    HeroFlightDirection direction,
    BuildContext from,
    BuildContext to,
  ) {
    final fromPhoto = (from.widget as Hero).child as _HeroPhoto;
    final toPhoto = (to.widget as Hero).child as _HeroPhoto;
    // the animation is the upper page's both ways: 0 is the card on the page below, 1 the photo on the page above
    final lower = direction == HeroFlightDirection.push ? fromPhoto : toPhoto;
    final upper = direction == HeroFlightDirection.push ? toPhoto : fromPhoto;
    return AnimatedBuilder(
      animation: a,
      child: lower.child,
      builder: (context, child) =>
          ClipRRect(borderRadius: BorderRadius.lerp(lower.radius, upper.radius, a.value)!, child: child),
    );
  }
}

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.radius, required this.child});

  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
