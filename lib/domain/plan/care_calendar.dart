import 'package:collection/collection.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/growing_season.dart';

enum EntryCertainty { done, matched, fixed, tentative }

class DateSpan {
  const DateSpan(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);
}

class FertilizingCycle {
  const FertilizingCycle({required this.nominal, required this.window, required this.isCurrent});

  final DateTime nominal;
  final DateSpan window;

  final bool isCurrent;
}

class CareEntry {
  const CareEntry({
    required this.kind,
    required this.date,
    required this.certainty,
    this.task,
    this.cycle,
    this.advice,
    this.movedFrom,
  });

  final CareKind kind;
  final DateTime date;
  final EntryCertainty certainty;

  final PlannedTask? task;
  final FertilizingCycle? cycle;

  final FertilizingAdvice? advice;

  final DateTime? movedFrom;
}

class CalendarPlan {
  const CalendarPlan({required this.entries, required this.windows});

  final List<CareEntry> entries;
  final List<DateSpan> windows;

  List<CareEntry> on(DateTime date) =>
      entries.where((entry) => entry.date == CarePlanner.dateOnly(date)).toList();

  bool inWindow(DateTime date) => windows.any((window) => window.contains(date));
}

sealed class WeatherCheck {
  const WeatherCheck();
}

final class NoForecast extends WeatherCheck {
  const NoForecast();
}

final class GoodWeather extends WeatherCheck {
  const GoodWeather(this.day);

  final DayForecast day;
}

final class BadWeather extends WeatherCheck {
  const BadWeather(this.day, {this.suggestion});

  final DayForecast day;

  final DayForecast? suggestion;
}

class CareCalendar {
  const CareCalendar({
    CarePlanner planner = const CarePlanner(),
    this.season = const GrowingSeason(),
  }) : _planner = planner;

  final CarePlanner _planner;

  final GrowingSeason season;

  CareCalendar _forProfile(LawnProfile profile) =>
      profile.season == season ? this : CareCalendar(planner: _planner, season: profile.season);

  static const suggestionRangeDays = 3;

  FertilizingAdvice currentFertilizing({
    required LawnProfile profile,
    required CarePlan plan,
    required List<DayForecast> forecast,
    required DateTime today,
    Set<DateTime> skipped = const {},
  }) {
    final calendar = _forProfile(profile);
    if (!identical(calendar, this)) {
      return calendar.currentFertilizing(
        profile: profile,
        plan: plan,
        forecast: forecast,
        today: today,
        skipped: skipped,
      );
    }
    final todayDate = CarePlanner.dateOnly(today);
    final last = _effectiveLastFertilized(profile, plan, todayDate);
    final interval = profile.fertilizingIntervalDays;

    final pinned = plan.pinnedFertilizingOn;
    if (pinned != null && !pinned.isBefore(todayDate)) {
      final cycleDay = CarePlanner.daysBetween(last, todayDate);
      final day = forecast.firstWhereOrNull((d) => CarePlanner.dateOnly(d.date) == pinned);
      if (day != null) {
        return FertilizeOn(
          day: day,
          conditions: CarePlanner.rate(day),
          cycleDay: cycleDay,
          interval: interval,
          pinned: true,
        );
      }
      return FertilizeLater(
        windowOpensOn: pinned,
        daysLeft: CarePlanner.daysBetween(todayDate, pinned),
        cycleDay: cycleDay,
        interval: interval,
        pinned: true,
      );
    }

    return _planner.fertilizing(
      profile: profile.copyWith(lastFertilizedOn: last),
      forecast: forecast.where((d) => season.contains(d.date)).toList(),
      today: todayDate,
      skipped: skipped,
    );
  }

