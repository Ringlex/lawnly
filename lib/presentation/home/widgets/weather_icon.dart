import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/weather/day_forecast.dart';

extension WeatherKindIcon on WeatherKind {
  IconData get icon => switch (this) {
    WeatherKind.clear => Icons.wb_sunny_outlined,
    WeatherKind.partlyCloudy => Icons.wb_cloudy_outlined,
    WeatherKind.cloudy => Icons.cloud_outlined,
    WeatherKind.rain => Icons.umbrella_outlined,
  };

  Color colorIn(Palette palette) => switch (this) {
    WeatherKind.clear => palette.sunColor,
    WeatherKind.partlyCloudy => palette.sunColor,
    WeatherKind.cloudy => palette.secondaryTextColor,
    WeatherKind.rain => palette.rainColor,
  };

  IconData iconAt({required bool isDay}) => switch (this) {
    WeatherKind.clear when !isDay => Icons.nightlight_outlined,
    WeatherKind.partlyCloudy when !isDay => Icons.nights_stay_outlined,
    _ => icon,
  };

  Color colorAt(Palette palette, {required bool isDay}) => switch (this) {
    WeatherKind.clear || WeatherKind.partlyCloudy when !isDay => palette.secondaryTextColor,
    _ => colorIn(palette),
  };
}

extension CurrentWeatherIcon on CurrentWeather {
  IconData get icon => kind.iconAt(isDay: isDay);

  Color colorIn(Palette palette) => kind.colorAt(palette, isDay: isDay);
}

extension HourForecastIcon on HourForecast {
  IconData get icon => kind.iconAt(isDay: isDay);

  Color colorIn(Palette palette) => kind.colorAt(palette, isDay: isDay);
}

String formatMm(double mm) => NumberFormat('#0.#').format(mm);

class LiveWeatherIcon extends StatefulWidget {
  const LiveWeatherIcon({required this.icon, required this.color, required this.kind, super.key});

  final IconData icon;
  final Color color;
  final WeatherKind kind;

  @override
  State<LiveWeatherIcon> createState() => _LiveWeatherIconState();
}

class _LiveWeatherIconState extends State<LiveWeatherIcon> with SingleTickerProviderStateMixin {
  static const _period = Duration(milliseconds: 2200);
  static const _maxTurns = 0.03;

  late final _controller = AnimationController(vsync: this, duration: _period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(widget.icon, size: 24, color: widget.color);
    final eased = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    return switch (widget.kind) {
      WeatherKind.clear || WeatherKind.partlyCloudy => RotationTransition(
        turns: Tween(begin: -_maxTurns, end: _maxTurns).animate(eased),
        child: icon,
      ),
      WeatherKind.rain => _RainIcon(color: widget.color, controller: _controller),
      WeatherKind.cloudy => icon,
    };
  }
}

class _RainIcon extends StatelessWidget {
  const _RainIcon({required this.color, required this.controller});

  final Color color;
  final Animation<double> controller;

  static const _size = 24.0;
  static const _drops = 3;
  static const _fall = 6.0;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: _size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.cloud_outlined, size: _size, color: color),
        for (var i = 0; i < _drops; i++)
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final phase = (controller.value + i / _drops) % 1;
              return Positioned(
                left: 6.0 + i * 5,
                top: 15 + phase * _fall,
                child: Opacity(
                  opacity: 1 - phase,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
                    child: const SizedBox(width: 2, height: 5),
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}
