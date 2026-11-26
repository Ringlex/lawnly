import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/local/storable.dart';
import 'package:lawnly/domain/plan/growing_season.dart';

part 'lawn_profile.freezed.dart';
part 'lawn_profile.g.dart';

enum EstablishmentMethod { seeded, sod }

enum SunExposure { sun, partialShade, shade }

enum GrassMix { universal, ornamental, shade, drought, sport, unknown }

enum SoilType { sandy, medium, clay, unknown }

enum WateringMode { automatic, manual }

enum ManualWateringMethod { hoseSprinkler, hose, wateringCan }

enum FertilizerType { liquid, fastGranular, slowGranular }

@freezed
abstract class LawnLocation with _$LawnLocation {
  const factory LawnLocation({required double latitude, required double longitude, String? label}) =
      _LawnLocation;

  factory LawnLocation.fromJson(Map<String, dynamic> json) => _$LawnLocationFromJson(json);
}

@freezed
abstract class LawnProfile with _$LawnProfile implements Storable {
  const LawnProfile._();

  const factory LawnProfile({
    required String name,
    required LawnLocation location,
    required int areaSqm,
    required DateTime establishedOn,
    required EstablishmentMethod establishment,
    required SunExposure sun,
    required GrassMix grassMix,
    required SoilType soil,
    double? soilPh,
    required WateringMode watering,
    int? sprinklerMinutes,
    double? sprinklerMmPerMinute,
    ManualWateringMethod? manualWateringMethod,
    double? sprinklerCoverageSqm,
    double? hoseLitresPerMinute,
    required int mowingIntervalDays,
    double? mowingHeightCm,
    DateTime? lastMowedOn,
    required Set<int> gardenWeekdays,
    @Default(FertilizerType.slowGranular) FertilizerType fertilizer,
    required int fertilizingIntervalDays,
    DateTime? lastFertilizedOn,
    @Default(DateTime.april) int seasonStartMonth,
    @Default(1) int seasonStartDay,
    @Default(DateTime.october) int seasonEndMonth,
    @Default(31) int seasonEndDay,
  }) = _LawnProfile;

  factory LawnProfile.fromJson(Map<String, dynamic> json) => _$LawnProfileFromJson(json);

  GrowingSeason get season => GrowingSeason(
    startMonth: seasonStartMonth,
    startDay: seasonStartDay,
    endMonth: seasonEndMonth,
    endDay: seasonEndDay,
  );
}
