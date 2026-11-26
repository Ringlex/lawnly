import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/data/weather/forecast_repository.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

Map<String, dynamic> _entry(
  DateTime local, {
  required double temperature,
  String? hourSymbol,
  double? hourRain,
  String? sixSymbol,
  double? sixRain,
}) => {
  'time': local.toUtc().toIso8601String(),
  'data': {
    'instant': {
      'details': {'air_temperature': temperature, 'wind_speed': 2.0},
    },
    if (hourSymbol != null)
      'next_1_hours': {
        'summary': {'symbol_code': hourSymbol},
        'details': {'precipitation_amount': hourRain ?? 0.0},
      },
    if (sixSymbol != null)
      'next_6_hours': {
        'summary': {'symbol_code': sixSymbol},
        'details': {'precipitation_amount': sixRain ?? 0.0},
      },
  },
};

final _response = <String, dynamic>{
  'properties': {
    'timeseries': [
      for (var hour = 0; hour < 24; hour++)
        _entry(
          DateTime(2026, 10, 9, hour),
          temperature: 9.4 + (hour == 15 ? 6.7 : 0),
          hourSymbol: hour >= 15 ? 'rain_night' : (hour < 7 ? 'cloudy' : 'cloudy'),
          hourRain: hour >= 15 ? 0.7 : 0.0,
          sixSymbol: 'rain',
          sixRain: 4.0,
        ),
      for (final hour in [0, 6, 12, 18])
        _entry(
          DateTime(2026, 10, 10, hour),
          temperature: hour == 12 ? 18.6 : 8.0,
          sixSymbol: 'cloudy',
          sixRain: 0.0,
        ),
      for (final hour in [0, 6, 12, 18])
        _entry(
          DateTime(2026, 10, 11, hour),
          temperature: hour == 12 ? 13.3 : 4.2,
          sixSymbol: 'clearsky_day',
          sixRain: 0.1,
        ),
    ],
  },
};

void main() {
  final report = MetNoForecastRepository.parse(_response);
  final days = report.days;

  test('bieżące warunki i temperatura minimalna', () {
    expect(report.current!.temperatureC, 9.4);
    expect(report.current!.kind, WeatherKind.cloudy);
    expect(report.current!.isDay, isTrue);
    expect(days[0].minTempC, 9.4);
    expect(days[0].maxTempC, 16.1);
  });

  test('prognoza godzinowa: godziny danego dnia, opad i noc', () {
    final hours = report.hoursOn(DateTime(2026, 10, 9));

    expect(hours, hasLength(24));
    expect(hours[15].time, DateTime(2026, 10, 9, 15));
    expect(hours[15].rainMm, 0.7);
    expect(hours[15].kind, WeatherKind.rain);
    expect(hours[15].isDay, isFalse);
    expect(hours[2].isDay, isTrue);
    expect(report.hoursOn(DateTime(2026, 10, 10)), isEmpty);
  });

  test('dzień deszczowy: suma opadu bez podwójnego liczenia i godzina początku', () {
    final today = days[0];

    expect(today.date, DateTime(2026, 10, 9));
    expect(today.kind, WeatherKind.rain);
    expect(today.rainMm, closeTo(0.7 * 9, 0.001));
    expect(today.rainFromHour, 15);
  });

  test('dni z krokiem sześciogodzinnym: pochmurno i pogodnie', () {
    expect(days[1].kind, WeatherKind.cloudy);
    expect(days[1].maxTempC, 18.6);
    expect(days[2].kind, WeatherKind.clear);
  });

  test('śladowy opad nie daje godziny deszczu', () {
    expect(days[1].rainFromHour, isNull);
    expect(days[2].rainFromHour, isNull);
  });

  test('limit liczby dni', () {
    expect(MetNoForecastRepository.parse(_response, days: 2).days, hasLength(2));
  });

  test('niepewny deszcz nie robi z dnia idealnego do nawożenia', () {
    final unlikely = DayForecast(
      date: DateTime(2026, 10, 9),
      kind: WeatherKind.rain,
      maxTempC: 16,
      rainMm: 5,
      rainChance: 35,
      maxWindKmh: 10,
    );

    expect(CarePlanner.rate(unlikely), DayConditions.acceptable);
  });
}
