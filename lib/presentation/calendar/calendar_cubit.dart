import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/calendar/calendar_state.dart';
import 'package:lawnly/presentation/common/state_type.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required CareService careService,
    required CareCalendar calendar,
    DateTime Function() now = DateTime.now,
    DateTime? initialDay,
  }) : _careService = careService,
       _calendar = calendar,
       _now = now,
       super(_initialState(CarePlanner.dateOnly(now()), initialDay)) {
    _changes = _careService.changes.listen((_) => load(silent: true));
  }

  final CareService _careService;
  final CareCalendar _calendar;
  final DateTime Function() _now;
  late final StreamSubscription<void> _changes;

  static CalendarState _initialState(DateTime today, DateTime? initialDay) {
    final selected = initialDay == null ? today : CarePlanner.dateOnly(initialDay);
    return CalendarState(
      today: today,
      month: DateTime(selected.year, selected.month),
      selected: selected,
    );
  }

  static DateTime gridStart(DateTime month) =>
      DateTime(month.year, month.month, 1 - (DateTime(month.year, month.month).weekday - 1));

  static DateTime gridEnd(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return DateTime(last.year, last.month, last.day + (DateTime.sunday - last.weekday));
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(type: StateType.loading));

    final result = await _careService.load().run();
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(type: StateType.error)),
      (snapshot) => _rebuild(
        state.copyWith(
          today: CarePlanner.dateOnly(_now()),
          profile: snapshot.profile,
          plan: snapshot.plan,
          forecast: snapshot.forecast,
        ),
      ),
    );
  }

  void showMonth(int delta) {
    final month = DateTime(state.month.year, state.month.month + delta);
    final isCurrent = month.year == state.today.year && month.month == state.today.month;
    _rebuild(state.copyWith(month: month, selected: isCurrent ? state.today : month));
  }

  void select(DateTime date) {
    final day = CarePlanner.dateOnly(date);
    if (day.month != state.month.month || day.year != state.month.year) {
      _rebuild(state.copyWith(month: DateTime(day.year, day.month), selected: day));
    } else {
      emit(state.copyWith(selected: day));
    }
  }

  DayForecast? forecastFor(DateTime date) =>
      state.forecast.firstWhereOrNull((d) => CarePlanner.dateOnly(d.date) == date);

  WeatherCheck checkWeather(CareKind kind, DateTime date) => _calendar.check(
    kind: kind,
    date: date,
    forecast: state.forecast,
    today: state.today,
    profile: state.profile!,
  );

  Future<bool> markDone(CareEntry entry) => _careService.complete(entry, state.today);

  Future<bool> pinFertilizing(DateTime? date) => _careService.pinFertilizing(date);

  Future<Future<bool> Function()?> remove(CareEntry entry) async {
    if (entry.task case final task?) {
      final saved = await _careService.deleteTask(task.id);
      return saved ? () => _careService.saveTask(task) : null;
    }
    if (entry.cycle case final cycle?) {
      final saved = await _careService.skipFertilizingCycle(cycle.nominal);
      return saved ? () => _careService.restoreFertilizingCycle(cycle.nominal) : null;
    }
    final saved = await _careService.skipEntry(entry.kind, entry.date);
    return saved ? () => _careService.restoreEntry(entry.kind, entry.date) : null;
  }

  Future<bool> saveTask(PlannedTask task) => _careService.saveTask(task);

  void _rebuild(CalendarState next) {
    if (next.profile == null || next.plan == null) return;

    emit(
      next.copyWith(
        type: StateType.loaded,
        calendar: _calendar.build(
          profile: next.profile!,
          plan: next.plan!,
          forecast: next.forecast,
          today: next.today,
          from: gridStart(next.month),
          to: gridEnd(next.month),
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
