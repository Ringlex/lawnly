import 'package:flutter/material.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.calendar,
    required this.onSelect,
    super.key,
  });

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final CalendarPlan calendar;
  final ValueChanged<DateTime> onSelect;

  static const _maxDots = 3;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final start = CalendarCubit.gridStart(month);
    final end = CalendarCubit.gridEnd(month);
    final days = [
      for (var day = start; !day.isAfter(end); day = DateTime(day.year, day.month, day.day + 1))
        day,
    ];

    return Column(
      spacing: 6,
      children: [
        Row(
          children: [
            for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
              Expanded(
                child: Text(
                  context.weekdayShort(weekday),
                  textAlign: TextAlign.center,
                  style: AppTheme.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: palette.mutedTextColor),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            mainAxisExtent: 48,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return _DayCell(
              day: day,
              inMonth: day.month == month.month,
              isToday: day == today,
              isPast: day.isBefore(today),
              isSelected: day == selected,
              inWindow: calendar.inWindow(day),
              entries: calendar.on(day).take(_maxDots).toList(),
              onTap: () => onSelect(day),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isPast,
    required this.isSelected,
    required this.inWindow,
    required this.entries,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isPast;
  final bool isSelected;
  final bool inWindow;
  final List<CareEntry> entries;
  final VoidCallback onTap;

  static const _dotStaggerMs = 30;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(12);

    final background = isToday
        ? palette.heroColor
        : inMonth && inWindow
        ? palette.windowColor
        : Colors.transparent;
    final numberColor = isToday
        ? Colors.white
        : inMonth && !isPast
        ? palette.headingColor
        : palette.mutedTextColor.withValues(alpha: 0.75);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: isSelected && !isToday
              ? BorderSide(color: palette.primaryColor, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                '${day.day}',
                style: AppTheme.body(
                  fontSize: 15,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ).copyWith(color: numberColor, height: 1),
              ),
              SizedBox(
                height: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 3,
                  children: [
                    for (final (index, entry) in entries.indexed)
                      PopIn(
                        key: ValueKey('${day.toIso8601String()}-$index'),
                        delay: Duration(milliseconds: _dotStaggerMs * index),
                        child: EntryDot(
                          color: _dotColor(palette, entry),
                          hollow: entry.certainty == EntryCertainty.tentative,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _dotColor(Palette palette, CareEntry entry) {
    if (entry.certainty == EntryCertainty.done) return palette.outlineColor;
    if (!isToday) return entry.kind.colorIn(palette);
    return entry.kind == CareKind.fertilizing ? palette.springColor : Colors.white;
  }
}

class EntryDot extends StatelessWidget {
  const EntryDot({required this.color, this.hollow = false, super.key});

  final Color color;
  final bool hollow;

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: hollow ? null : color,
      border: hollow ? Border.all(color: color, width: 1.5) : null,
    ),
  );
}
