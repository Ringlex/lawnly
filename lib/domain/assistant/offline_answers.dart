import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/domain/plan/care_planner.dart';

const _scarificationWindows = [
  ((month: 4, day: 15), (month: 5, day: 31)),
  ((month: 8, day: 15), (month: 9, day: 15)),
];

({bool now, DateTime? next, bool tooYoung}) scarificationAdvice(
  DateTime today, {
  LawnProfile? profile,
}) {
  final date = CarePlanner.dateOnly(today);
  final ready = profile == null ? null : GuideTopic.scarification.readyOn(profile);
  final tooYoung = ready != null && date.isBefore(ready);
  final from = tooYoung ? ready : date;
  DateTime at(int year, ({int month, int day}) point) => DateTime(year, point.month, point.day);

  if (!tooYoung) {
    for (final (start, end) in _scarificationWindows) {
      if (!date.isBefore(at(date.year, start)) && !date.isAfter(at(date.year, end))) {
        return (now: true, next: null, tooYoung: false);
      }
    }
  }

  final upcoming = [
    for (final year in [from.year, from.year + 1])
      for (final (start, end) in _scarificationWindows)
        if (!at(year, end).isBefore(from)) at(year, start).isBefore(from) ? from : at(year, start),
  ].where((start) => start.isAfter(date)).toList()..sort();
  return (now: false, next: upcoming.first, tooYoung: tooYoung);
}
