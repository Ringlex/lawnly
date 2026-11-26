import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/presentation/common/state_type.dart';

part 'calendar_state.freezed.dart';

@freezed
abstract class CalendarState with _$CalendarState {
  const factory CalendarState({
    required DateTime today,
    required DateTime month,
    required DateTime selected,
    @Default(StateType.loading) StateType type,
    LawnProfile? profile,
    CarePlan? plan,
    @Default([]) List<DayForecast> forecast,
    CalendarPlan? calendar,
  }) = _CalendarState;
}
