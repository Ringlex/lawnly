import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/common/state_type.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required DateTime today,
    @Default(StateType.loading) StateType type,
    LawnProfile? profile,
    CarePlan? plan,
    @Default([]) List<DayForecast> forecast,
    CurrentWeather? current,
    DateTime? forecastFetchedAt,
    FertilizingAdvice? fertilizing,
    WateringAdvice? watering,
    DateTime? focusDate,
    @Default([]) List<CareEntry> focusEntries,
    @Default(true) bool inSeason,
    DateTime? seasonStartsOn,
    CalendarPlan? calendar,
    @Default({}) Set<DateTime> skipped,
  }) = _HomeState;
}