  CalendarPlan build({
    required LawnProfile profile,
    required CarePlan plan,
    required List<DayForecast> forecast,
    required DateTime today,
    required DateTime from,
    required DateTime to,
    Set<DateTime> skippedDays = const {},
  }) {
    final calendar = _forProfile(profile);
    if (!identical(calendar, this)) {
      return calendar.build(
        profile: profile,
        plan: plan,
        forecast: forecast,
        today: today,
        from: from,
        to: to,
        skippedDays: skippedDays,
      );
    }
    final todayDate = CarePlanner.dateOnly(today);
    final entries = <CareEntry>[];
    final windows = <DateSpan>[];
    final forecastEnd = forecast.isEmpty
        ? todayDate.subtract(const Duration(days: 1))
        : CarePlanner.dateOnly(forecast.last.date);

    final taskEntries = <CareEntry>[];
    _addTasks(profile, plan, forecast, todayDate, taskEntries);

    if (plan.activeProgramId == null) {
      _addFertilizing(
        profile,
        plan,
        forecast,
        todayDate,
        forecastEnd,
        to,
        skippedDays,
        _ownDates(taskEntries, CareKind.fertilizing),
        entries,
        windows,
      );
    }
    _addMowing(
      profile,
      plan,
      forecast,
      todayDate,
      to,
      _ownDates(taskEntries, CareKind.mowing),
      entries,
    );
    _addWatering(plan, forecast, todayDate, entries);
    entries.addAll(taskEntries);

    final doneTasks = {
      for (final entry in entries)
        if (entry.task != null && entry.certainty == EntryCertainty.done) (entry.kind, entry.date),
    };
    entries.removeWhere(
      (entry) =>
          entry.task == null &&
          entry.certainty == EntryCertainty.done &&
          doneTasks.contains((entry.kind, entry.date)),
    );

    final span = DateSpan(CarePlanner.dateOnly(from), CarePlanner.dateOnly(to));
    entries
      ..retainWhere((entry) => span.contains(entry.date))
      ..sortBy<num>((entry) => entry.kind.index);
    return CalendarPlan(entries: entries, windows: windows);
  }

  WeatherCheck check({
    required CareKind kind,
    required DateTime date,
    required List<DayForecast> forecast,
    required DateTime today,
    required LawnProfile profile,
  }) {
    final target = CarePlanner.dateOnly(date);
    final day = forecast.firstWhereOrNull((d) => CarePlanner.dateOnly(d.date) == target);
    if (day == null) return const NoForecast();
    if (!isBadFor(kind, day)) return GoodWeather(day);

    final suggestion = _bestNearby(
      kind: kind,
      target: target,
      forecast: forecast,
      today: CarePlanner.dateOnly(today),
      profile: profile,
      maxDistance: suggestionRangeDays,
    );
    return BadWeather(day, suggestion: suggestion);
  }

  static bool isBadFor(CareKind kind, DayForecast day) => switch (kind) {
    CareKind.fertilizing => CarePlanner.rate(day) == DayConditions.poor,
    CareKind.mowing => _rainyMorning(day),
    CareKind.watering || CareKind.aeration || CareKind.scarification => day.rainMm >= 2,
    CareKind.overseeding => day.rainMm > 10 || day.maxTempC > 27,
    CareKind.liming => day.rainMm > 10 || day.maxWindKmh > 25,
    CareKind.other => false,
  };

  static bool _rainyMorning(DayForecast day) =>
      day.rainMm >= 2 && (day.rainFromHour == null || day.rainFromHour! < 12);

  DateTime _effectiveLastFertilized(LawnProfile profile, CarePlan plan, DateTime today) {
    final interval = profile.fertilizingIntervalDays;
    var last = profile.lastFertilizedOn == null
        ? _addDays(today, -interval)
        : CarePlanner.dateOnly(profile.lastFertilizedOn!);
    final skipped = plan.skippedFertilizingOn.map(CarePlanner.dateOnly).toSet();
    while (skipped.contains(_addDays(last, interval))) {
      last = _addDays(last, interval);
    }
    return last;
  }

