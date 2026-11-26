import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/calendar_state.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/add_task_sheet.dart';
import 'package:lawnly/presentation/calendar/widgets/day_panel.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';
import 'package:lawnly/presentation/weather/weather_cubit.dart';

class DayPage extends StatelessWidget {
  const DayPage({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => WeatherCubit(careService: getIt())..load()),
      BlocProvider(
        create: (_) =>
            CalendarCubit(careService: getIt(), calendar: getIt(), initialDay: date)..load(),
      ),
    ],
    child: _DayView(date: CarePlanner.dateOnly(date)),
  );
}

class _DayView extends StatelessWidget {
  const _DayView({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final today = CarePlanner.dateOnly(DateTime.now());
    final title = date == today
        ? strings.calendarToday(context.longDate(date).replaceFirst(',', ''))
        : capitalized(context.longDate(date));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!date.isBefore(today))
            IconButton(
              onPressed: () => showAddTaskSheet(
                context,
                cubit: context.read<CalendarCubit>(),
                initialDate: date,
              ),
              tooltip: strings.calendarAdd,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          _Weather(date: date, isToday: date == today),
          Gap.xLarge,
          Text(strings.dayPlanned, style: context.textTheme.titleLarge),
          Gap.medium,
          _Entries(date: date),
        ],
      ),
    );
  }
}

class _Weather extends StatelessWidget {
  const _Weather({required this.date, required this.isToday});

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) => state.type.map(
        loading: () => const Padding(
          padding: EdgeInsets.all(Insets.xxLarge),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: () => Column(
          spacing: Insets.medium,
          children: [
            Text(strings.homeLoadError, textAlign: TextAlign.center),
            OutlinedButton(
              onPressed: context.read<WeatherCubit>().load,
              child: Text(strings.commonRetry),
            ),
          ],
        ),
        loaded: () {
          final report = state.report!;
          final day = report.days.firstWhereOrNull((day) => CarePlanner.dateOnly(day.date) == date);
          final now = DateTime.now();
          final dayHours = report.hoursOn(date);
          final hours = [
            for (final hour in dayHours)
              if (!isToday || hour.time.add(const Duration(hours: 1)).isAfter(now)) hour,
          ];

          if (day == null && hours.isEmpty) {
            return Text(strings.dayNoForecast, style: context.textTheme.bodyMedium);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (day != null) ...[_SummaryCard(day: day), Gap.xLarge],
              if (hours.isNotEmpty) ...[
                Text(strings.dayHourly, style: context.textTheme.titleLarge),
                Gap.medium,
                _HourStrip(
                  hours: hours,
                  highlightFirst: isToday,
                  mowingHours: CarePlanner.mowingHours(dayHours),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.day});

  final DayForecast day;

  static const _minRainMm = 0.5;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final textStyle = AppTheme.body(fontSize: 14).copyWith(color: palette.onHeroColor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Row(
        spacing: Insets.large,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.xSmall,
              children: [
                Text(
                  day.minTempC == null
                      ? strings.homeTemperatureShort(day.maxTempC.round())
                      : strings.weatherMinMax(day.maxTempC.round(), day.minTempC!.round()),
                  style: AppTheme.display(fontSize: 40).copyWith(color: Colors.white, height: 1),
                ),
                Gap.xSmall,
                if (day.rainMm >= _minRainMm)
                  Text(
                    day.rainFromHour == null
                        ? strings.homeRainMm(formatMm(day.rainMm))
                        : strings.weatherRainFrom(day.maxTempC.round(), day.rainFromHour!),
                    style: textStyle,
                  ),
                if (day.rainChance case final chance?)
                  Text(strings.weatherRainChance(chance), style: textStyle),
                Text(strings.dayWindMax(day.maxWindKmh.round()), style: textStyle),
              ],
            ),
          ),
          Icon(day.kind.icon, size: 64, color: palette.springColor),
        ],
      ),
    );
  }
}

class _HourStrip extends StatelessWidget {
  const _HourStrip({required this.hours, required this.highlightFirst, required this.mowingHours});

  final List<HourForecast> hours;

  final bool highlightFirst;

  final Set<DateTime> mowingHours;

  static const _tileWidth = 56.0;
  static const _tileHeight = 112.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final mowingColor = CareKind.mowing.colorIn(palette);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Insets.medium,
      children: [
        SizedBox(
          height: _tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            separatorBuilder: (_, _) => HorizontalGap.small,
            itemBuilder: (context, index) => SizedBox(
              width: _tileWidth,
              child: _HourTile(
                hour: hours[index],
                highlighted: highlightFirst && index == 0,
                goodForMowing: mowingHours.contains(hours[index].time),
              ),
            ),
          ),
        ),
        if (hours.any((hour) => mowingHours.contains(hour.time)))
          Row(
            spacing: Insets.small,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: mowingColor, width: _HourTile.mowingBorderWidth),
                ),
              ),
              Expanded(
                child: Text(context.strings.dayMowingLegend, style: context.textTheme.bodySmall),
              ),
            ],
          ),
      ],
    );
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.hour, required this.highlighted, required this.goodForMowing});

  final HourForecast hour;
  final bool highlighted;
  final bool goodForMowing;

  static const mowingBorderWidth = 2.0;

  static const _minRainMm = 0.2;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    final labelColor = highlighted ? Colors.white : palette.headingColor;
    final mutedColor = highlighted ? palette.heroMutedColor : palette.mutedTextColor;
    final iconColor = highlighted ? palette.springColor : hour.colorIn(palette);
    final rainColor = highlighted ? palette.springColor : palette.rainColor;

    return Container(
      decoration: BoxDecoration(
        color: highlighted ? palette.heroColor : palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        border: goodForMowing
            ? Border.all(color: CareKind.mowing.colorIn(palette), width: mowingBorderWidth)
            : highlighted
            ? null
            : Border.all(color: palette.outlineColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          Text(
            highlighted ? strings.weatherNow : DateFormat('HH:mm').format(hour.time),
            style: AppTheme.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ).copyWith(color: highlighted ? labelColor : mutedColor),
          ),
          Icon(hour.icon, size: 22, color: iconColor),
          Text(
            strings.homeTemperatureShort(hour.temperatureC.round()),
            style: AppTheme.body(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ).copyWith(color: labelColor, height: 1),
          ),
          SizedBox(
            height: 14,
            child: hour.rainMm >= _minRainMm
                ? Text(
                    strings.homeRainMm(formatMm(hour.rainMm)),
                    maxLines: 1,
                    style: AppTheme.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: rainColor),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) => state.type.map(
        loading: () => const Padding(
          padding: EdgeInsets.all(Insets.large),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: () => Center(
          child: OutlinedButton(
            onPressed: context.read<CalendarCubit>().load,
            child: Text(strings.commonRetry),
          ),
        ),
        loaded: () {
          final entries = state.calendar!.on(date);
          if (entries.isEmpty) {
            return Text(strings.calendarEmptyDay, style: context.textTheme.bodyMedium);
          }

          final forecast = context.read<CalendarCubit>().forecastFor(date);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.small,
            children: [
              for (final entry in entries)
                EntryRow(
                  entry: entry,
                  subtitle: entrySubtitle(context, entry, state.profile!, forecast),
                  tag: DayPanel.isIdeal(entry) ? strings.homeBadgeIdeal : null,
                ),
            ],
          );
        },
      ),
    );
  }
}
