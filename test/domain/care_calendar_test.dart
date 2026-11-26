import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

final _today = DateTime(2026, 10, 9);

DateTime _oct(int day) => DateTime(2026, 10, day);

final _profile = LawnProfile(
  name: 'Przed domem',
  location: const LawnLocation(latitude: 50.04, longitude: 21.99),
  areaSqm: 250,
  establishedOn: DateTime(2024, 5),
  establishment: EstablishmentMethod.seeded,
  sun: SunExposure.sun,
  grassMix: GrassMix.ornamental,
  soil: SoilType.medium,
  watering: WateringMode.automatic,
  sprinklerMinutes: 20,
  mowingIntervalDays: 5,
  lastMowedOn: _oct(4),
  gardenWeekdays: const {DateTime.wednesday, DateTime.friday, DateTime.saturday, DateTime.sunday},
  fertilizer: FertilizerType.liquid,
  fertilizingIntervalDays: 15,
  lastFertilizedOn: DateTime(2026, 9, 26),
);

DayForecast _day(int day, WeatherKind kind, double temp, {double rain = 0, int? from}) =>
    DayForecast(
      date: _oct(day),
      kind: kind,
      maxTempC: temp,
      rainMm: rain,
      rainFromHour: from,
      maxWindKmh: 10,
    );

final _forecast = [
  _day(9, WeatherKind.rain, 16, rain: 6, from: 15),
  _day(10, WeatherKind.cloudy, 14),
  _day(11, WeatherKind.clear, 15),
  _day(12, WeatherKind.cloudy, 12),
  _day(13, WeatherKind.rain, 11, rain: 4, from: 9),
];