  void _addFertilizing(
    LawnProfile profile,
    CarePlan plan,
    List<DayForecast> forecast,
    DateTime today,
    DateTime forecastEnd,
    DateTime to,
    Set<DateTime> skippedDays,
    List<DateTime> ownDates,
    List<CareEntry> entries,
    List<DateSpan> windows,
  ) {
    final interval = profile.fertilizingIntervalDays;
    final slack = FertilizingWindow(interval).slack;
    DateSpan windowOf(DateTime nominal) => DateSpan(
      _addDays(nominal, -slack),
      _earliest(_addDays(nominal, slack), season.endOf(nominal.year)),
    );

    DateTime seasonal(DateTime nominal) {
      final windowStart = _addDays(nominal, -slack);
      return season.contains(windowStart)
          ? nominal
          : _addDays(season.startAfter(windowStart), slack);
    }

    DateTime tentativeDay(DateTime nominal, DateSpan window, {required DateTime notBefore}) =>
        _nearestGardenDay(profile, _earliest(nominal, window.end), window, notBefore: notBefore);

    if (profile.lastFertilizedOn case final last?) {
      entries.add(
        CareEntry(
          kind: CareKind.fertilizing,
          date: CarePlanner.dateOnly(last),
          certainty: EntryCertainty.done,
        ),
      );
    }

    DateTime? ownIn(DateTime after, DateSpan window) =>
        ownDates.firstWhereOrNull((d) => d.isAfter(after) && !d.isAfter(window.end));

    final last = _effectiveLastFertilized(profile, plan, today);
    final fromInterval = _addDays(last, interval);
    var nominal = seasonal(fromInterval);
    final afterForecast = _addDays(forecastEnd, 1);

    FertilizingAdvice? advice;
    if (nominal == fromInterval && season.contains(today)) {
      final candidate = currentFertilizing(
        profile: profile,
        plan: plan,
        forecast: forecast,
        today: today,
        skipped: skippedDays,
      );
      final usable = switch (candidate) {
        FertilizeOn() || FertilizeLater(pinned: true) => true,
        _ => !afterForecast.isAfter(windowOf(nominal).end),
      };
      if (usable) {
        advice = candidate;
      } else {
        nominal = _addDays(season.startAfter(today), slack);
      }
    }
    final cycle = FertilizingCycle(nominal: nominal, window: windowOf(nominal), isCurrent: true);
    windows.add(cycle.window);

    final DateTime date;
    if (ownIn(last, cycle.window) case final own?) {
      date = own;
    } else {
      final (planned, certainty) = switch (advice) {
        FertilizeOn(:final day, :final pinned) => (
          CarePlanner.dateOnly(day.date),
          pinned ? EntryCertainty.fixed : EntryCertainty.matched,
        ),
        FertilizeLater(:final windowOpensOn, pinned: true) => (windowOpensOn, EntryCertainty.fixed),
        null => (
          tentativeDay(nominal, cycle.window, notBefore: cycle.window.start),
          EntryCertainty.tentative,
        ),
        _ => (
          tentativeDay(_latest(nominal, afterForecast), cycle.window, notBefore: afterForecast),
          EntryCertainty.tentative,
        ),
      };
      entries.add(
        CareEntry(
          kind: CareKind.fertilizing,
          date: planned,
          certainty: certainty,
          cycle: cycle,
          advice: advice,
        ),
      );
      date = planned;
    }

    final skipped = plan.skippedFertilizingOn.map(CarePlanner.dateOnly).toSet();
    var anchor = date;
    while (true) {
      final next = seasonal(_addDays(anchor, interval));
      final window = windowOf(next);
      if (window.start.isAfter(to)) break;
      if (ownIn(anchor, window) case final own?) {
        windows.add(window);
        anchor = own;
        continue;
      }
      anchor = next;
      if (skipped.contains(next)) continue;

      windows.add(window);
      final nextCycle = FertilizingCycle(nominal: next, window: window, isCurrent: false);
      anchor = tentativeDay(next, window, notBefore: window.start);
      entries.add(
        CareEntry(
          kind: CareKind.fertilizing,
          date: anchor,
          certainty: EntryCertainty.tentative,
          cycle: nextCycle,
        ),
      );
    }
  }

  void _addMowing(
    LawnProfile profile,
    CarePlan plan,
    List<DayForecast> forecast,
    DateTime today,
    DateTime to,
    List<DateTime> ownDates,
    List<CareEntry> entries,
  ) {
    final interval = profile.mowingIntervalDays;
    if (profile.lastMowedOn case final last?) {
      entries.add(
        CareEntry(
          kind: CareKind.mowing,
          date: CarePlanner.dateOnly(last),
          certainty: EntryCertainty.done,
        ),
      );
    }

    final last = profile.lastMowedOn == null
        ? _addDays(today, -interval)
        : CarePlanner.dateOnly(profile.lastMowedOn!);
    var anchor = last;
    while (true) {
      var due = _latest(_addDays(anchor, interval), today);
      if (!season.contains(due)) due = season.startAfter(due);
      if (due.isAfter(to)) break;
      final day = _mowingDay(profile, forecast, due);
      if (!season.contains(day)) {
        anchor = day;
        continue;
      }

      final own = ownDates.firstWhereOrNull(
        (d) => d.isAfter(anchor) && !d.isAfter(_addDays(day, interval ~/ 2)),
      );
      if (own != null) {
        anchor = own;
        continue;
      }

      anchor = day;
      if (plan.skipped.contains(SkippedEntry(kind: CareKind.mowing, date: day))) continue;

      final inForecast = _forecastFor(forecast, day) != null;
      entries.add(
        CareEntry(
          kind: CareKind.mowing,
          date: day,
          certainty: inForecast ? EntryCertainty.matched : EntryCertainty.tentative,
        ),
      );
    }
  }

