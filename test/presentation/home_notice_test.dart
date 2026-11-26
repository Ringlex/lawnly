import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/presentation/home/home_notice.dart';
import 'package:lawnly/presentation/home/home_state.dart';

void main() {
  final today = DateTime(2026, 5, 10);

  DayForecast day(int offset, {double? minTemp, double maxTemp = 18, double rain = 0}) =>
      DayForecast(
        date: today.add(Duration(days: offset)),
        kind: WeatherKind.clear,
        maxTempC: maxTemp,
        rainMm: rain,
        maxWindKmh: 5,
        minTempC: minTemp,
      );

  test('bez zagrożeń i ze świeżą prognozą nie ma komunikatów', () {
    final state = HomeState(today: today, forecast: [day(0), day(1)], forecastFetchedAt: today);

    expect(homeNotices(state, today), isEmpty);
  });

  test('przymrozek jutro daje ostrzeżenie', () {
    final state = HomeState(today: today, forecast: [day(0), day(1, minTemp: -1)]);

    final notice = homeNotices(state, today).single as WeatherWarning;

    expect(notice.risk, WeatherRisk.frost);
    expect(notice.isToday, isFalse);
  });

  test('stara prognoza daje komunikat o wieku danych', () {
    final state = HomeState(
      today: today,
      forecast: [day(0)],
      forecastFetchedAt: today.subtract(const Duration(hours: 9)),
    );

    final notice = homeNotices(state, today).single as StaleForecast;

    expect(notice.age.inHours, 9);
  });
}
