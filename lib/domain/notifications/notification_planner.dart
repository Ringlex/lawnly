import 'package:lawnly/core/l10n/generated/app_localizations.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/program_planner.dart';

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final String payload;
}

class NotificationPlanner {
  const NotificationPlanner();

  static const horizonDays = 7;
  static const warningHour = 17;
  static const warningMinute = 45;
  static const frostC = 0.0;
  static const heatC = 30.0;
  static const downpourMm = 20.0;
  static const washoutMm = 10.0;

  static String payloadOf(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<PlannedNotification> plan({
    required NotificationPrefs prefs,
    required CalendarPlan calendar,
    required List<DayForecast> forecast,
    required DateTime now,
    required L10n strings,
  }) {
    if (!prefs.enabled) return const [];

    final today = CarePlanner.dateOnly(now);
    final result = <PlannedNotification>[];

    for (var offset = 0; offset < horizonDays; offset++) {
      final date = DateTime(today.year, today.month, today.day + offset);
      final morning = _morning(prefs, calendar, forecast, date, strings);
      if (morning != null) {
        final at = DateTime(date.year, date.month, date.day, prefs.morningHour);
        if (at.isAfter(now)) {
          result.add(
            PlannedNotification(
              id: offset * 2,
              at: at,
              title: morning.$1,
              body: morning.$2,
              payload: payloadOf(date),
            ),
          );
        }
      }

      if (!prefs.warnings) continue;
      final warning = _warning(forecast, date, strings);
      if (warning == null) continue;
      final eve = date.subtract(const Duration(days: 1));
      final at =
          DateTime(eve.year, eve.month, eve.day, warningHour, warningMinute);
      if (at.isAfter(now)) {
        result.add(
          PlannedNotification(
            id: offset * 2 + 1,
            at: at,
            title: warning.$1,
            body: warning.$2,
            payload: payloadOf(date),
          ),
        );
      }
    }
    return result;
  }

  (String, String)? _morning(
    NotificationPrefs prefs,
    CalendarPlan calendar,
    List<DayForecast> forecast,
    DateTime date,
    L10n strings,
  ) {
    final entries = [
      for (final entry in calendar.on(date))
        if (entry.certainty != EntryCertainty.done &&
            _allowed(prefs, entry.kind))
          entry,
    ];
    if (entries.isEmpty) return null;

    entries.sort((a, b) => _priority(a.kind).compareTo(_priority(b.kind)));
    final entry = entries.first;

    if (entry.task case final task? when ProgramPlanner.isProgramTask(task)) {
      return _programStep(task, forecast, date, strings);
    }

    return switch (entry.kind) {
      CareKind.fertilizing => switch (entry.advice) {
          FertilizeOn(:final conditions, :final cycleDay, :final interval) => (
              conditions == DayConditions.ideal
                  ? strings.notifFertilizeIdealTitle
                  : strings.notifFertilizeTitle,
              strings.notifFertilizeBody(cycleDay, interval),
            ),
          _ => (
              strings.notifFertilizeTitle,
              strings.notifFertilizeFallbackBody
            ),
        },
      CareKind.mowing => (strings.notifMowingTitle, strings.notifMowingBody),
      CareKind.watering => (
          strings.notifWateringTitle,
          strings.notifWateringBody
        ),
      _ => (strings.notifTaskTitle, strings.notifTaskBody),
    };
  }

  (String, String) _programStep(
    PlannedTask task,
    List<DayForecast> forecast,
    DateTime date,
    L10n strings,
  ) {
    final summary = (task.note ?? '').split('\n').first.trim();
    final rain = _rainOn(forecast, date);
    final body = switch ((summary.isEmpty, rain)) {
      (true, final mm?) when mm >= washoutMm =>
        strings.notifProgramRain(mm.round()),
      (true, _) => strings.notifFertilizeFallbackBody,
      (false, final mm?) when mm >= washoutMm =>
        '$summary. ${strings.notifProgramRain(mm.round())}',
      (false, _) => summary,
    };
    return (strings.notifProgramTitle, body);
  }

  static double? _rainOn(List<DayForecast> forecast, DateTime date) {
    for (final day in forecast) {
      if (CarePlanner.dateOnly(day.date) == date) return day.rainMm;
    }
    return null;
  }

  (String, String)? _warning(
      List<DayForecast> forecast, DateTime date, L10n strings) {
    for (final day in forecast) {
      if (CarePlanner.dateOnly(day.date) != date) continue;
      final minTemp = day.minTempC;
      if (minTemp != null && minTemp <= frostC) {
        return (
          strings.noticeFrostTitle,
          strings.noticeFrostBody(strings.noticeTomorrow, minTemp.round()),
        );
      }
      if (day.maxTempC >= heatC) {
        return (
          strings.noticeHeatTitle,
          strings.noticeHeatBody(strings.noticeTomorrow, day.maxTempC.round()),
        );
      }
      if (day.rainMm >= downpourMm) {
        return (
          strings.noticeDownpourTitle,
          strings.noticeDownpourBody(
              strings.noticeTomorrow, day.rainMm.round().toString()),
        );
      }
    }
    return null;
  }

  static bool _allowed(NotificationPrefs prefs, CareKind kind) =>
      switch (kind) {
        CareKind.fertilizing => prefs.fertilizing,
        CareKind.watering => prefs.watering,
        _ => prefs.care,
      };

  static int _priority(CareKind kind) => switch (kind) {
        CareKind.fertilizing => 0,
        CareKind.mowing => 1,
        CareKind.watering => 3,
        _ => 2,
      };
}
