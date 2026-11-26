import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

final _today = DateTime(2026, 10, 9);

DateTime _day(int offset) => DateTime(_today.year, _today.month, _today.day + offset);

LawnProfile _profile({
  int interval = 15,
  int? daysSinceFertilized = 13,
  Set<int> gardenWeekdays = const {1, 2, 3, 4, 5, 6, 7},
}) => LawnProfile(
  name: 'Przed domem',
  location: const LawnLocation(latitude: 52.23, longitude: 21.01),
  areaSqm: 250,
  establishedOn: DateTime(2024, 5),
  establishment: EstablishmentMethod.seeded,
  sun: SunExposure.sun,
  grassMix: GrassMix.ornamental,
  soil: SoilType.medium,
  watering: WateringMode.automatic,
  sprinklerMinutes: 20,
  mowingIntervalDays: 5,
  gardenWeekdays: gardenWeekdays,
  fertilizer: FertilizerType.liquid,
  fertilizingIntervalDays: interval,
  lastFertilizedOn: daysSinceFertilized == null ? null : _day(-daysSinceFertilized),
);

DayForecast _dry(int offset, {double temp = 15}) => DayForecast(
  date: _day(offset),
  kind: WeatherKind.cloudy,
  maxTempC: temp,
  rainMm: 0,
  maxWindKmh: 10,
);

DayForecast _rain(int offset, {double mm = 6, double temp = 16}) => DayForecast(
  date: _day(offset),
  kind: WeatherKind.rain,
  maxTempC: temp,
  rainMm: mm,
  rainFromHour: 15,
  maxWindKmh: 9,
);

void main() {
  const planner = CarePlanner();

  group('FertilizingWindow', () {
    test('15 dni daje okno od 12. do 18. dnia', () {
      const window = FertilizingWindow(15);
      expect((window.start, window.end), (12, 18));
    });

    test('krótki interwał ma co najmniej 2 dni zapasu', () {
      const window = FertilizingWindow(7);
      expect((window.start, window.end), (5, 9));
    });
  });

  group('fertilizing', () {
    test('13. dzień z 15 i lekki deszcz po południu: nawóź dziś', () {
      final advice = planner.fertilizing(
        profile: _profile(),
        forecast: [_rain(0), _dry(1), _dry(2), _dry(3), _dry(4)],
        today: _today,
      );

      expect(advice, isA<FertilizeOn>());
      advice as FertilizeOn;
      expect(advice.day.date, _today);
      expect(advice.conditions, DayConditions.ideal);
      expect((advice.cycleDay, advice.interval), (13, 15));
    });

    test('idealny dzień po interwale wygrywa ze zwykłym dniem 15.', () {
      final advice = planner.fertilizing(
        profile: _profile(),
        forecast: [_dry(0), _dry(1), _dry(2), _rain(3), _dry(4)],
        today: _today,
      );

      expect((advice as FertilizeOn).day.date, _day(3));
    });

    test('bez idealnego dnia wybiera dzień najbliżej interwału', () {
      final advice = planner.fertilizing(
        profile: _profile(),
        forecast: [_dry(0), _dry(1), _dry(2), _dry(3), _dry(4)],
        today: _today,
      );

      expect((advice as FertilizeOn).day.date, _day(2));
      expect(advice.conditions, DayConditions.acceptable);
    });

    test('ulewa i upał odpadają', () {
      final advice = planner.fertilizing(
        profile: _profile(daysSinceFertilized: 16),
        forecast: [_rain(0, mm: 25), _dry(1, temp: 30), _dry(2, temp: 31)],
        today: _today,
      );

      expect(advice, isA<WaitForWeather>());
    });

    test('pomija dni bez czasu na ogród', () {
      final advice = planner.fertilizing(
        profile: _profile(gardenWeekdays: {DateTime.sunday}),
        forecast: [_rain(0), _dry(1), _rain(2), _dry(3)],
        today: _today,
      );

      expect((advice as FertilizeOn).day.date.weekday, DateTime.sunday);
    });

    test('przesunięty dzień nie wraca jako propozycja', () {
      final advice = planner.fertilizing(
        profile: _profile(),
        forecast: [_rain(0), _dry(1), _rain(2)],
        today: _today,
        skipped: {_today},
      );

      expect((advice as FertilizeOn).day.date, _day(2));
    });

    test('przed oknem i poza zasięgiem prognozy: nawożenie później', () {
      final advice = planner.fertilizing(
        profile: _profile(daysSinceFertilized: 3),
        forecast: [_rain(0), _rain(1), _rain(2), _rain(3), _rain(4)],
        today: _today,
      );

      expect(advice, isA<FertilizeLater>());
      advice as FertilizeLater;
      expect(advice.daysLeft, 9);
      expect(advice.windowOpensOn, _day(9));
    });

    test('nieznana data ostatniego nawożenia oznacza, że nawożenie należy się już', () {
      final advice = planner.fertilizing(
        profile: _profile(daysSinceFertilized: null),
        forecast: [_rain(0)],
        today: _today,
      );

      expect((advice as FertilizeOn).day.date, _today);
    });
  });

  group('watering', () {
    test('deszcz w ciągu 3 dni wystarcza', () {
      final advice = planner.watering([_rain(0), _dry(1), _dry(2)]);
      expect((advice.needed, advice.reason), (false, WateringReason.rainExpected));
    });

    test('chłodno i sucho: podlewanie zbędne', () {
      final advice = planner.watering([_dry(0, temp: 12), _dry(1, temp: 11)]);
      expect((advice.needed, advice.reason), (false, WateringReason.cool));
    });

    test('ciepło i sucho: trzeba podlać', () {
      final advice = planner.watering([_dry(0, temp: 24), _dry(1, temp: 26)]);
      expect((advice.needed, advice.reason), (true, WateringReason.dry));
    });
  });
}
