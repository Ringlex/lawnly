import 'package:flutter/widgets.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';
import 'package:lawnly/presentation/common/text_utils.dart';

String wateringHint(BuildContext context, LawnProfile profile) {
  final strings = context.strings;
  return switch (WateringGuide.of(profile)) {
    SectionGuide(:final minutes) => strings.homeWateringCalibrated(
      minutes,
      formatDecimal(wateringTargetMm),
    ),
    SpotGuide(:final minutesPerSpot, :final moves?) => strings.homeWateringMoves(
      minutesPerSpot,
      moves,
    ),
    SpotGuide(:final minutesPerSpot) => strings.homeWateringSpot(minutesPerSpot),
    HoseGuide(:final minutesPerSqm, :final totalMinutes, :final sessions) => [
      strings.homeWateringHose(formatDecimal(minutesPerSqm), durationText(context, totalMinutes)),
      if (sessions > 1) strings.homeWateringInParts(sessions),
    ].join(' '),
    CanGuide(:final litresPerSqm, :final cansPerSqm) => strings.homeWateringCan(
      formatDecimal(litresPerSqm),
      formatDecimal(cansPerSqm),
      wateringCanLitres,
    ),
    NoGuide(:final sectionMinutes?) => strings.homeWateringAuto(sectionMinutes),
    NoGuide() => strings.homeWateringManual(wateringTargetMm),
  };
}

String durationText(BuildContext context, int minutes) {
  final strings = context.strings;
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return strings.durationMinutes(minutes);
  return rest == 0 ? strings.durationHours(hours) : strings.durationHoursMinutes(hours, rest);
}
