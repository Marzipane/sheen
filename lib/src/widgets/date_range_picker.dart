import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A date-range picker: a month header with previous and next arrows over a [SheenDateRangeCalendar], a sideways swipe
/// to change the month, and the usual range logic ([pick]): the first tap starts a range, a later day ends it, an
/// earlier one starts again.
///
/// Months before [today]'s and after [lastDay]'s cannot be reached. Pass translated [weekdayLabels] (Monday first)
/// and a [monthLabel] that formats a month in the reader's language.
///
/// ```dart
/// SheenDateRangePicker(
///   today: DateTime.now(),
///   start: checkIn,
///   end: checkOut,
///   weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
///   monthLabel: (m) => DateFormat.yMMMM(locale).format(m),
///   onChanged: (s, e) => setState(() => (checkIn, checkOut) = (s, e)),
/// )
/// ```
///
/// {@category Selection}
class SheenDateRangePicker extends StatefulWidget {
  /// A picker showing [start]–[end].
  const SheenDateRangePicker({
    super.key,
    required this.today,
    required this.weekdayLabels,
    required this.monthLabel,
    required this.onChanged,
    this.start,
    this.end,
    this.lastDay,
    this.initialMonth,
    this.firstDayOfWeek = DateTime.monday,
    this.dayLabel,
  });

  /// Today; earlier days and months cannot be picked.
  final DateTime today;

  /// The first day of the range.
  final DateTime? start;

  /// The last day of the range.
  final DateTime? end;

  /// The last day that can be picked; null for no limit.
  final DateTime? lastDay;

  /// The month shown first; the month of [start] (or [today]) when null.
  final DateTime? initialMonth;

  /// Seven narrow weekday names, Monday first.
  final List<String> weekdayLabels;

  /// Formats a month for the header, such as "October 2026".
  final String Function(DateTime month) monthLabel;

  /// Called with the new range after a tap.
  final void Function(DateTime? start, DateTime? end) onChanged;

  /// The weekday the rows start on.
  final int firstDayOfWeek;

  /// The full spoken date for screen readers.
  final String Function(DateTime day)? dayLabel;

  /// The range after tapping [day] with [start]–[end] picked: a first day starts a range, a later one ends it, an
  /// earlier one (or a tap after a full range) starts a new one.
  static (DateTime?, DateTime?) pick(DateTime? start, DateTime? end, DateTime day) {
    if (start == null || end != null || !day.isAfter(start)) return (day, null);
    return (start, day);
  }

  @override
  State<SheenDateRangePicker> createState() => _SheenDateRangePickerState();
}

class _SheenDateRangePickerState extends State<SheenDateRangePicker> {
  late DateTime _month = _first(widget.initialMonth ?? widget.start ?? widget.today);

  static DateTime _first(DateTime d) => DateTime(d.year, d.month);

  bool get _canGoBack => _month.isAfter(_first(widget.today));

  bool get _canGoOn {
    final last = widget.lastDay;
    return last == null || _month.isBefore(_first(last));
  }

  void _go(int by) {
    if (by < 0 ? !_canGoBack : !_canGoOn) return;
    HapticFeedback.selectionClick();
    setState(() => _month = DateTime(_month.year, _month.month + by));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final strings = SheenStrings.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget arrow(String icon, String label, bool enabled, int by) => Opacity(
      opacity: enabled ? 1 : .35,
      child: SheenIconButton(
        icon: icon,
        semanticLabel: label,
        size: 36,
        iconSize: 18,
        onTap: enabled ? () => _go(by) : null,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 150) return;
        // a swipe towards the start of the line shows the next month
        _go((v < 0) != rtl ? 1 : -1);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Row(
              children: [
                arrow(SheenIcons.back, strings.previous, _canGoBack, -1),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    header: true,
                    child: Text(
                      widget.monthLabel(_month),
                      textAlign: TextAlign.center,
                      style: t.type.headline.copyWith(color: t.colors.text),
                    ),
                  ),
                ),
                arrow(SheenIcons.chevron, strings.next, _canGoOn, 1),
              ],
            ),
          ),
          SheenDateRangeCalendar(
            month: _month,
            today: widget.today,
            start: widget.start,
            end: widget.end,
            lastDay: widget.lastDay,
            weekdayLabels: widget.weekdayLabels,
            firstDayOfWeek: widget.firstDayOfWeek,
            dayLabel: widget.dayLabel,
            onDay: (day) {
              final (s, e) = SheenDateRangePicker.pick(widget.start, widget.end, day);
              widget.onChanged(s, e);
            },
          ),
        ],
      ),
    );
  }
}
