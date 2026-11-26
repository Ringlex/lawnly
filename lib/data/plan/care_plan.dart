import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/local/storable.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';

enum CareKind { fertilizing, mowing, watering, aeration, scarification, overseeding, liming, other }

@freezed
abstract class PlannedTask with _$PlannedTask {
  const factory PlannedTask({
    required String id,
    required CareKind kind,
    required DateTime date,
    @Default(true) bool flexible,
    String? note,
    DateTime? doneOn,
  }) = _PlannedTask;

  factory PlannedTask.fromJson(Map<String, dynamic> json) => _$PlannedTaskFromJson(json);

  static const maxShiftDays = 2;
}

@freezed
abstract class CustomProgram with _$CustomProgram {
  const factory CustomProgram({
    required String id,
    required String name,
    required String product,
    required int doseGramsPerSqm,
    required int intervalDays,
    required DateTime startDate,
  }) = _CustomProgram;

  factory CustomProgram.fromJson(Map<String, dynamic> json) => _$CustomProgramFromJson(json);

  static const idPrefix = 'custom:';
}

@freezed
abstract class SkippedEntry with _$SkippedEntry {
  const factory SkippedEntry({required CareKind kind, required DateTime date}) = _SkippedEntry;

  factory SkippedEntry.fromJson(Map<String, dynamic> json) => _$SkippedEntryFromJson(json);
}

@freezed
abstract class CarePlan with _$CarePlan implements Storable {
  const factory CarePlan({
    @Default([]) List<PlannedTask> tasks,
    DateTime? pinnedFertilizingOn,
    @Default([]) List<DateTime> skippedFertilizingOn,
    @Default([]) List<SkippedEntry> skipped,
    String? activeProgramId,
    @Default([]) List<CustomProgram> customPrograms,
  }) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) => _$CarePlanFromJson(json);
}
