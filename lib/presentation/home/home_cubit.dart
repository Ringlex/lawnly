import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/home/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required CareService careService,
    required CareCalendar calendar,
    required CarePlanner planner,
    NotificationScheduler? notifications,
    DateTime Function() now = DateTime.now,
  }) : _careService = careService,
       _calendar = calendar,
       _planner = planner,
       _notifications = notifications,
       _now = now,
       super(HomeState(today: CarePlanner.dateOnly(now()))) {
    _changes = _careService.changes.listen((_) => load(silent: true));
  }

  final CareService _careService;
  final CareCalendar _calendar;
  final CarePlanner _planner;
  final NotificationScheduler? _notifications;
  final DateTime Function() _now;
  late final StreamSubscription<void> _changes;
  var _completing = false;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(type: StateType.loading));
    }

    final result = await _careService.load().run();
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(type: StateType.error)),
      (snapshot) => _plan(
        state.copyWith(
          today: CarePlanner.dateOnly(_now()),
          profile: snapshot.profile,
          plan: snapshot.plan,
          forecast: snapshot.forecast,
          current: snapshot.current,
          forecastFetchedAt: snapshot.fetchedAt,
        ),
      ),
    );
  }

  Future<bool> markDone(CareEntry entry) async {
    if (_completing) return false;
    _completing = true;
    final saved = await _careService
        .complete(entry, state.today)
        .whenComplete(() => _completing = false);
    if (saved && entry.kind == CareKind.fertilizing) emit(state.copyWith(skipped: {}));
    return saved;
  }

  Set<DateTime>? _skippedBeforePostpone;

  void undoPostpone() {
    final previous = _skippedBeforePostpone;
    if (previous == null) return;
    _skippedBeforePostpone = null;
    _plan(state.copyWith(skipped: previous));
  }

  void postpone() {
    if (state.fertilizing case FertilizeOn(:final day)) {
      _skippedBeforePostpone = state.skipped;
      _plan(state.copyWith(skipped: {...state.skipped, CarePlanner.dateOnly(day.date)}));
    }
  }

  static const _lookAheadDays = 60;

  static const _overdueDays = 30;

  void _plan(HomeState next) {
    final today = next.today;
    final calendar = _calendar.build(
      profile: next.profile!,
      plan: next.plan!,
      forecast: next.forecast,
      today: today,
      from: today.subtract(const Duration(days: _overdueDays)),
      to: DateTime(today.year, today.month, today.day + _lookAheadDays),
      skippedDays: next.skipped,
    );

    final upcoming = [
      for (final entry in calendar.entries)
        if (entry.certainty != EntryCertainty.done &&
            entry.kind != CareKind.watering &&
            (!entry.date.isBefore(today) || entry.task != null))
          entry,
    ];
    DateTime dayOf(CareEntry entry) => entry.date.isBefore(today) ? today : entry.date;
    final focusDate = upcoming.map(dayOf).minOrNull;

    emit(
      next.copyWith(
        type: StateType.loaded,
        fertilizing: _calendar.currentFertilizing(
          profile: next.profile!,
          plan: next.plan!,
          forecast: next.forecast,
          today: today,
          skipped: next.skipped,
        ),
        watering: _planner.watering(next.forecast),
        calendar: calendar,
        inSeason: next.profile!.season.contains(today),
        seasonStartsOn: focusDate == null ? next.profile!.season.startAfter(today) : null,
        focusDate: focusDate,
        focusEntries: [
          for (final entry in upcoming)
            if (dayOf(entry) == focusDate) entry,
        ],
      ),
    );
    unawaited(
      _notifications?.reschedule(
        calendar: calendar,
        forecast: next.forecast,
        seasonStartsOn: focusDate == null ? next.profile!.season.startAfter(today) : null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
