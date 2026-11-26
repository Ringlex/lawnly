import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';

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
  gardenWeekdays: const {5, 6, 7},
  fertilizer: FertilizerType.liquid,
  fertilizingIntervalDays: 15,
);

LawnProfile _manual(ManualWateringMethod? method) => _profile.copyWith(
  watering: WateringMode.manual,
  sprinklerMinutes: null,
  manualWateringMethod: method,
);

JournalEntry _watering({int? minutes, double? litres}) => JournalEntry(
  id: '1',
  kind: JournalKind.care,
  careKind: CareKind.watering,
  date: DateTime(2026, 7, 1),
  wateringMinutes: minutes,
  wateringLitres: litres,
);

void main() {
  group('automatyczne', () {
    test('bez kalibracji: czas sekcji z ustawień', () {
      expect((WateringGuide.of(_profile) as NoGuide).sectionMinutes, 20);
    });

    test('po kalibracji 0,6 mm/min: 25 min na 15 mm', () {
      final guide = WateringGuide.of(_profile.copyWith(sprinklerMmPerMinute: 0.6));
      expect((guide as SectionGuide).minutes, 25);
    });
  });

  group('ręczne', () {
    test('bez wybranego sposobu: ogólna rada', () {
      expect(WateringGuide.of(_manual(null)), isA<NoGuide>());
    });

    test('zraszacz na wężu: czas w jednym miejscu i liczba przestawień', () {
      final guide = WateringGuide.of(
        _manual(
          ManualWateringMethod.hoseSprinkler,
        ).copyWith(sprinklerMmPerMinute: 0.6, sprinklerCoverageSqm: 28),
      );

      expect((guide as SpotGuide).minutesPerSpot, 25);
      expect(guide.moves, 9);
    });

    test('wąż 12 l/min: 1,25 min na m², 5 h 13 min na cały trawnik, 6 wieczorów', () {
      final guide = WateringGuide.of(
        _manual(ManualWateringMethod.hose).copyWith(hoseLitresPerMinute: 12),
      );

      guide as HoseGuide;
      expect(guide.minutesPerSqm, 1.25);
      expect(guide.totalMinutes, 313);
      expect(guide.sessions, 6);
    });

    test('konewka: 15 l na m², półtorej konewki, 3750 l na cały trawnik', () {
      final guide = WateringGuide.of(_manual(ManualWateringMethod.wateringCan)) as CanGuide;

      expect(guide.litresPerSqm, 15);
      expect(guide.cansPerSqm, 1.5);
      expect(guide.totalLitres, 3750);
    });
  });

  group('woda z wpisów dziennika', () {
    test('automatyczne: minuty × mm/min', () {
      final profile = _profile.copyWith(sprinklerMmPerMinute: 0.6);
      expect(wateringMmOf(_watering(minutes: 25), profile), closeTo(15, 1e-9));
    });

    test('wąż: litry rozłożone na całą powierzchnię', () {
      final profile = _manual(ManualWateringMethod.hose).copyWith(hoseLitresPerMinute: 12);
      expect(wateringMmOf(_watering(minutes: 60), profile), closeTo(2.88, 1e-9));
    });

    test('konewka: litry na powierzchnię', () {
      final profile = _manual(ManualWateringMethod.wateringCan);
      expect(wateringMmOf(_watering(litres: 50), profile), closeTo(0.2, 1e-9));
    });

    test('bez pomiaru nie da się policzyć', () {
      expect(wateringMmOf(_watering(minutes: 20), _profile), isNull);
    });
  });
}
