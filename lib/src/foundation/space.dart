import 'package:flutter/widgets.dart';

/// The 4 pt spacing grid.
///
/// {@category Foundation}
abstract final class SheenSpace {
  /// 4 pt.
  static const double xs = 4;

  /// 8 pt.
  static const double s = 8;

  /// 12 pt.
  static const double m = 12;

  /// 16 pt: the side inset of a phone screen.
  static const double l = 16;

  /// 20 pt.
  static const double xl = 20;

  /// 24 pt.
  static const double xxl = 24;

  /// 32 pt.
  static const double xxxl = 32;

  /// Every step of the grid, smallest first.
  static const List<double> values = [xs, s, m, l, xl, xxl, xxxl];

  /// The minimum touch target (44 pt, Apple's Human Interface Guidelines).
  static const double hit = 44;
}

/// Inner padding of the capsule buttons. Their heights come from a 48 pt minimum, so the vertical padding only keeps the
/// label off the edge at large text sizes.
///
/// {@category Foundation}
abstract final class SheenButtonInset {
  /// [SheenSecondaryButton]: 20 pt at the sides, 6 pt above and below.
  static const EdgeInsets secondary = EdgeInsets.symmetric(horizontal: SheenSpace.xl, vertical: 6);

  /// [SheenFloatingButton]: 18 pt at the sides, 6 pt above and below, a little tighter for a glass capsule over content.
  static const EdgeInsets floating = EdgeInsets.symmetric(horizontal: 18, vertical: 6);
}

/// Corner radii. Capsules use height / 2; a nested corner uses the outer radius minus the inset.
///
/// {@category Foundation}
abstract final class SheenRadius {
  /// Cards.
  static const double card = 24;

  /// Photos inside cards.
  static const double photo = 20;

  /// The top corners of sheets.
  static const double sheet = 38;

  /// Text fields.
  static const double field = 14;

  /// Grouped lists.
  static const double group = 20;

  /// A check box ([SheenCheck]).
  static const double check = 7;

  /// The glass bar at the bottom of a page ([SheenActionBar]).
  static const double actionBar = 36;
}

/// Sizes of small controls drawn by sheen itself.
///
/// {@category Foundation}
abstract final class SheenControlSize {
  /// The side of a check box ([SheenCheck]).
  static const double check = 24;

  /// The outline of an empty check box.
  static const double checkOutline = 2;

  /// The stroke of the tick in a ticked check box.
  static const double checkMark = 2.5;

  /// The space between [SheenActionBar]'s edge and its action button.
  static const double actionBarInset = 10;
}

/// Widths for larger windows (tablets, desktop, the web).
///
/// On a phone, content keeps 16 pt sides; on a wider window it is centred at a readable width while photos, maps
/// and backgrounds still run edge to edge.
///
/// {@category Layout}
abstract final class SheenLayout {
  /// One column of content: lists, forms, long text.
  static const double readable = 720;

  /// Grids: cards two across, photo tiles.
  static const double wide = 1080;

  /// The widest a sheet grows.
  static const double sheet = 640;

  /// The side inset that centres content of at most [max] in a window [width] wide, never under [min].
  static double inset(double width, {double max = readable, double min = 16}) {
    final centred = (width - max) / 2;
    return centred > min ? centred : min;
  }

  /// From this width (a tablet, not Split View or Slide Over) use the wide layouts: the tab bar at the top, a list
  /// beside its detail, forms in a centred sheet.
  static const double splitMin = 700;

  /// Whether a window [width] wide takes the wide layouts ([splitMin]).
  static bool isWide(double width) => width >= splitMin;

  /// From this width (a tablet in landscape) a page keeps a side pane.
  static const double paneMin = 1000;

  /// Whether a window [width] wide keeps a side pane ([paneMin]).
  static bool hasSidePane(double width) => width >= paneMin;

  /// Cards across in a grid: two from [splitMin], else one.
  static int columns(double width) => width >= splitMin ? 2 : 1;

  /// Photo tiles across: four from [paneMin], three from [splitMin], else two.
  static int tiles(double width) => width >= paneMin ? 4 : (width >= splitMin ? 3 : 2);
}

/// `context.contentInset`: the side inset of a readable column in this window.
///
/// {@category Layout}
extension SheenLayoutContext on BuildContext {
  /// The side inset of a readable column in this window ([SheenLayout.inset]): 16 on a phone.
  double get contentInset => SheenLayout.inset(MediaQuery.sizeOf(this).width);
}
