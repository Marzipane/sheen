import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// The order of the wheels in [showSheenDateSheet].
///
/// {@category Sheets}
enum SheenDateOrder {
  /// Day, month, year (most of the world).
  dayMonthYear,

  /// Month, day, year (the United States).
  monthDayYear,

  /// Year, month, day (East Asia, ISO).
  yearMonthDay,
}

/// The English month names, the default of [showSheenDateSheet].
const List<String> _englishMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Opens a sheet with day, month and year wheels and returns the date shown when Done is tapped, or null when the
/// sheet is closed.
///
/// The date stays inside [first]..[last]: a wheel turned past either end springs back. A day past the end of a month
/// becomes the month's last day. Pass translated [monthLabels] and the locale's [order].
///
/// ```dart
/// final birthday = await showSheenDateSheet(
///   context: context,
///   title: 'Date of birth',
///   first: DateTime(1920),
///   last: DateTime.now(),
///   initial: DateTime(1990, 5, 17),
/// );
/// ```
///
/// {@category Sheets}
Future<DateTime?> showSheenDateSheet({
  required BuildContext context,
  required String title,
  required DateTime first,
  required DateTime last,
  DateTime? initial,
  List<String>? monthLabels,
  SheenDateOrder order = SheenDateOrder.dayMonthYear,
  String? doneLabel,
  String? cancelLabel,
}) async {
  assert(!last.isBefore(first));
  assert(monthLabels == null || monthLabels.length == 12);
  var picked = SheenDateWheels.clamp(initial ?? last, first, last);
  final done = await showSheenCustomSheet<bool>(
    context: context,
    medium: .45,
    large: .45,
    startLarge: false,
    builder: (sheetContext, scroll) => Builder(
      builder: (context) => SheenSheetBody(
        title: title,
        cancelLabel: cancelLabel,
        doneLabel: doneLabel ?? SheenStrings.of(context).done,
        onCancel: () => Navigator.of(sheetContext).pop(false),
        onDone: () => Navigator.of(sheetContext).pop(true),
        child: SingleChildScrollView(
          controller: scroll,
          child: SheenDateWheels(
            first: first,
            last: last,
            initial: picked,
            monthLabels: monthLabels ?? _englishMonths,
            order: order,
            onChanged: (d) => picked = d,
          ),
        ),
      ),
    ),
  );
  return done == true ? picked : null;
}

/// Day, month and year wheels, as [showSheenDateSheet] shows them; usable on their own in a page.
///
/// {@category Sheets}
class SheenDateWheels extends StatefulWidget {
  /// Wheels showing [initial], kept inside [first]..[last].
  const SheenDateWheels({
    super.key,
    required this.first,
    required this.last,
    required this.initial,
    required this.onChanged,
    this.monthLabels = _englishMonths,
    this.order = SheenDateOrder.dayMonthYear,
  });

  /// The earliest date that can be picked.
  final DateTime first;

  /// The latest date that can be picked.
  final DateTime last;

  /// The date shown first.
  final DateTime initial;

  /// Called with the date shown whenever a wheel settles.
  final ValueChanged<DateTime> onChanged;

  /// The twelve month names, January first.
  final List<String> monthLabels;

  /// The order of the wheels.
  final SheenDateOrder order;

  /// The height of one row.
  static const double rowHeight = 36;

  /// [date] without its time, kept inside [first]..[last].
  static DateTime clamp(DateTime date, DateTime first, DateTime last) {
    final d = DateTime(date.year, date.month, date.day);
    final lo = DateTime(first.year, first.month, first.day), hi = DateTime(last.year, last.month, last.day);
    return d.isBefore(lo) ? lo : (d.isAfter(hi) ? hi : d);
  }

  @override
  State<SheenDateWheels> createState() => _SheenDateWheelsState();
}

class _SheenDateWheelsState extends State<SheenDateWheels> {
  late DateTime _date = SheenDateWheels.clamp(widget.initial, widget.first, widget.last);
  late final FixedExtentScrollController _day = FixedExtentScrollController(initialItem: _date.day - 1);
  late final FixedExtentScrollController _month = FixedExtentScrollController(initialItem: _date.month - 1);
  late final FixedExtentScrollController _year = FixedExtentScrollController(
    initialItem: _date.year - widget.first.year,
  );

  @override
  void dispose() {
    _day.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  void _set({int? year, int? month, int? day}) {
    final y = year ?? _date.year, m = month ?? _date.month;
    final d = (day ?? _date.day).clamp(1, SheenDateRangeCalendar.daysIn(DateTime(y, m)));
    final next = SheenDateWheels.clamp(DateTime(y, m, d), widget.first, widget.last);
    if (next != _date) HapticFeedback.selectionClick();
    setState(() => _date = next);
    widget.onChanged(next);
    // a wheel that asked for a date out of range (or a day past the month's end) springs back to the date shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final (c, i) in [(_day, next.day - 1), (_month, next.month - 1), (_year, next.year - widget.first.year)]) {
        if (c.hasClients && c.selectedItem != i) {
          c.animateToItem(i, duration: SheenMotion.snappySettle, curve: SheenMotion.curveOf(SheenMotion.snappy));
        }
      }
    });
  }

  Widget _wheel({
    required Key key,
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int i) label,
    required int selected,
    required ValueChanged<int> onSelected,
    required int flex,
  }) {
    final t = context.sheen;
    return Expanded(
      flex: flex,
      child: Semantics(
        value: label(selected),
        increasedValue: selected + 1 < count ? label(selected + 1) : null,
        decreasedValue: selected > 0 ? label(selected - 1) : null,
        onIncrease: selected + 1 < count ? () => onSelected(selected + 1) : null,
        onDecrease: selected > 0 ? () => onSelected(selected - 1) : null,
        child: ExcludeSemantics(
          child: ListWheelScrollView.useDelegate(
            key: key,
            controller: controller,
            itemExtent: SheenDateWheels.rowHeight,
            diameterRatio: 1.4,
            overAndUnderCenterOpacity: .45,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, i) => Center(
                child: Text(
                  label(i),
                  maxLines: 1,
                  style: t.type.body.copyWith(color: t.colors.text, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final w = widget;
    final day = _wheel(
      key: const ValueKey('sheen-date-day'),
      controller: _day,
      count: SheenDateRangeCalendar.daysIn(_date),
      label: (i) => '${i + 1}',
      selected: _date.day - 1,
      onSelected: (i) => _set(day: i + 1),
      flex: 2,
    );
    final month = _wheel(
      key: const ValueKey('sheen-date-month'),
      controller: _month,
      count: 12,
      label: (i) => w.monthLabels[i],
      selected: _date.month - 1,
      onSelected: (i) => _set(month: i + 1),
      flex: 4,
    );
    final year = _wheel(
      key: const ValueKey('sheen-date-year'),
      controller: _year,
      count: w.last.year - w.first.year + 1,
      label: (i) => '${w.first.year + i}',
      selected: _date.year - w.first.year,
      onSelected: (i) => _set(year: w.first.year + i),
      flex: 3,
    );
    final wheels = switch (w.order) {
      SheenDateOrder.dayMonthYear => [day, month, year],
      SheenDateOrder.monthDayYear => [month, day, year],
      SheenDateOrder.yearMonthDay => [year, month, day],
    };
    return SizedBox(
      height: SheenDateWheels.rowHeight * 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // the band behind the chosen row
          Positioned(
            left: 12,
            right: 12,
            height: SheenDateWheels.rowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.track.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: wheels),
          ),
        ],
      ),
    );
  }
}