void main() {
  const calendar = CareCalendar();

  CalendarPlan build({CarePlan plan = const CarePlan(), LawnProfile? profile}) => calendar.build(
    profile: profile ?? _profile,
    plan: plan,
    forecast: _forecast,
    today: _today,
    from: DateTime(2026, 9, 28),
    to: DateTime(2026, 11, 1),
  );

  List<CareEntry> of(CalendarPlan plan, CareKind kind) =>
      plan.entries.where((e) => e.kind == kind).toList();

  group('nawożenie', () {
    test('aktywny program producenta wyłącza standardowy cykl nawożenia', () {
      final standard = build().entries.where((e) => e.kind == CareKind.fertilizing);
      final withProgram = build(
        plan: const CarePlan(activeProgramId: 'icl-two'),
      ).entries.where((e) => e.kind == CareKind.fertilizing);

      expect(standard, isNotEmpty);
      expect(withProgram, isEmpty);
    });

    test('dziś idealnie, następne wstępnie w sobotę 24.10 z oknem 21–27', () {
      final fertilizing = of(
        build(),
        CareKind.fertilizing,
      ).where((e) => e.certainty != EntryCertainty.done).toList();

      expect(fertilizing[0].date, _today);
      expect(fertilizing[0].certainty, EntryCertainty.matched);
      expect(fertilizing[0].cycle!.window.start, _oct(8));
      expect(fertilizing[0].cycle!.window.end, _oct(14));

      expect(fertilizing[1].date, _oct(24));
      expect(fertilizing[1].certainty, EntryCertainty.tentative);
      expect(fertilizing[1].cycle!.window.start, _oct(21));
      expect(fertilizing[1].cycle!.window.end, _oct(27));
    });

    test('przypięty dzień wygrywa z doborem pod pogodę', () {
      final plan = build(plan: CarePlan(pinnedFertilizingOn: _oct(11)));
      final current = of(plan, CareKind.fertilizing).firstWhere((e) => e.cycle?.isCurrent ?? false);

      expect(current.date, _oct(11));
      expect(current.certainty, EntryCertainty.fixed);
      expect((current.advice! as FertilizeOn).pinned, isTrue);
    });

    test('pominięty cykl przesuwa nawożenie o interwał, na dzień na ogród', () {
      final plan = build(plan: CarePlan(skippedFertilizingOn: [_oct(11)]));
      final current = of(plan, CareKind.fertilizing).firstWhere((e) => e.cycle?.isCurrent ?? false);

      expect(current.cycle!.nominal, _oct(26));
      expect(current.date, _oct(25));
      expect(current.certainty, EntryCertainty.tentative);
    });

    test('ostatnie nawożenie widać w kalendarzu jako zrobione', () {
      final plan = calendar.build(
        profile: _profile.copyWith(lastFertilizedOn: _oct(2)),
        plan: const CarePlan(),
        forecast: _forecast,
        today: _today,
        from: DateTime(2026, 9, 28),
        to: DateTime(2026, 11, 1),
      );

      expect(plan.on(_oct(2)).single.certainty, EntryCertainty.done);
    });
  });

  group('koszenie', () {
    test('co 5 dni w dni na ogród, dziś rano przed deszczem', () {
      final mowing = of(
        build(),
        CareKind.mowing,
      ).where((e) => e.certainty != EntryCertainty.done).map((e) => e.date).toList();

      expect(mowing.take(4), [_oct(9), _oct(14), _oct(21), _oct(28)]);
    });

    test('deszcz od rana przesuwa koszenie na kolejny dzień na ogród', () {
      final plan = build(profile: _profile.copyWith(lastMowedOn: _oct(8)));
      final next = of(plan, CareKind.mowing).firstWhere((e) => e.date.isAfter(_today));

      expect(next.date, _oct(14));
    });
  });

  group('usuwanie z kalendarza', () {
    test('usunięte koszenie znika, a kolejne zostają w tym samym rytmie', () {
      final plan = build(
        plan: CarePlan(
          skipped: [SkippedEntry(kind: CareKind.mowing, date: _oct(14))],
        ),
      );
      final mowing = of(
        plan,
        CareKind.mowing,
      ).where((e) => e.certainty != EntryCertainty.done).map((e) => e.date).toList();

      expect(mowing.take(3), [_oct(9), _oct(21), _oct(28)]);
    });

    test('pominięty dalszy cykl nawożenia znika, następny liczy się od niego', () {
      final plan = build(plan: CarePlan(skippedFertilizingOn: [_oct(24)]));
      final upcoming = of(
        plan,
        CareKind.fertilizing,
      ).where((e) => e.certainty != EntryCertainty.done).map((e) => e.date).toList();

      expect(upcoming, isNot(contains(_oct(24))));
      expect(upcoming.length, 1);
    });
  });

  group('własne zabiegi przestawiają plan', () {
    List<DateTime> mowingDates(CalendarPlan plan) => of(
      plan,
      CareKind.mowing,
    ).where((e) => e.certainty != EntryCertainty.done).map((e) => e.date).toList()..sort();

    test('koszenie dzień przed planowanym: plan znika, kolejne liczone od niego', () {
      final own = PlannedTask(id: '1', kind: CareKind.mowing, date: _oct(13), flexible: false);
      final dates = mowingDates(build(plan: CarePlan(tasks: [own])));

      expect(dates.take(5), [_oct(9), _oct(13), _oct(18), _oct(23), _oct(28)]);
      expect(dates, isNot(contains(_oct(14))));
    });

    test('elastyczne koszenie w deszczowy dzień przesuwa się, a plan liczy od nowego dnia', () {
      final own = PlannedTask(id: '1', kind: CareKind.mowing, date: _oct(13));
      final plan = build(plan: CarePlan(tasks: [own]));
      final ownEntry = plan.entries.firstWhere((e) => e.task != null);

      expect(ownEntry.date, _oct(11));
      expect(mowingDates(plan).take(4), [_oct(11), _oct(16), _oct(21), _oct(28)]);
    });

    test('własne nawożenie w oknie zastępuje cykl z planu', () {
      final own = PlannedTask(id: '1', kind: CareKind.fertilizing, date: _oct(10), flexible: false);
      final plan = build(plan: CarePlan(tasks: [own]));
      final fertilizing = of(
        plan,
        CareKind.fertilizing,
      ).where((e) => e.certainty != EntryCertainty.done).toList();

      expect(fertilizing.where((e) => e.task == null && e.date == _today), isEmpty);
      expect(fertilizing.firstWhere((e) => e.task == null).date, _oct(25));
    });
  });

  group('sezon', () {
    final lateOctober = DateTime(2026, 10, 27);
    final spring = DateTime(2027, 4, 1);

    CalendarPlan lateBuild(LawnProfile profile, {DateTime? today}) => calendar.build(
      profile: profile,
      plan: const CarePlan(),
      forecast: const [],
      today: today ?? lateOctober,
      from: today ?? lateOctober,
      to: DateTime(2027, 4, 30),
    );

    List<DateTime> datesOf(CalendarPlan plan, CareKind kind) =>
        of(plan, kind).where((e) => e.certainty != EntryCertainty.done).map((e) => e.date).toList()
          ..sort();

    bool inWinter(DateTime d) => d.isAfter(DateTime(2026, 10, 31)) && d.isBefore(spring);

    test('ostatnie nawożenie mieści się w październiku, następne dopiero wiosną', () {
      final plan = lateBuild(_profile.copyWith(lastFertilizedOn: _oct(15)));
      final dates = datesOf(plan, CareKind.fertilizing);

      expect(dates.first, _oct(30));
      expect(dates.where(inWinter), isEmpty);
      expect(dates[1].isBefore(spring), isFalse);
      expect(dates[1].isBefore(DateTime(2027, 4, 8)), isTrue);
    });

    test('okno zaczynające się po sezonie przechodzi na wiosnę', () {
      final plan = lateBuild(_profile.copyWith(lastFertilizedOn: DateTime(2026, 10, 25)));
      final current = of(plan, CareKind.fertilizing).firstWhere((e) => e.cycle?.isCurrent ?? false);

      expect(current.cycle!.window.start, spring);
      expect(current.certainty, EntryCertainty.tentative);
    });

    test('koszenie kończy się w październiku i wraca w pierwszy wiosenny dzień na ogród', () {
      final plan = lateBuild(_profile.copyWith(lastMowedOn: DateTime(2026, 10, 25)));
      final dates = datesOf(plan, CareKind.mowing);

      expect(dates.first, _oct(30));
      expect(dates.where(inWinter), isEmpty);
      expect(dates[1], DateTime(2027, 4, 2));
    });

    test('własny sezon z profilu: koniec 15 października', () {
      final profile = _profile.copyWith(
        lastMowedOn: DateTime(2026, 10, 8),
        seasonEndMonth: DateTime.october,
        seasonEndDay: 15,
      );
      final plan = calendar.build(
        profile: profile,
        plan: const CarePlan(),
        forecast: const [],
        today: _today,
        from: _today,
        to: DateTime(2026, 11, 30),
      );
      final dates = datesOf(plan, CareKind.mowing);

      expect(dates.first, _oct(14));
      expect(dates.where((d) => d.isAfter(_oct(15)) && d.isBefore(spring)), isEmpty);
    });

    test('zimą plan automatyczny jest pusty aż do kwietnia', () {
      final december = DateTime(2026, 12, 1);
      final plan = lateBuild(_profile, today: december);

      expect(
        plan.entries
            .where((e) => e.certainty != EntryCertainty.done)
            .where((e) => inWinter(e.date)),
        isEmpty,
      );
    });
  });

  test('zrobione własne koszenie widać raz, choć zapisało się też w profilu', () {
    final own = PlannedTask(id: '1', kind: CareKind.mowing, date: _today, doneOn: _today);
    final plan = calendar.build(
      profile: _profile.copyWith(lastMowedOn: _today),
      plan: CarePlan(tasks: [own]),
      forecast: _forecast,
      today: _today,
      from: DateTime(2026, 9, 28),
      to: DateTime(2026, 11, 1),
    );

    final done = plan.on(_today).where((e) => e.kind == CareKind.mowing).toList();
    expect(done.single.task, own);
  });

  group('zabiegi użytkownika', () {
    final aeration = PlannedTask(id: '1', kind: CareKind.aeration, date: _oct(13));

    test('elastyczna aeracja ucieka przed deszczem na niedzielę', () {
      final entry = build(
        plan: CarePlan(tasks: [aeration]),
      ).entries.firstWhere((e) => e.task != null);

      expect(entry.date, _oct(11));
      expect(entry.movedFrom, _oct(13));
    });

    test('stały termin zostaje mimo deszczu', () {
      final fixed = aeration.copyWith(flexible: false);
      final entry = build(plan: CarePlan(tasks: [fixed])).entries.firstWhere((e) => e.task != null);

      expect(entry.date, _oct(13));
      expect(entry.movedFrom, isNull);
    });

    test('poza prognozą termin jest wstępny', () {
      final later = aeration.copyWith(date: _oct(20));
      final entry = build(plan: CarePlan(tasks: [later])).entries.firstWhere((e) => e.task != null);

      expect(entry.certainty, EntryCertainty.tentative);
    });
  });

  group('sprawdzanie pogody', () {
    WeatherCheck check(DateTime date) => calendar.check(
      kind: CareKind.aeration,
      date: date,
      forecast: _forecast,
      today: _today,
      profile: _profile,
    );

    test('deszcz we wtorek: podpowiada niedzielę, a nie zajęty poniedziałek', () {
      final result = check(_oct(13));

      expect(result, isA<BadWeather>());
      expect((result as BadWeather).suggestion!.date, _oct(11));
    });

    test('sucha niedziela pasuje', () {
      expect(check(_oct(11)), isA<GoodWeather>());
    });

    test('bez prognozy nie ma czego sprawdzać', () {
      expect(check(_oct(20)), isA<NoForecast>());
    });
  });
}
