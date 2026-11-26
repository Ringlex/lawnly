import 'dart:math';

import 'package:collection/collection.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/weather/day_forecast.dart';

class FertilizingWindow {
  const FertilizingWindow(this.interval);

  final int interval;

  int get slack => max(2, (interval * 0.2).round());

  int get start => interval - slack;

  int get end => interval + slack;
}

enum DayConditions { ideal, acceptable, poor }

sealed class FertilizingAdvice {
  const FertilizingAdvice({required this.cycleDay, required this.interval});

  final int cycleDay;
  final int interval;
}

final class FertilizeOn extends FertilizingAdvice {
  const FertilizeOn({
    required this.day,
    required this.conditions,
    required super.cycleDay,
    required super.interval,
    this.pinned = false,
  });

  final DayForecast day;
  final DayConditions conditions;

  final bool pinned;
}

final class FertilizeLater extends FertilizingAdvice {
  const FertilizeLater({
    required this.windowOpensOn,
    required this.daysLeft,
    required super.cycleDay,
    required super.interval,
    this.pinned = false,
  });

  final DateTime windowOpensOn;
  final int daysLeft;
  final bool pinned;
}

final class WaitForWeather extends FertilizingAdvice {
  const WaitForWeather({required super.cycleDay, required super.interval});
}

enum WateringReason { rainExpected, cool, dry }

class WateringAdvice {
  const WateringAdvice({required this.needed, required this.reason, required this.rainMm});

  final bool needed;
  final WateringReason reason;

  final double rainMm;
}

class CarePlanner {
  const CarePlanner();

  static const wateringHorizon = 3;

  static const minRainChance = 60;

  FertilizingAdvice fertilizing({
    required LawnProfile profile,
    required List<DayForecast> forecast,
    required DateTime today,
    Set<DateTime> skipped = const {},
  }) {
    final window = FertilizingWindow(profile.fertilizingIntervalDays);
    final todayDate = dateOnly(today);
    final last = profile.lastFertilizedOn;
    final cycleToday = last == null ? window.interval : daysBetween(dateOnly(last), todayDate);

    final candidates = <FertilizeOn>[];
    for (final day in forecast) {
      final date = dateOnly(day.date);
      final offset = daysBetween(todayDate, date);
      final cycleDay = cycleToday + offset;
      if (offset < 0 || cycleDay < window.start) continue;
      if (skipped.contains(date) || !profile.gardenWeekdays.contains(date.weekday)) continue;

      final conditions = rate(day);
      if (conditions == DayConditions.poor) continue;

      candidates.add(
        FertilizeOn(
          day: day,
          conditions: conditions,
          cycleDay: cycleToday,
          interval: window.interval,
        ),
      );
    }

    final ideal = candidates.firstWhereOrNull((c) => c.conditions == DayConditions.ideal);
    if (ideal != null) return ideal;

    if (candidates.isNotEmpty) {
      int distance(FertilizeOn c) =>
          (cycleToday + daysBetween(todayDate, dateOnly(c.day.date)) - window.interval).abs();
      return candidates.reduce((a, b) => distance(b) < distance(a) ? b : a);
    }

    if (cycleToday < window.start) {
      final daysLeft = window.start - cycleToday;
      return FertilizeLater(
        windowOpensOn: DateTime(todayDate.year, todayDate.month, todayDate.day + daysLeft),
        daysLeft: daysLeft,
        cycleDay: cycleToday,
        interval: window.interval,
      );
    }

    return WaitForWeather(cycleDay: cycleToday, interval: window.interval);
  }

  WateringAdvice watering(List<DayForecast> forecast) {
    final upcoming = forecast.take(wateringHorizon).toList();
    final rain = upcoming.map((d) => d.rainMm).sum;

    if (rain >= 5) {
      return WateringAdvice(needed: false, reason: WateringReason.rainExpected, rainMm: rain);
    }
    final warmest = upcoming.map((d) => d.maxTempC).maxOrNull ?? 0;
    if (warmest < 15) {
      return WateringAdvice(needed: false, reason: WateringReason.cool, rainMm: rain);
    }
    return WateringAdvice(needed: true, reason: WateringReason.dry, rainMm: rain);
  }

  static DayConditions rate(DayForecast day) {
    if (day.maxTempC > 27 || day.maxTempC < 6 || day.rainMm > 15 || day.maxWindKmh > 35) {
      return DayConditions.poor;
    }
    final likelyRain = (day.rainChance ?? 100) >= minRainChance;
    if (day.rainMm >= 2 &&
        likelyRain &&
        day.maxTempC >= 8 &&
        day.maxTempC <= 25 &&
        day.maxWindKmh <= 25) {
      return DayConditions.ideal;
    }
    return DayConditions.acceptable;
  }

  static const _wetGrassHours = 2;

  static Set<DateTime> mowingHours(List<HourForecast> hours) {
    bool wet(HourForecast hour) => hour.rainMm >= 0.2;

    return {
      for (var i = 0; i < hours.length; i++)
        if (_goodForMowing(hours[i]) &&
            i >= _wetGrassHours &&
            hours.sublist(i - _wetGrassHours, i).every((before) => before.isDay && !wet(before)))
          hours[i].time,
    };
  }

  static bool _goodForMowing(HourForecast hour) =>
      hour.isDay &&
      hour.rainMm < 0.2 &&
      (hour.rainChance ?? 0) < 50 &&
      hour.temperatureC >= 5 &&
      hour.temperatureC <= 28;

  static DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  static int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
