import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// One month of a date-range picker: past days off, today in the accent, the range ends on prominent glass and the
/// days between them on a band.
///
/// It draws one month; [SheenDateRangePicker] adds the month header, arrows and swipe. Taps report a day through
/// [onDay]; deciding which end it sets is the caller's (see the example).
///
/// ```dart
/// SheenDateRangeCalendar(
///   month: DateTime(2026, 10),
///   today: DateTime.now(),
///   start: start,
///   end: end,
///   weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
///   firstDayOfWeek: DateTime.sunday,
///   onDay: pick,
/// )
/// ```
///
/// {@category Selection}
class SheenDateRangeCalendar extends StatelessWidget {
  /// One month around [month], with [start]–[end] marked.
  const SheenDateRangeCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.weekdayLabels,
    required this.onDay,
    this.start,
    this.end,
    this.lastDay,
    this.dayLabel,
    this.firstDayOfWeek = DateTime.monday,
  }) : assert(weekdayLabels.length == 7),
       assert(firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday);

  /// Any day of the month to show.
  final DateTime month;

  /// Today; earlier days cannot be picked.
  final DateTime today;

  /// The first day of the range, if picked.
  final DateTime? start;

  /// The last day of the range, if picked.
  final DateTime? end;

  /// The last day that can be picked; later days are off like past ones. Null for no limit.
  final DateTime? lastDay;

  /// Seven narrow weekday names, **Monday first** whatever [firstDayOfWeek] is (the calendar rotates them).
  final List<String> weekdayLabels;

  /// Called with the tapped day.
  final ValueChanged<DateTime> onDay;

  /// The full spoken date for screen readers; defaults to the day number.
  final String Function(DateTime day)? dayLabel;

  /// The weekday the rows start on: `DateTime.monday` (most of the world, the default) to `DateTime.sunday`
  /// (the United States, Canada, Japan…). `MaterialLocalizations.firstDayOfWeekIndex` or `intl` can tell you the
  /// locale's.
  final int firstDayOfWeek;

  /// The number of days in [month].
  static int daysIn(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

  static DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final first = DateTime(month.year, month.month);
    final days = daysIn(month);
    final lead = (first.weekday - firstDayOfWeek + 7) % 7;
    final cells = lead + days;
    final rows = (cells / 7).ceil();
    final today0 = _d(today);
    final s = start == null ? null : _d(start!);
    final e = end == null ? null : _d(end!);
    final last = lastDay == null ? null : _d(lastDay!);
    final band = t.colors.accentText.withValues(alpha: t.isDark ? .18 : .14);
    final dayStyle = t.type.body.copyWith(color: t.colors.text, fontFeatures: const [FontFeature.tabularFigures()]);

    Widget cell(int index) {
      final n = index - lead + 1;
      if (n < 1 || n > days) return const SizedBox(height: 40);
      final day = DateTime(month.year, month.month, n);
      final off = day.isBefore(today0) || (last != null && day.isAfter(last));
      final isStart = s != null && day == s;
      final isEnd = e != null && day == e;
      final inRange = s != null && e != null && day.isAfter(s) && day.isBefore(e);
      final isToday = day == today0;

      Widget label;
      if (isStart || isEnd) {
        label = SheenGlass(
          variant: SheenGlassVariant.prominent,
          shape: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: Text(
                '$n',
                style: dayStyle.copyWith(fontWeight: FontWeight.w700, color: t.colors.onAccent),
              ),
            ),
          ),
        );
      } else {
        label = Text(
          '$n',
          style: dayStyle.copyWith(
            color: off ? t.colors.textTertiary.withValues(alpha: .5) : (isToday ? t.colors.accentText : t.colors.text),
            fontWeight: isToday ? FontWeight.w700 : (inRange ? FontWeight.w600 : FontWeight.w400),
          ),
        );
      }
      // The night band runs between the two circles: the start shows its right half, the end its left half.
      final halfBand = s != null && e != null && (isStart || isEnd) && s != e;
      return Semantics(
        button: !off,
        enabled: !off,
        selected: isStart || isEnd || inRange,
        label: dayLabel?.call(day) ?? '$n',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: off
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onDay(day);
                },
          child: SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (inRange) Positioned.fill(child: ColoredBox(color: band)),
                if (halfBand)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: (isStart ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart).resolve(
                        Directionality.of(context),
                      ),
                      widthFactor: .5,
                      child: ColoredBox(color: band),
                    ),
                  ),
                label,
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: SizedBox(
                  height: 20,
                  child: Center(
                    child: Text(
                      weekdayLabels[(firstDayOfWeek - 1 + i) % 7],
                      style: t.type.caption.copyWith(fontWeight: FontWeight.w600, color: t.colors.textTertiary),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: 4),
          Row(children: [for (var c = 0; c < 7; c++) Expanded(child: cell(r * 7 + c))]),
        ],
      ],
    );
  }
}
