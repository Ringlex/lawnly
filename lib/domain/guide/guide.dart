import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

enum GuideTopic {
  scarification(best: {4, 5}, possible: {8, 9}, kind: CareKind.scarification),
  aeration(best: {4, 5, 9}, possible: {10}, kind: CareKind.aeration),
  raking(best: {3, 4}, possible: {10, 11}, kind: CareKind.other),
  overseeding(best: {8, 9}, possible: {4, 5}, kind: CareKind.overseeding),
  sanding(best: {4, 5, 9}, possible: {}, kind: CareKind.other),
  liming(best: {10, 11}, possible: {3}, kind: CareKind.liming);

  const GuideTopic({required this.best, required this.possible, required this.kind});

  final Set<int> best;

  final Set<int> possible;

  final CareKind kind;

  bool goodIn(int month) => best.contains(month) || possible.contains(month);

  int? minAgeMonths(EstablishmentMethod method) => switch (this) {
    GuideTopic.scarification => method == EstablishmentMethod.sod ? 12 : 24,
    GuideTopic.aeration => 12,
    _ => null,
  };

  DateTime? readyOn(LawnProfile profile) {
    final months = minAgeMonths(profile.establishment);
    if (months == null) return null;
    final established = profile.establishedOn;
    return DateTime(established.year, established.month + months);
  }

  bool tooYoung(LawnProfile? profile, DateTime today) {
    final ready = profile == null ? null : readyOn(profile);
    return ready != null && CarePlanner.dateOnly(today).isBefore(ready);
  }

  bool goodNow(LawnProfile? profile, DateTime today) =>
      goodIn(today.month) && !tooYoung(profile, today);

  DateTime planDate(DateTime today, {LawnProfile? profile}) {
    final date = CarePlanner.dateOnly(today);
    if (goodNow(profile, date)) return date;

    final ready = profile == null ? null : readyOn(profile);
    final from = ready != null && ready.isAfter(date) ? ready : date;
    for (var offset = 0; offset <= 12; offset++) {
      final month = DateTime(from.year, from.month + offset);
      if (best.contains(month.month) && month.isAfter(date)) return month;
    }
    return from;
  }
}

GuideTopic? ageLimitedTopic(CareKind kind) => switch (kind) {
  CareKind.scarification => GuideTopic.scarification,
  CareKind.aeration => GuideTopic.aeration,
  _ => null,
};

const guideOrder = [
  GuideTopic.scarification,
  GuideTopic.aeration,
  GuideTopic.sanding,
  GuideTopic.overseeding,
  GuideTopic.raking,
  GuideTopic.liming,
];

typedef MonthRange = ({int from, int to});

bool inRange(MonthRange range, int month) => month >= range.from && month <= range.to;

const fertilizingSeasons = <MonthRange>[
  (from: 3, to: 4),
  (from: 5, to: 6),
  (from: 7, to: 8),
  (from: 9, to: 10),
];

const mowingSeasons = <MonthRange>[
  (from: 4, to: 4),
  (from: 5, to: 6),
  (from: 7, to: 8),
  (from: 9, to: 11),
];

({double min, double max}) mowingRange(GrassMix mix) => switch (mix) {
  GrassMix.universal || GrassMix.unknown => (min: 4, max: 5),
  GrassMix.ornamental => (min: 2.5, max: 4),
  GrassMix.shade => (min: 5, max: 6),
  GrassMix.drought => (min: 5, max: 7),
  GrassMix.sport => (min: 3.5, max: 5),
};

double mowingHeight(LawnProfile profile) {
  if (profile.mowingHeightCm case final height?) return height;
  return switch (profile.grassMix) {
    GrassMix.ornamental => 3.5,
    GrassMix.shade || GrassMix.drought => 6,
    GrassMix.sport => 4.5,
    GrassMix.universal || GrassMix.unknown => 5,
  };
}

double mowWhenTaller(double height) => height * 1.5;
