import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:lawnly/core/fpdarts.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/weather/day_forecast.dart';

enum ForecastFailure { network }

abstract class ForecastRepository {
  const ForecastRepository();

  TaskEither<ForecastFailure, WeatherReport> report(LawnLocation location, {int days = 14});

  TaskEither<ForecastFailure, Map<DateTime, double>> pastRain(
    LawnLocation location, {
    required DateTime start,
    required DateTime end,
  });
}

class MetNoForecastRepository extends ForecastRepository {
  const MetNoForecastRepository({required http.Client client}) : _client = client;

  final http.Client _client;

  static const _host = 'api.met.no';

  static const _historyHost = 'historical-forecast-api.open-meteo.com';

  static const _userAgent = 'Lawnly/1.0 (+https://lawnly-assistant.pitstop-garage.workers.dev)';

  static const _rainHourThresholdMm = 0.2;

  static const _rainDayThresholdMm = 0.5;

  static const _noonHour = 12;

  static const _msToKmh = 3.6;

  @override
  TaskEither<ForecastFailure, WeatherReport> report(LawnLocation location, {int days = 14}) =>
      tryCatchE<ForecastFailure, WeatherReport>(() async {
        final uri = Uri.https(_host, '/weatherapi/locationforecast/2.0/compact', {
          'lat': location.latitude.toStringAsFixed(4),
          'lon': location.longitude.toStringAsFixed(4),
        });
        final response = await _client.get(uri, headers: {'User-Agent': _userAgent});
        if (response.statusCode != 200) {
          return left(ForecastFailure.network);
        }
        return right(parse(jsonDecode(response.body) as Map<String, dynamic>, days: days));
      }, (_, _) => ForecastFailure.network);

  @override
  TaskEither<ForecastFailure, Map<DateTime, double>> pastRain(
    LawnLocation location, {
    required DateTime start,
    required DateTime end,
  }) => tryCatchE<ForecastFailure, Map<DateTime, double>>(() async {
    String day(DateTime date) => date.toIso8601String().substring(0, 10);
    final uri = Uri.https(_historyHost, '/v1/forecast', {
      'latitude': location.latitude.toStringAsFixed(4),
      'longitude': location.longitude.toStringAsFixed(4),
      'start_date': day(start),
      'end_date': day(end),
      'daily': 'precipitation_sum',
      'timezone': 'auto',
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      return left(ForecastFailure.network);
    }
    return right(parsePastRain(jsonDecode(response.body) as Map<String, dynamic>));
  }, (_, _) => ForecastFailure.network);

  static Map<DateTime, double> parsePastRain(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final rain = (daily['precipitation_sum'] as List<dynamic>).cast<num?>();
    return {
      for (var i = 0; i < dates.length; i++) DateTime.parse(dates[i]): rain[i]?.toDouble() ?? 0,
    };
  }

  static WeatherReport parse(Map<String, dynamic> json, {int days = 14}) {
    final series = ((json['properties'] as Map<String, dynamic>)['timeseries'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final steps = [for (final entry in series) _Step.from(entry)];

    final hours = [
      for (final step in steps)
        if (step.hourlySymbol != null)
          HourForecast(
            time: step.time,
            kind: _kindOf(step.hourlySymbol!),
            temperatureC: step.temperatureC,
            rainMm: step.rainMm,
            windKmh: step.windKmh,
            isDay: !step.hourlySymbol!.endsWith('_night'),
          ),
    ];

    final byDay = <DateTime, List<_Step>>{};
    for (final step in steps) {
      byDay
          .putIfAbsent(DateTime(step.time.year, step.time.month, step.time.day), () => [])
          .add(step);
    }

    final forecasts = [
      for (final MapEntry(key: date, value: group) in byDay.entries.take(days)) _dayOf(date, group),
    ];

    final first = steps.first;
    return WeatherReport(
      days: forecasts,
      hours: hours,
      current: CurrentWeather(
        temperatureC: first.temperatureC,
        kind: _kindOf(first.hourlySymbol ?? first.sixHourSymbol ?? 'cloudy'),
        windKmh: first.windKmh,
        isDay: !(first.hourlySymbol ?? '').endsWith('_night'),
      ),
    );
  }

  static DayForecast _dayOf(DateTime date, List<_Step> group) {
    final rainMm = group.fold(0.0, (sum, step) => sum + step.rainMm);
    final noon = group.reduce(
      (a, b) => (a.time.hour - _noonHour).abs() <= (b.time.hour - _noonHour).abs() ? a : b,
    );
    final symbol = noon.hourlySymbol ?? noon.sixHourSymbol ?? 'cloudy';
    final firstRain = group.firstWhereOrNull(
      (step) => step.hourlySymbol != null && step.rainMm >= _rainHourThresholdMm,
    );

    return DayForecast(
      date: date,
      kind: rainMm >= _rainDayThresholdMm ? WeatherKind.rain : _kindOf(symbol),
      maxTempC: group.map((step) => step.temperatureC).reduce(math.max),
      minTempC: group.map((step) => step.temperatureC).reduce(math.min),
      rainMm: rainMm,
      maxWindKmh: group.map((step) => step.windKmh).reduce(math.max),
      rainFromHour: rainMm > 0 ? firstRain?.time.hour : null,
    );
  }

  static WeatherKind _kindOf(String symbol) {
    final name = symbol.split('_').first;
    if (name == 'clearsky' || name == 'fair') return WeatherKind.clear;
    if (name == 'partlycloudy') return WeatherKind.partlyCloudy;
    if (name == 'cloudy' || name == 'fog') return WeatherKind.cloudy;
    return WeatherKind.rain;
  }
}

class _Step {
  const _Step({
    required this.time,
    required this.temperatureC,
    required this.windKmh,
    required this.rainMm,
    this.hourlySymbol,
    this.sixHourSymbol,
  });

  factory _Step.from(Map<String, dynamic> entry) {
    final data = entry['data'] as Map<String, dynamic>;
    final details = (data['instant'] as Map<String, dynamic>)['details'] as Map<String, dynamic>;
    final hour = data['next_1_hours'] as Map<String, dynamic>?;
    final sixHours = data['next_6_hours'] as Map<String, dynamic>?;
    final span = hour ?? sixHours;

    String? symbolOf(Map<String, dynamic>? block) =>
        ((block?['summary'] as Map<String, dynamic>?)?['symbol_code']) as String?;

    final local = DateTime.parse(entry['time'] as String).toLocal();
    return _Step(
      time: DateTime(local.year, local.month, local.day, local.hour),
      temperatureC: (details['air_temperature'] as num).toDouble(),
      windKmh:
          ((details['wind_speed'] as num?)?.toDouble() ?? 0) * MetNoForecastRepository._msToKmh,
      rainMm:
          (((span?['details'] as Map<String, dynamic>?)?['precipitation_amount']) as num?)
              ?.toDouble() ??
          0,
      hourlySymbol: symbolOf(hour),
      sixHourSymbol: symbolOf(sixHours),
    );
  }

  final DateTime time;
  final double temperatureC;
  final double windKmh;
  final double rainMm;
  final String? hourlySymbol;
  final String? sixHourSymbol;
}
