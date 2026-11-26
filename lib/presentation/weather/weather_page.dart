import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';
import 'package:lawnly/presentation/weather/weather_cubit.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => WeatherCubit(careService: getIt())..load(),
    child: const _WeatherView(),
  );
}

class _WeatherView extends StatelessWidget {
  const _WeatherView();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final location = state.profile?.location;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.weatherTitle),
                if (location != null)
                  Text(
                    location.label ?? strings.locationCurrent,
                    style: context.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          body: state.type.map(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(Insets.xxLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Insets.large,
                  children: [
                    Text(strings.homeLoadError, textAlign: TextAlign.center),
                    OutlinedButton(
                      onPressed: context.read<WeatherCubit>().load,
                      child: Text(strings.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
            loaded: () => _Forecast(report: state.report!),
          ),
        );
      },
    );
  }
}

class _Forecast extends StatelessWidget {
  const _Forecast({required this.report});

  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final days = report.days;
    final planned = days.take(CareService.planningDays).toList();
    final later = days.skip(CareService.planningDays).toList();
    final today = days.isEmpty ? null : CarePlanner.dateOnly(days.first.date);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
      children: [
        if (report.current case final now?) ...[
          _NowCard(now: now, today: days.firstOrNull),
          Gap.xLarge,
        ],
        Text(strings.weatherDays, style: context.textTheme.titleLarge),
        Gap.medium,
        _DayList(days: planned, today: today),
        if (later.isNotEmpty) ...[
          Gap.large,
          Text(strings.weatherLessCertain, style: context.textTheme.bodySmall),
          Gap.small,
          _DayList(days: later, today: today, uncertain: true),
        ],
        Gap.large,
        Text(
          strings.weatherSource,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.now, required this.today});

  final CurrentWeather now;
  final DayForecast? today;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final textStyle = AppTheme.body(fontSize: 14).copyWith(color: palette.onHeroColor);
    final day = today;

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
                  strings.weatherNow.toUpperCase(),
                  style: AppTheme.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: palette.springColor, letterSpacing: 0.5),
                ),
                Text(
                  strings.homeTemperatureShort(now.temperatureC.round()),
                  style: AppTheme.display(fontSize: 56).copyWith(color: Colors.white, height: 1),
                ),
                Gap.xSmall,
                Text(strings.weatherWind(now.windKmh.round()), style: textStyle),
                if (day != null && day.minTempC != null)
                  Text(
                    strings.weatherTodayRange(day.maxTempC.round(), day.minTempC!.round()),
                    style: textStyle,
                  ),
                if (day?.rainChance case final chance?)
                  Text(strings.weatherRainChance(chance), style: textStyle),
              ],
            ),
          ),
          Icon(now.icon, size: 72, color: palette.springColor),
        ],
      ),
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.days, required this.today, this.uncertain = false});

  final List<DayForecast> days;
  final DateTime? today;
  final bool uncertain;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: palette.outlineColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const Divider(indent: Insets.large, endIndent: Insets.large),
            _DayRow(day: days[i], today: today, muted: uncertain),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.today, required this.muted});

  final DayForecast day;
  final DateTime? today;
  final bool muted;

  static const _minRainMm = 0.5;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final date = CarePlanner.dateOnly(day.date);
    final offset = today == null ? null : CarePlanner.daysBetween(today!, date);
    final label = switch (offset) {
      0 => strings.weatherToday,
      1 => strings.weatherTomorrow,
      _ => context.weekdayShort(date.weekday),
    };
    final textColor = muted ? palette.secondaryTextColor : palette.headingColor;

    return InkWell(
      onTap: () => context.push(Routes.day(date)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: Insets.medium),
        child: Row(
          spacing: Insets.medium,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: textColor),
                  ),
                  Text(context.shortDate(date), style: context.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(day.kind.icon, size: 26, color: day.kind.colorIn(palette)),
            Expanded(
              child: day.rainMm >= _minRainMm
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.homeRainMm(formatMm(day.rainMm)),
                          style: AppTheme.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: palette.rainColor),
                        ),
                        if (day.rainChance case final chance?)
                          Text('$chance%', style: context.textTheme.bodySmall),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              day.minTempC == null
                  ? strings.homeTemperatureShort(day.maxTempC.round())
                  : strings.weatherMinMax(day.maxTempC.round(), day.minTempC!.round()),
              style: AppTheme.body(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ).copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