  DateTime _mowingDay(LawnProfile profile, List<DayForecast> forecast, DateTime due) {
    for (var offset = 0; offset < 7; offset++) {
      final day = _addDays(due, offset);
      if (!profile.gardenWeekdays.contains(day.weekday)) continue;
      final weather = _forecastFor(forecast, day);
      if (weather == null || !_rainyMorning(weather)) return day;
    }
    return due;
  }

  void _addWatering(
    CarePlan plan,
    List<DayForecast> forecast,
    DateTime today,
    List<CareEntry> entries,
  ) {
    if (!season.contains(today) || forecast.isEmpty || !_planner.watering(forecast).needed) {
      return;
    }
    if (plan.skipped.contains(SkippedEntry(kind: CareKind.watering, date: today))) return;
    entries.add(CareEntry(kind: CareKind.watering, date: today, certainty: EntryCertainty.matched));
  }

  void _addTasks(
    LawnProfile profile,
    CarePlan plan,
    List<DayForecast> forecast,
    DateTime today,
    List<CareEntry> entries,
  ) {
    for (final task in plan.tasks) {
      if (task.doneOn case final doneOn?) {
        entries.add(
          CareEntry(
            kind: task.kind,
            date: CarePlanner.dateOnly(doneOn),
            certainty: EntryCertainty.done,
            task: task,
          ),
        );
        continue;
      }

      final date = CarePlanner.dateOnly(task.date);
      final weather = _forecastFor(forecast, date);
      final moved = task.flexible && weather != null && isBadFor(task.kind, weather)
          ? _bestNearby(
              kind: task.kind,
              target: date,
              forecast: forecast,
              today: today,
              profile: profile,
              maxDistance: PlannedTask.maxShiftDays,
            )?.date
          : null;
      final finalDate = moved == null ? date : CarePlanner.dateOnly(moved);

      entries.add(
        CareEntry(
          kind: task.kind,
          date: finalDate,
          certainty: _forecastFor(forecast, finalDate) != null
              ? EntryCertainty.matched
              : task.flexible
              ? EntryCertainty.tentative
              : EntryCertainty.fixed,
          task: task,
          movedFrom: moved == null ? null : date,
        ),
      );
    }
  }

  DayForecast? _bestNearby({
    required CareKind kind,
    required DateTime target,
    required List<DayForecast> forecast,
    required DateTime today,
    required LawnProfile profile,
    required int maxDistance,
  }) {
    int distance(DayForecast d) => CarePlanner.daysBetween(target, d.date).abs();
    int score(DayForecast d) =>
        distance(d) + (profile.gardenWeekdays.contains(d.date.weekday) ? 0 : 2);

    return forecast
        .where(
          (d) =>
              distance(d) > 0 &&
              distance(d) <= maxDistance &&
              !d.date.isBefore(today) &&
              !isBadFor(kind, d),
        )
        .sortedBy<num>(score)
        .firstOrNull;
  }

  DateTime _nearestGardenDay(
    LawnProfile profile,
    DateTime target,
    DateSpan window, {
    required DateTime notBefore,
  }) {
    if (!window.contains(target)) return target;
    final days = [
      for (var day = window.start; !day.isAfter(window.end); day = _addDays(day, 1))
        if (profile.gardenWeekdays.contains(day.weekday) && !day.isBefore(notBefore)) day,
    ];
    return days.sortedBy<num>((d) => CarePlanner.daysBetween(target, d).abs()).firstOrNull ??
        target;
  }

  static List<DateTime> _ownDates(List<CareEntry> taskEntries, CareKind kind) => [
    for (final entry in taskEntries)
      if (entry.kind == kind && entry.certainty != EntryCertainty.done) entry.date,
  ]..sort();

  static DayForecast? _forecastFor(List<DayForecast> forecast, DateTime date) =>
      forecast.firstWhereOrNull((d) => CarePlanner.dateOnly(d.date) == date);

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static DateTime _latest(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  static DateTime _earliest(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
