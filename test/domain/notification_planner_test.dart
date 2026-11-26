import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/core/l10n/generated/app_localizations.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/notifications/notification_planner.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';

void main() {
  const planner = NotificationPlanner();
  final strings = lookupL10n(const Locale('pl'));
  final now = DateTime(2026, 5, 10, 6);
  final tomorrow = DateTime(2026, 5, 11);

  CareEntry entry(CareKind kind, DateTime date) =>
      CareEntry(kind: kind, date: date, certainty: EntryCertainty.matched);

  DayForecast day(DateTime date, {double? minTemp, double rain = 0}) => DayForecast(
    date: date,
    kind: WeatherKind.clear,
    maxTempC: 18,
    rainMm: rain,
    maxWindKmh: 5,
    minTempC: minTemp,
  );

  List<PlannedNotification> run({
    NotificationPrefs prefs = const NotificationPrefs(enabled: true),
    List<CareEntry> entries = const [],
    List<DayForecast> forecast = const [],
  }) => planner.plan(
    prefs: prefs,
    calendar: CalendarPlan(entries: entries, windows: const []),
    forecast: forecast,
    now: now,
    strings: strings,
  );

  test('wyłączone powiadomienia nic nie planują', () {
    final result = run(
      prefs: const NotificationPrefs(),
      entries: [entry(CareKind.mowing, tomorrow)],
    );

    expect(result, isEmpty);
  });

  test('najwyżej jedno poranne powiadomienie dziennie, nawożenie ma pierwszeństwo', () {
    final result = run(
      entries: [entry(CareKind.watering, tomorrow), entry(CareKind.fertilizing, tomorrow)],
    );

    expect(result, hasLength(1));
    expect(result.single.at, DateTime(2026, 5, 11, NotificationPrefs.defaultMorningHour));
    expect(result.single.payload, '2026-05-11');
  });

  test('wyłączona kategoria jest pomijana', () {
    final result = run(
      prefs: const NotificationPrefs(enabled: true, care: false),
      entries: [entry(CareKind.mowing, tomorrow)],
    );

    expect(result, isEmpty);
  });

  CareEntry programEntry(DateTime date) => CareEntry(
    kind: CareKind.fertilizing,
    date: date,
    certainty: EntryCertainty.matched,
    task: PlannedTask(
      id: 'program:icl-one:step:2026',
      kind: CareKind.fertilizing,
      date: date,
      flexible: false,
      note: 'Nawóz X · 30 g/m² × 100 m² = 3,0 kg\nŹródło: example.pl',
    ),
  );

  test('krok programu podaje produkt, dawkę i ilość', () {
    final result = run(entries: [programEntry(tomorrow)], forecast: [day(tomorrow)]);

    expect(result.single.title, strings.notifProgramTitle);
    expect(result.single.body, 'Nawóz X · 30 g/m² × 100 m² = 3,0 kg');
  });

  test('krok programu ostrzega przed ulewnym deszczem w dniu zabiegu', () {
    final result = run(entries: [programEntry(tomorrow)], forecast: [day(tomorrow, rain: 12)]);

    expect(result.single.body, contains('Nawóz X'));
    expect(result.single.body, contains(strings.notifProgramRain(12)));
  });

  test('ostrzeżenie o przymrozku przychodzi dzień wcześniej wieczorem', () {
    final result = run(forecast: [day(tomorrow, minTemp: -2)]);

    expect(result, hasLength(1));
    expect(result.single.at, DateTime(2026, 5, 10, 17, 45));
    expect(result.single.title, strings.noticeFrostTitle);
  });

  test('ostrzeżenia można wyłączyć', () {
    final result = run(
      prefs: const NotificationPrefs(enabled: true, warnings: false),
      forecast: [day(tomorrow, minTemp: -2)],
    );

    expect(result, isEmpty);
  });

  test('godzina poranna jest ograniczona do godzin poza ciszą nocną', () {
    final prefs = NotificationPrefs.fromJson({'enabled': true, 'morningHour': 23});

    expect(prefs.morningHour, NotificationPrefs.quietFromHour - 1);
  });
}
