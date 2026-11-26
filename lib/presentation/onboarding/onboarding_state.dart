import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';

part 'onboarding_state.freezed.dart';

enum OnboardingStatus { editing, locating, saving, done }

enum OnboardingError {
  locationServiceDisabled,
  locationPermissionDenied,
  cityNotFound,
  network,
  save,
}

@freezed
abstract class OnboardingDraft with _$OnboardingDraft {
  const OnboardingDraft._();

  const factory OnboardingDraft({
    @Default('') String name,
    LawnLocation? location,
    @Default('') String cityQuery,
    int? areaSqm,
    DateTime? establishedOn,
    @Default(EstablishmentMethod.seeded) EstablishmentMethod establishment,
    @Default(SunExposure.sun) SunExposure sun,
    GrassMix? grassMix,
    SoilType? soil,
    double? soilPh,
    @Default(false) bool soilPhInvalid,
    @Default(WateringMode.automatic) WateringMode watering,
    @Default(20) int sprinklerMinutes,
    @Default(5) int mowingIntervalDays,
    DateTime? lastMowedOn,
    @Default({DateTime.saturday, DateTime.sunday}) Set<int> gardenWeekdays,
    @Default(15) int fertilizingIntervalDays,
    DateTime? lastFertilizedOn,
    @Default(false) bool lastFertilizedUnknown,
  }) = _OnboardingDraft;

  bool isStepComplete(int step) => switch (step) {
    0 => name.trim().isNotEmpty && (location != null || cityQuery.trim().isNotEmpty),
    1 => (areaSqm ?? 0) > 0 && establishedOn != null,
    2 => !soilPhInvalid,
    3 => gardenWeekdays.isNotEmpty && sprinklerMinutes > 0,
    _ => true,
  };

  LawnProfile toProfile() => LawnProfile(
    name: name.trim(),
    location: location!,
    areaSqm: areaSqm!,
    establishedOn: establishedOn!,
    establishment: establishment,
    sun: sun,
    grassMix: grassMix ?? GrassMix.unknown,
    soil: soil ?? SoilType.unknown,
    soilPh: soilPh,
    watering: watering,
    sprinklerMinutes: watering == WateringMode.automatic ? sprinklerMinutes : null,
    mowingIntervalDays: mowingIntervalDays,
    lastMowedOn: lastMowedOn,
    gardenWeekdays: gardenWeekdays,
    fertilizingIntervalDays: fertilizingIntervalDays,
    lastFertilizedOn: lastFertilizedUnknown ? null : lastFertilizedOn,
  );
}

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int step,
    @Default(OnboardingDraft()) OnboardingDraft draft,
    @Default(OnboardingStatus.editing) OnboardingStatus status,
    OnboardingError? error,
  }) = _OnboardingState;
}
