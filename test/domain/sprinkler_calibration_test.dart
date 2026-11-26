import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/domain/plan/sprinkler_calibration.dart';

void main() {
  test('średnio 9 mm w 15 minut to 0,6 mm na minutę, 15 mm w 25 minut', () {
    final result = SprinklerCalibration.measure([9, 8, 10, 9], minutes: 15)!;

    expect(result.averageMm, 9);
    expect(result.mmPerMinute, closeTo(0.6, 1e-9));
    expect(result.minutesFor(15), 25);
    expect(result.spreadMm, 2);
    expect(result.isEven, isTrue);
  });

  test('duże różnice między kubkami to nierówne podlewanie', () {
    final result = SprinklerCalibration.measure([4, 12, 9, 10], minutes: 15)!;

    expect(result.isEven, isFalse);
  });

  test('puste kubki są pomijane, bez żadnego wyniku nie ma kalibracji', () {
    expect(SprinklerCalibration.measure([null, 6, null, 0], minutes: 10)!.averageMm, 6);
    expect(SprinklerCalibration.measure([null, null], minutes: 10), isNull);
  });
}
