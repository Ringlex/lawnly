import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/add_task_sheet.dart';
import 'package:lawnly/presentation/calendar/widgets/entry_sheet.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/watering_hint.dart';

class DayPanel extends StatelessWidget {
  const DayPanel({
    required this.date,
    required this.isToday,
    required this.entries,
    required this.forecast,
    required this.profile,
    super.key,
  });

  final DateTime date;
  final bool isToday;
  final List<CareEntry> entries;
  final DayForecast? forecast;
  final LawnProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final title = isToday
        ? strings.calendarToday(context.longDate(date).replaceFirst(',', ''))
        : capitalized(context.longDate(date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Insets.small,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: Insets.small,
          children: [
            Expanded(child: Text(title, style: context.textTheme.titleLarge)),
            if (forecast case final day?)
              Text(
                day.rainFromHour == null
                    ? context.weatherSummary(day)
                    : strings.weatherRainFrom(
                        day.maxTempC.round(), day.rainFromHour!),
                style: AppTheme.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.rainColor),
              ),
          ],
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.medium),
            child: Text(strings.calendarEmptyDay,
                style: context.textTheme.bodyMedium),
          )
        else
          for (final entry in entries)
            EntryRow(
              entry: entry,
              subtitle: entrySubtitle(context, entry, profile, forecast),
              tag: isIdeal(entry) ? strings.homeBadgeIdeal : null,
            ),
      ],
    );
  }

  static bool isIdeal(CareEntry entry) =>
      entry.certainty == EntryCertainty.matched &&
      entry.advice is FertilizeOn &&
      (entry.advice! as FertilizeOn).conditions == DayConditions.ideal;
}

String entrySubtitle(
  BuildContext context,
  CareEntry entry,
  LawnProfile profile,
  DayForecast? forecast,
) {
  final strings = context.strings;
  if (entry.certainty == EntryCertainty.done) return strings.entryDone;

  if (entry.task case final task?) {
    if (entry.movedFrom case final from?) return strings.entryMoved(context.shortDate(from));
    final note = (task.note ?? '').split('\n').first.trim();
    return note.isEmpty ? strings.entryOwn : note;
  }

  return switch (entry.kind) {
    CareKind.fertilizing => switch (entry) {
        CareEntry(certainty: EntryCertainty.fixed) => strings.entryPinned,
        CareEntry(advice: FertilizeOn(:final cycleDay, :final interval)) =>
          strings.homeCycleDay(
            cycleDay,
            interval,
          ),
        CareEntry(:final cycle?) => strings.entryTentative(
            context.shortDate(cycle.window.start),
            context.shortDate(cycle.window.end),
          ),
        _ => strings.entryOwn,
      },
    CareKind.mowing => (forecast?.rainFromHour ?? 0) >= 12
        ? strings.entryBeforeRain
        : strings.entryEvery(strings.daysCount(profile.mowingIntervalDays)),
    CareKind.watering => wateringHint(context, profile),
    _ => strings.entryOwn,
  };
}

class EntryRow extends StatelessWidget {
  const EntryRow(
      {required this.entry, required this.subtitle, this.tag, super.key});

  final CareEntry entry;
  final String subtitle;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarCubit>();

    return OpenCard<PlannedTask>(
      radius: BorderRadius.circular(AppTheme.buttonRadius),
      color: context.palette.cardColor,
      openBuilder: (_) => BlocProvider.value(
        value: cubit,
        child: EntryPage(entry: entry),
      ),
      onClosed: (task) {
        if (task != null && context.mounted) {
          showAddTaskSheet(context,
              cubit: cubit, task: task, initialDate: task.date);
        }
      },
      closedBuilder: _content,
    );
  }

  Widget _content(BuildContext context, VoidCallback onTap) {
    final palette = context.palette;
    final color = entry.certainty == EntryCertainty.done
        ? palette.mutedTextColor
        : entry.kind.colorIn(palette);
    final radius = BorderRadius.circular(AppTheme.buttonRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: Insets.medium),
          child: Row(
            spacing: Insets.medium,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.kind.icon, size: 20, color: color),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Wrap(
                      spacing: Insets.small,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          entry.kind.label(context),
                          style: AppTheme.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: palette.headingColor),
                        ),
                        if (tag != null) _Tag(tag!),
                      ],
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(fontSize: 13)
                          .copyWith(color: palette.mutedTextColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 20, color: palette.mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: Insets.small, vertical: 3),
      decoration: BoxDecoration(
        color: palette.windowColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTheme.body(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ).copyWith(color: palette.primaryColor),
      ),
    );
  }
}
