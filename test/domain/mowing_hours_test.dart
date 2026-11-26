import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

List<HourForecast> _day({
  Map<int, double> rain = const {},
  Map<int, double> temperature = const {},
  Map<int, int> rainChance = const {},
}) => [
  for (var hour = 0; hour < 24; hour++)
    HourForecast(
      time: DateTime(2026, 10, 17, hour),
      kind: WeatherKind.clear,
      temperatureC: temperature[hour] ?? 14,
      rainMm: rain[hour] ?? 0,
      rainChance: rainChance[hour] ?? 10,
      windKmh: 8,
      isDay: hour >= 7 && hour < 18,
    ),
];

Set<int> _hours(List<HourForecast> day) =>
    CarePlanner.mowingHours(day).map((time) => time.hour).toSet();

void main() {
  test('sucha doba: od 9:00 do zmroku, bez rosy o świcie', () {
    expect(_hours(_day()), {9, 10, 11, 12, 13, 14, 15, 16, 17});
  });

  test('w deszczu i przez dwie godziny po nim trawa jest mokra', () {
    expect(_hours(_day(rain: {12: 1.5})), {9, 10, 11, 15, 16, 17});
  });

  test('niepewna pogoda, upał i chłód odpadają', () {
    final day = _day(rainChance: {10: 70}, temperature: {14: 31, 16: 3});

    expect(_hours(day), {9, 11, 12, 13, 15, 17});
  });
}
