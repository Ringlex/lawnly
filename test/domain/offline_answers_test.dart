import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/assistant/offline_answers.dart';
import 'package:lawnly/domain/guide/guide.dart';

void main() {
  test('w październiku nie, następne okno 15 kwietnia', () {
    final advice = scarificationAdvice(DateTime(2026, 10, 9));
    expect(advice.now, isFalse);
    expect(advice.next, DateTime(2027, 4, 15));
  });

  test('w maju i pod koniec sierpnia tak', () {
    expect(scarificationAdvice(DateTime(2026, 5, 10)).now, isTrue);
    expect(scarificationAdvice(DateTime(2026, 8, 20)).now, isTrue);
  });

  test('w lipcu następne okno od 15 sierpnia', () {
    expect(scarificationAdvice(DateTime(2026, 7, 1)).next, DateTime(2026, 8, 15));
  });

  group('wiek trawnika', () {
    LawnProfile lawn(DateTime established, EstablishmentMethod method) => LawnProfile(
      name: 'Ogród',
      location: const LawnLocation(latitude: 50, longitude: 22),
      areaSqm: 100,
      establishedOn: established,
      establishment: method,
      sun: SunExposure.sun,
      grassMix: GrassMix.universal,
      soil: SoilType.medium,
      watering: WateringMode.manual,
      mowingIntervalDays: 7,
      fertilizingIntervalDays: 30,
      gardenWeekdays: const {6},
      fertilizer: FertilizerType.slowGranular,
    );

    test('trawnik z siewu z maja 2025 wertykulujemy dopiero od maja 2027', () {
      final young = lawn(DateTime(2025, 5), EstablishmentMethod.seeded);
      final advice = scarificationAdvice(DateTime(2026, 5, 10), profile: young);

      expect(advice.now, isFalse);
      expect(advice.tooYoung, isTrue);
      expect(advice.next, DateTime(2027, 5));
      expect(
        GuideTopic.scarification.planDate(DateTime(2026, 5, 10), profile: young),
        DateTime(2027, 5),
      );
    });

    test('rolka dojrzewa po roku, aeracja po roku niezależnie od sposobu', () {
      final sod = lawn(DateTime(2025, 6), EstablishmentMethod.sod);

      expect(scarificationAdvice(DateTime(2026, 8, 20), profile: sod).now, isTrue);
      expect(GuideTopic.aeration.tooYoung(sod, DateTime(2026, 5, 31)), isTrue);
      expect(GuideTopic.aeration.planDate(DateTime(2026, 5, 31), profile: sod), DateTime(2026, 9));
      expect(GuideTopic.aeration.goodNow(sod, DateTime(2026, 9, 1)), isTrue);
    });

    test('wiek nie ogranicza innych zabiegów', () {
      final young = lawn(DateTime(2026, 4), EstablishmentMethod.seeded);
      expect(GuideTopic.liming.goodNow(young, DateTime(2026, 10, 16)), isTrue);
    });
  });
}
