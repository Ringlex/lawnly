import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/journal/season_summary.dart';
import 'package:lawnly/domain/plan/growing_season.dart';

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
  mowingIntervalDays: 5,
  gardenWeekdays: const {5, 6, 7},
  fertilizer: FertilizerType.liquid,
  fertilizingIntervalDays: 15,
);

var _id = 0;

JournalEntry _care(CareKind kind, DateTime date, {String? npk, double? dose, DoseUnit? unit}) =>
    JournalEntry(
      id: '${_id++}',
      kind: JournalKind.care,
      careKind: kind,
      date: date,
      npk: npk,
      dose: dose,
      doseUnit: unit ?? DoseUnit.gramsPerSqm,
    );

void main() {
  final today = DateTime(2026, 10, 9);

  group('seasonFor', () {
    const season = GrowingSeason();

    test('w sezonie: od 1 kwietnia do dziś', () {
      expect(SeasonSummary.seasonFor(today, season), (DateTime(2026, 4, 1), today));
    });

    test('zimą przed sezonem: poprzedni, zakończony sezon', () {
      expect(SeasonSummary.seasonFor(DateTime(2027, 2, 10), season), (
        DateTime(2026, 4, 1),
        DateTime(2026, 10, 31),
      ));
    });
  });

  test('skład NPK: azot to pierwsza liczba', () {
    expect(SeasonSummary.nitrogenPercent('5-3-10'), 5);
    expect(SeasonSummary.nitrogenPercent('12,5-4-8'), 12.5);
    expect(SeasonSummary.nitrogenPercent(null), isNull);
    expect(SeasonSummary.nitrogenPercent('jesienny'), isNull);
  });

  test('liczy zabiegi z sezonu, miesiące, azot i ilość nawozu', () {
    final entries = [
      _care(CareKind.mowing, DateTime(2026, 5, 2)),
      _care(CareKind.mowing, DateTime(2026, 5, 9)),
      _care(CareKind.mowing, DateTime(2026, 10, 4)),
      _care(CareKind.mowing, DateTime(2025, 10, 20)),
      _care(CareKind.fertilizing, DateTime(2026, 5, 2), npk: '20-5-8', dose: 30),
      _care(
        CareKind.fertilizing,
        DateTime(2026, 10, 9),
        npk: '5-3-10',
        dose: 20,
        unit: DoseUnit.mlPerSqm,
      ),
      _care(CareKind.watering, DateTime(2026, 7, 15)),
      JournalEntry(
        id: 'obs',
        kind: JournalKind.observation,
        date: DateTime(2026, 10, 4),
        tags: {ObservationTag.moss},
      ),
    ];

    final summary = SeasonSummary.from(entries: entries, profile: _profile, today: today);

    expect((summary.mowings, summary.fertilizings, summary.waterings), (3, 2, 1));
    expect(summary.months.length, 7);
    expect(summary.months[1].mowings, 2);
    expect(summary.months[1].fertilizings, 1);
    expect(summary.nitrogenPer100Sqm, closeTo(0.7, 1e-9));
    expect(summary.granularKg, closeTo(7.5, 1e-9));
    expect(summary.liquidLitres, closeTo(5, 1e-9));
    expect(summary.nitrogenRange, (2.0, 3.0));
    expect(summary.observations.single.id, 'obs');
  });

  test('bez składu i dawki azotu nie liczymy', () {
    final summary = SeasonSummary.from(
      entries: [_care(CareKind.fertilizing, DateTime(2026, 6, 1))],
      profile: _profile,
      today: today,
    );

    expect(summary.nitrogenPer100Sqm, isNull);
  });
}
