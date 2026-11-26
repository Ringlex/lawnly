enum WeatherKind { clear, partlyCloudy, cloudy, rain }

class DayForecast {
  const DayForecast({
    required this.date,
    required this.kind,
    required this.maxTempC,
    required this.rainMm,
    required this.maxWindKmh,
    this.rainFromHour,
    this.rainChance,
    this.minTempC,
  });

  final DateTime date;
  final WeatherKind kind;
  final double maxTempC;
  final double rainMm;
  final double maxWindKmh;

  final int? rainFromHour;

  final int? rainChance;

  final double? minTempC;
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperatureC,
    required this.kind,
    required this.windKmh,
    this.isDay = true,
  });

  final double temperatureC;
  final WeatherKind kind;
  final double windKmh;

  final bool isDay;
}

class HourForecast {
  const HourForecast({
    required this.time,
    required this.kind,
    required this.temperatureC,
    required this.rainMm,
    required this.windKmh,
    this.rainChance,
    this.isDay = true,
  });

  final DateTime time;
  final WeatherKind kind;
  final double temperatureC;
  final double rainMm;
  final double windKmh;
  final int? rainChance;
  final bool isDay;
}

class WeatherReport {
  const WeatherReport({required this.days, this.current, this.hours = const []});

  final CurrentWeather? current;

  final List<DayForecast> days;

  final List<HourForecast> hours;

  List<HourForecast> hoursOn(DateTime date) => [
    for (final hour in hours)
      if (hour.time.year == date.year && hour.time.month == date.month && hour.time.day == date.day)
        hour,
  ];
}
