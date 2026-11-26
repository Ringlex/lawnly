import 'package:collection/collection.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/growing_season.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';

class MonthStats {
  const MonthStats({required this.month, required this.mowings, required this.fertilizings});

  final DateTime month;
  final int mowings;
  final int fertilizings;
}

class SeasonSummary {
  const SeasonSummary({
    required this.start,
    required this.end,
    required this.mowings,
    required this.fertilizings,
    required this.waterings,
    required this.months,
    required this.nitrogenRange,
    required this.granularKg,
    required this.liquidLitres,
    required this.observations,
    this.nitrogenPer100Sqm,
    this.wateringMm,
  });

  final DateTime start;

  final DateTime end;
  final int mowings;
  final int fertilizings;
  final int waterings;
  final List<MonthStats> months;

  final double? nitrogenPer100Sqm;

  final (double, double) nitrogenRange;
  final double granularKg;
  final double liquidLitres;

  final double? wateringMm;

  final List<JournalEntry> observations;

  static (DateTime, DateTime) seasonFor(DateTime today, GrowingSeason season) {
    final date = CarePlanner.dateOnly(today);
    final year = date.isBefore(season.startOf(date.year)) ? date.year - 1 : date.year;
    final end = season.endOf(year);
    return (season.startOf(year), date.isBefore(end) ? date : end);
  }

  factory SeasonSummary.from({
    required List<JournalEntry> entries,
    required LawnProfile profile,
    required DateTime today,
  }) {
    final (start, end) = seasonFor(today, profile.season);
    final inSeason = entries.where((e) {
      final date = CarePlanner.dateOnly(e.date);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    List<JournalEntry> care(CareKind kind) =>
        inSeason.where((e) => e.kind == JournalKind.care && e.careKind == kind).toList();
    final mowings = care(CareKind.mowing);
    final fertilizings = care(CareKind.fertilizing);

    final months = [
      for (
        var month = DateTime(start.year, start.month);
        !month.isAfter(end);
        month = DateTime(month.year, month.month + 1)
      )
        MonthStats(
          month: month,
          mowings: mowings.where((e) => _sameMonth(e.date, month)).length,
          fertilizings: fertilizings.where((e) => _sameMonth(e.date, month)).length,
        ),
    ];

    final nitrogenGramsPerSqm = fertilizings
        .map((e) => (e.dose ?? 0) * (nitrogenPercent(e.npk) ?? 0) / 100)
        .sum;
    final hasNitrogen = fertilizings.any((e) => e.dose != null && nitrogenPercent(e.npk) != null);

    double total(DoseUnit unit) => fertilizings
        .where((e) => e.doseUnit == unit)
        .map((e) => (e.dose ?? 0) * profile.areaSqm / 1000)
        .sum;

    final wateringMm = care(
      CareKind.watering,
    ).map((e) => wateringMmOf(e, profile)).whereType<double>().toList();

    return SeasonSummary(
      start: start,
      end: end,
      mowings: mowings.length,
      fertilizings: fertilizings.length,
      waterings: care(CareKind.watering).length,
      wateringMm: wateringMm.isEmpty ? null : wateringMm.sum,
      months: months,
      nitrogenPer100Sqm: hasNitrogen ? nitrogenGramsPerSqm / 10 : null,
      nitrogenRange: nitrogenRangeFor(profile.grassMix),
      granularKg: total(DoseUnit.gramsPerSqm),
      liquidLitres: total(DoseUnit.mlPerSqm),
      observations: inSeason
          .where((e) => e.kind == JournalKind.observation && e.tags.isNotEmpty)
          .sortedBy<DateTime>((e) => e.date)
          .reversed
          .toList(),
    );
  }

  static double? nitrogenPercent(String? npk) {
    final first = npk?.split(RegExp(r'[-–/ ]')).firstOrNull?.replaceAll(',', '.');
    return first == null ? null : double.tryParse(first);
  }

  static (double, double) nitrogenRangeFor(GrassMix mix) => switch (mix) {
    GrassMix.ornamental => (2.0, 3.0),
    GrassMix.sport => (2.5, 3.5),
    GrassMix.shade || GrassMix.drought => (1.0, 2.0),
    GrassMix.universal || GrassMix.unknown => (1.5, 2.5),
  };

  static bool _sameMonth(DateTime date, DateTime month) =>
      date.year == month.year && date.month == month.month;
}
