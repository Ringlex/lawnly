import 'dart:math';

import 'package:collection/collection.dart';

class SprinklerCalibration {
  const SprinklerCalibration._({
    required this.averageMm,
    required this.spreadMm,
    required this.minutes,
  });

  static SprinklerCalibration? measure(List<double?> cups, {required int minutes}) {
    final values = cups.whereType<double>().where((mm) => mm > 0).toList();
    if (values.isEmpty || minutes <= 0) return null;
    return SprinklerCalibration._(
      averageMm: values.average,
      spreadMm: values.max - values.min,
      minutes: minutes,
    );
  }

  final double averageMm;

  final double spreadMm;
  final int minutes;

  double get mmPerMinute => averageMm / minutes;

  bool get isEven => spreadMm <= max(1.0, averageMm * 0.25);

  int minutesFor(num targetMm) => (targetMm / mmPerMinute).round();
}
