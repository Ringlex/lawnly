import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/home/home_state.dart';

enum WeatherRisk { frost, heat, downpour }

sealed class HomeNotice {
  const HomeNotice();
}

final class WeatherWarning extends HomeNotice {
  const WeatherWarning({
    required this.risk,
    required this.date,
    required this.isToday,
    required this.value,
  });

  final WeatherRisk risk;
  final DateTime date;
  final bool isToday;
  final double value;
}

final class PlanMoved extends HomeNotice {
  const PlanMoved(this.date);

  final DateTime date;
}

final class StaleForecast extends HomeNotice {
  const StaleForecast(this.age);

  final Duration age;
}

abstract class NoticeThresholds {
  const NoticeThresholds._();

  static const frostC = 0.0;
  static const heatC = 30.0;
  static const downpourMm = 20.0;
  static const staleAfter = Duration(hours: 1);
  static const lookAheadDays = 2;
}

List<HomeNotice> homeNotices(HomeState state, DateTime now) {
  final fetchedAt = state.forecastFetchedAt;
  final age = fetchedAt == null ? Duration.zero : now.difference(fetchedAt);

  return [
    ?_warning(state),
    if (state.fertilizing case FertilizeOn(:final day) when state.skipped.isNotEmpty)
      PlanMoved(CarePlanner.dateOnly(day.date)),
    if (age >= NoticeThresholds.staleAfter) StaleForecast(age),
  ];
}

WeatherWarning? _warning(HomeState state) {
  for (final (index, day) in state.forecast.take(NoticeThresholds.lookAheadDays).indexed) {
    WeatherWarning warning(WeatherRisk risk, double value) =>
        WeatherWarning(risk: risk, date: day.date, isToday: index == 0, value: value);

    final minTemp = day.minTempC;
    if (minTemp != null && minTemp <= NoticeThresholds.frostC) {
      return warning(WeatherRisk.frost, minTemp);
    }
    if (day.maxTempC >= NoticeThresholds.heatC) return warning(WeatherRisk.heat, day.maxTempC);
    if (day.rainMm >= NoticeThresholds.downpourMm) {
      return warning(WeatherRisk.downpour, day.rainMm);
    }
  }
  return null;
}
