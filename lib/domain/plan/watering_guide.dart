import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';

const wateringTargetMm = 15;

const wateringCanLitres = 10;

const wateringSessionMinutes = 60;

sealed class WateringGuide {
  const WateringGuide();

  factory WateringGuide.of(LawnProfile profile) {
    final rate = profile.sprinklerMmPerMinute;
    final hasRate = rate != null && rate > 0;

    if (profile.watering == WateringMode.automatic) {
      return hasRate
          ? SectionGuide((wateringTargetMm / rate).round())
          : NoGuide(sectionMinutes: profile.sprinklerMinutes);
    }

    switch (profile.manualWateringMethod) {
      case ManualWateringMethod.hoseSprinkler when hasRate:
        final coverage = profile.sprinklerCoverageSqm;
        return SpotGuide(
          minutesPerSpot: (wateringTargetMm / rate).round(),
          moves: coverage == null || coverage <= 0 ? null : (profile.areaSqm / coverage).ceil(),
        );
      case ManualWateringMethod.hose:
        final flow = profile.hoseLitresPerMinute;
        if (flow == null || flow <= 0) return const NoGuide();
        final total = (wateringTargetMm * profile.areaSqm / flow).round();
        return HoseGuide(
          minutesPerSqm: wateringTargetMm / flow,
          totalMinutes: total,
          sessions: (total / wateringSessionMinutes).ceil(),
        );
      case ManualWateringMethod.wateringCan:
        return CanGuide(
          litresPerSqm: wateringTargetMm.toDouble(),
          cansPerSqm: wateringTargetMm / wateringCanLitres,
          totalLitres: wateringTargetMm * profile.areaSqm,
        );
      default:
        return const NoGuide();
    }
  }
}

final class SectionGuide extends WateringGuide {
  const SectionGuide(this.minutes);

  final int minutes;
}

final class SpotGuide extends WateringGuide {
  const SpotGuide({required this.minutesPerSpot, this.moves});

  final int minutesPerSpot;

  final int? moves;
}

final class HoseGuide extends WateringGuide {
  const HoseGuide({
    required this.minutesPerSqm,
    required this.totalMinutes,
    required this.sessions,
  });

  final double minutesPerSqm;
  final int totalMinutes;

  final int sessions;
}

final class CanGuide extends WateringGuide {
  const CanGuide({required this.litresPerSqm, required this.cansPerSqm, required this.totalLitres});

  final double litresPerSqm;
  final double cansPerSqm;
  final int totalLitres;
}

final class NoGuide extends WateringGuide {
  const NoGuide({this.sectionMinutes});

  final int? sectionMinutes;
}

double? wateringMmOf(JournalEntry entry, LawnProfile profile) {
  if (entry.wateringLitres case final litres?) return litres / profile.areaSqm;

  final minutes = entry.wateringMinutes;
  if (minutes == null) return null;
  final rate = profile.sprinklerMmPerMinute;
  final flow = profile.hoseLitresPerMinute;

  if (profile.watering == WateringMode.automatic ||
      profile.manualWateringMethod == ManualWateringMethod.hoseSprinkler) {
    return rate == null ? null : minutes * rate;
  }
  if (profile.manualWateringMethod == ManualWateringMethod.hose && flow != null) {
    return minutes * flow / profile.areaSqm;
  }
  return null;
}

int? defaultWateringMinutes(LawnProfile profile) => switch (WateringGuide.of(profile)) {
  SectionGuide(:final minutes) => minutes,
  SpotGuide(:final minutesPerSpot) => minutesPerSpot,
  HoseGuide(:final totalMinutes) => totalMinutes,
  NoGuide(:final sectionMinutes) => sectionMinutes,
  CanGuide() => null,
};
