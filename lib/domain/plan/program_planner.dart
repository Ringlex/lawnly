import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/growing_season.dart';

class ProgramPlanner {
  const ProgramPlanner();

  static const idPrefix = 'program:';

  static bool isProgramTask(PlannedTask task) => task.id.startsWith(idPrefix);

  List<PlannedTask> missingTasks({
    required FertilizerProgram program,
    required int areaSqm,
    required DateTime today,
    required Set<String> existingIds,
  }) {
    final todayDate = CarePlanner.dateOnly(today);
    final tasks = <PlannedTask>[];
    for (final step in program.steps) {
      final year = _nextYear(step, todayDate);
      final id = '$idPrefix${program.id}:${step.id}:$year';
      if (existingIds.contains(id)) continue;
      tasks.add(
        PlannedTask(
          id: id,
          kind: step.kind,
          date: _dateIn(step, year, todayDate),
          flexible: false,
          note: noteOf(step, areaSqm, site: sourceOf(program)?.site),
        ),
      );
    }
    return tasks;
  }

  List<PlannedTask> customTasks({
    required CustomProgram program,
    required int areaSqm,
    required GrowingSeason season,
    required DateTime today,
    required Set<String> existingIds,
  }) {
    final todayDate = CarePlanner.dateOnly(today);
    final seasonStart =
        season.contains(todayDate) ? todayDate : season.startAfter(todayDate);
    final horizon = season.endOf(seasonStart.year);
    final first = CarePlanner.dateOnly(program.startDate);
    final step = ProgramStep(
      id: program.id,
      product: program.product,
      doseFrom: program.doseGramsPerSqm,
      fromMonth: DateTime.january,
      toMonth: DateTime.december,
    );
    final note = noteOf(step, areaSqm);

    final tasks = <PlannedTask>[];
    var date = first;
    while (!date.isAfter(horizon)) {
      final id = '$idPrefix${program.id}:${_stamp(date)}';
      final upcoming = !date.isBefore(todayDate) && !date.isBefore(seasonStart);
      if (upcoming && season.contains(date) && !existingIds.contains(id)) {
        tasks.add(
          PlannedTask(
              id: id,
              kind: CareKind.fertilizing,
              date: date,
              flexible: false,
              note: note),
        );
      }
      date = DateTime(date.year, date.month, date.day + program.intervalDays);
    }
    return tasks;
  }

  static String _stamp(DateTime date) =>
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

  static String noteOf(ProgramStep step, int areaSqm, {String? site}) {
    final parts = [step.product];
    if (step.hasDose) {
      final kilograms =
          (step.dose * areaSqm / 1000).toStringAsFixed(1).replaceAll('.', ',');
      parts.add('${_doseOf(step)} × $areaSqm m² = $kilograms kg');
    }
    final lines = [
      parts.join(' · '),
      if (step.note != null) step.note!,
      if (site != null) 'Źródło: $site',
    ];
    return lines.join('\n');
  }

  static String _doseOf(ProgramStep step) {
    final from = step.doseFrom;
    final to = step.doseTo;
    if (to == null || to == from) return '$from g/m²';
    return '$from–$to g/m² (średnio ${_number(step.dose)})';
  }

  static String _number(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toString().replaceAll('.', ',');

  static int _nextYear(ProgramStep step, DateTime today) {
    final end = DateTime(today.year, step.toMonth + 1, 0);
    return end.isBefore(today) ? today.year + 1 : today.year;
  }

  static DateTime _dateIn(ProgramStep step, int year, DateTime today) {
    final start = DateTime(year, step.fromMonth);
    final end = DateTime(year, step.toMonth + 1, 0);
    final middle = DateTime(
      year,
      start.month,
      start.day + CarePlanner.daysBetween(start, end) ~/ 2,
    );
    return middle.isBefore(today) ? today : middle;
  }
}
