import 'package:lawnly/core/l10n/current_l10n.dart';
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/generated/app_localizations.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/notifications/notification_planner.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

abstract class NotificationGateway {
  const NotificationGateway();

  Stream<String> get selections;

  Future<String?> launchPayload();

  Future<bool> requestPermission();

  Future<void> replaceAll(List<PlannedNotification> notifications);
}

class NotificationScheduler {
  NotificationScheduler({
    required NotificationGateway gateway,
    required NotificationPrefsRepository prefs,
    required NotificationStateRepository state,
    NotificationPlanner planner = const NotificationPlanner(),
    DateTime Function() now = DateTime.now,
  }) : _gateway = gateway,
       _prefs = prefs,
       _state = state,
       _planner = planner,
       _now = now;

  final NotificationGateway _gateway;
  final NotificationPrefsRepository _prefs;
  final NotificationStateRepository _state;
  final NotificationPlanner _planner;
  final DateTime Function() _now;

  static const planChangeId = 100;
  static const seasonStartId = 101;
  static const planChangeWithinDays = 3;

  ({CalendarPlan calendar, List<DayForecast> forecast, DateTime? seasonStartsOn})? _lastInput;

  Stream<String> get selections => _gateway.selections;

  Future<String?> launchPayload() => _gateway.launchPayload();

  Future<NotificationPrefs> prefs() => _prefs.load();

  Future<bool> update(NotificationPrefs next) async {
    var saved = next;
    if (next.enabled && !(await _prefs.load()).enabled) {
      final granted = await _gateway.requestPermission();
      if (!granted) saved = next.copyWith(enabled: false);
    }
    await _prefs.save(saved);
    await _apply();
    return saved.enabled == next.enabled;
  }

  Future<void> reschedule({
    required CalendarPlan calendar,
    required List<DayForecast> forecast,
    DateTime? seasonStartsOn,
  }) {
    _lastInput = (calendar: calendar, forecast: forecast, seasonStartsOn: seasonStartsOn);
    return _apply();
  }

  Future<void> forgetPlan() async {
    _lastInput = null;
    await _state.save(const NotificationState());
  }

  Future<void> _apply() async {
    final prefs = await _prefs.load();
    final input = _lastInput;
    if (!prefs.enabled) return _gateway.replaceAll(const []);
    if (input == null) return;

    final strings = currentL10n();
    final now = _now();
    final planned = _planner.plan(
      prefs: prefs,
      calendar: input.calendar,
      forecast: input.forecast,
      now: now,
      strings: strings,
    );
    final planChange = await _planChange(prefs, input.calendar, now, strings);
    final seasonStart = _seasonStart(prefs, input.seasonStartsOn, now, strings);
    await _gateway.replaceAll([...planned, ?planChange, ?seasonStart]);
  }

  Future<PlannedNotification?> _planChange(
    NotificationPrefs prefs,
    CalendarPlan calendar,
    DateTime now,
    L10n strings,
  ) async {
    final today = CarePlanner.dateOnly(now);
    final state = await _state.load();
    final next = _nextFertilizing(calendar, today);
    var pendingTo = state.pendingMoveTo;
    var pendingAt = state.pendingMoveAt;

    final baseline = state.baselineFertilizingOn;
    final soon = next != null && next.difference(today).inDays <= planChangeWithinDays;
    if (prefs.fertilizing && baseline != null && next != null && next != baseline && soon) {
      pendingTo = next;
      pendingAt = _deliveryTime(now, prefs.morningHour);
    }
    if (pendingAt != null && !pendingAt.isAfter(now)) {
      pendingTo = null;
      pendingAt = null;
    }

    await _state.save(
      NotificationState(
        baselineFertilizingOn: next ?? baseline,
        pendingMoveTo: pendingTo,
        pendingMoveAt: pendingAt,
      ),
    );

    if (!prefs.fertilizing || pendingTo == null || pendingAt == null) return null;
    return PlannedNotification(
      id: planChangeId,
      at: pendingAt,
      title: strings.notifPlanChangedTitle,
      body: strings.notifPlanChangedBody(DateFormat('d MMMM').format(pendingTo)),
      payload: NotificationPlanner.payloadOf(pendingTo),
    );
  }

  static PlannedNotification? _seasonStart(
    NotificationPrefs prefs,
    DateTime? startsOn,
    DateTime now,
    L10n strings,
  ) {
    if (startsOn == null || !prefs.care) return null;
    final at = DateTime(startsOn.year, startsOn.month, startsOn.day, prefs.morningHour);
    if (!at.isAfter(now)) return null;
    return PlannedNotification(
      id: seasonStartId,
      at: at,
      title: strings.notifSeasonTitle,
      body: strings.notifSeasonBody,
      payload: NotificationPlanner.payloadOf(CarePlanner.dateOnly(startsOn)),
    );
  }

  static DateTime? _nextFertilizing(CalendarPlan calendar, DateTime today) {
    final dates = [
      for (final entry in calendar.entries)
        if (entry.kind == CareKind.fertilizing &&
            entry.certainty != EntryCertainty.done &&
            !entry.date.isBefore(today))
          entry.date,
    ]..sort();
    return dates.firstOrNull;
  }

  static DateTime _deliveryTime(DateTime now, int morningHour) {
    final soon = now.add(const Duration(minutes: 1));
    if (soon.hour < NotificationPrefs.quietUntilHour) {
      return DateTime(soon.year, soon.month, soon.day, morningHour);
    }
    if (soon.hour >= NotificationPrefs.quietFromHour) {
      return DateTime(soon.year, soon.month, soon.day + 1, morningHour);
    }
    return soon;
  }
}
