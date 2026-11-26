import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';

import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/journal/journal_repository.dart';
import 'package:lawnly/data/journal/photo_store.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/lawn/lawn_repository.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/plan/plan_repository.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/data/weather/forecast_repository.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/program_planner.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';

enum CareFailure { noProfile, forecast }

class CareSnapshot {
  const CareSnapshot({
    required this.profile,
    required this.plan,
    required this.forecast,
    this.current,
    this.fetchedAt,
  });

  final LawnProfile profile;
  final CarePlan plan;

  final List<DayForecast> forecast;
  final CurrentWeather? current;

  final DateTime? fetchedAt;
}

class CareService {
  CareService({
    required LawnRepository lawnRepository,
    required PlanRepository planRepository,
    required ForecastRepository forecastRepository,
    required JournalRepository journalRepository,
    required PhotoStore photoStore,
  }) : _lawnRepository = lawnRepository,
       _planRepository = planRepository,
       _forecastRepository = forecastRepository,
       _journalRepository = journalRepository,
       _photoStore = photoStore;

  final LawnRepository _lawnRepository;
  final PlanRepository _planRepository;
  final ForecastRepository _forecastRepository;
  final JournalRepository _journalRepository;
  final PhotoStore _photoStore;

  final _changes = StreamController<void>.broadcast();

  static const _programs = ProgramPlanner();

  static const _forecastMaxAge = Duration(minutes: 30);
  ({LawnLocation location, DateTime fetchedAt, WeatherReport report})? _cachedReport;

  static const planningDays = 7;
  static const reportDays = 14;

  Stream<void> get changes => _changes.stream;

  TaskEither<CareFailure, CareSnapshot> load() => TaskEither(() async {
    final profile = (await _lawnRepository.profile().run()).toNullable();
    if (profile == null) return left(CareFailure.noProfile);

    final stored = await _translatedProgramNotes(await _planRepository.plan().run(), profile);
    final plan = await _withProgramTasks(stored, profile);
    final report = await _report(profile.location);
    return report.map(
      (report) => CareSnapshot(
        profile: profile,
        plan: plan,
        forecast: report.days.take(planningDays).toList(),
        current: report.current,
        fetchedAt: _cachedReport?.fetchedAt,
      ),
    );
  });

  TaskEither<CareFailure, (LawnProfile, WeatherReport)> weather() => TaskEither(() async {
    final profile = (await _lawnRepository.profile().run()).toNullable();
    if (profile == null) return left(CareFailure.noProfile);

    final report = await _report(profile.location);
    return report.map((report) => (profile, report));
  });

  Future<bool> complete(CareEntry entry, DateTime today) async {
    if (entry.task case final task?) {
      final saved = await saveTask(task.copyWith(doneOn: CarePlanner.dateOnly(today)));
      if (!saved) return false;
    }
    final updated = await switch (entry.kind) {
      CareKind.fertilizing => markFertilized(today),
      CareKind.mowing => markMowed(today),
      _ => Future.value(true),
    };
    if (!updated) return false;

    final now = DateTime.now();
    final profile = (await _lawnRepository.profile().run()).toNullable();
    final (cycleDay, interval) = switch (entry.advice) {
      FertilizeOn(:final cycleDay, :final interval) => (cycleDay, interval),
      _ => (null, null),
    };
    return _updateJournal(
      (entries) => [
        ...entries,
        JournalEntry(
          id: now.microsecondsSinceEpoch.toString(),
          kind: JournalKind.care,
          careKind: entry.kind,
          date: DateTime(today.year, today.month, today.day, now.hour, now.minute),
          note: entry.task?.note,
          cycleDay: cycleDay,
          interval: interval,
          mowingHeightCm: entry.kind == CareKind.mowing ? profile?.mowingHeightCm : null,
          wateringMinutes: entry.kind == CareKind.watering && profile != null
              ? defaultWateringMinutes(profile)
              : null,
        ),
      ],
    );
  }

  Task<Option<LawnProfile>> profile() => _lawnRepository.profile();

  Task<CarePlan> plan() => _planRepository.plan();

  Future<bool> activateProgram(String id) async {
    final profile = (await _lawnRepository.profile().run()).toNullable();
    if (profile == null) return false;

    return _updatePlan((plan) {
      final kept = plan.tasks.where((t) => !ProgramPlanner.isProgramTask(t) || t.doneOn != null);
      final cleared = plan.copyWith(tasks: kept.toList(), activeProgramId: id);
      return cleared.copyWith(tasks: [...cleared.tasks, ..._missingProgramTasks(cleared, profile)]);
    });
  }

  Future<bool> saveCustomProgram(CustomProgram program) async {
    final plan = await _planRepository.plan().run();
    final wasActive = plan.activeProgramId == '${CustomProgram.idPrefix}${program.id}';
    final saved = await _updatePlan(
      (plan) => plan.copyWith(
        customPrograms: [...plan.customPrograms.where((p) => p.id != program.id), program],
      ),
    );
    if (!saved || !wasActive) return saved;
    return activateProgram(plan.activeProgramId!);
  }

  Future<bool> deleteCustomProgram(String id) async {
    final plan = await _planRepository.plan().run();
    if (plan.activeProgramId == '${CustomProgram.idPrefix}$id') await deactivateProgram();
    return _updatePlan(
      (plan) =>
          plan.copyWith(customPrograms: plan.customPrograms.where((p) => p.id != id).toList()),
    );
  }

  Future<bool> deactivateProgram() => _updatePlan(
    (plan) => plan.copyWith(
      activeProgramId: null,
      tasks: plan.tasks.where((t) => !ProgramPlanner.isProgramTask(t) || t.doneOn != null).toList(),
    ),
  );

  Future<bool> saveProfile(LawnProfile profile) async {
    final saved = await _lawnRepository.save(profile).run();
    return _notifyIf(saved.isRight());
  }

  Task<List<JournalEntry>> journal() => _journalRepository.journal().map(
    (journal) => journal.entries.sortedBy<DateTime>((e) => e.date).reversed.toList(),
  );

  Future<bool> saveJournalEntry(JournalEntry entry) async {
    final saved = await _updateJournal(
      (entries) => [...entries.where((e) => e.id != entry.id), entry],
    );
    if (!saved) return false;

    final date = CarePlanner.dateOnly(entry.date);
    bool isNewer(DateTime? last) => last == null || date.isAfter(last);
    return switch (entry) {
      JournalEntry(kind: JournalKind.measurement, :final ph?) => _updateProfile(
        (profile) => profile.copyWith(soilPh: ph),
      ),
      JournalEntry(kind: JournalKind.care, careKind: CareKind.fertilizing) => _updateProfile(
        (profile) =>
            isNewer(profile.lastFertilizedOn) ? profile.copyWith(lastFertilizedOn: date) : profile,
      ),
      JournalEntry(kind: JournalKind.care, careKind: CareKind.mowing) => _updateProfile(
        (profile) => isNewer(profile.lastMowedOn) ? profile.copyWith(lastMowedOn: date) : profile,
      ),
      _ => Future.value(true),
    };
  }

  Future<bool> deleteJournalEntry(JournalEntry entry) async {
    final saved = await _updateJournal(
      (entries) => entries.where((e) => e.id != entry.id).toList(),
    );
    if (saved) {
      for (final photo in entry.photos) {
        await _photoStore.delete(photo);
      }
    }
    return saved;
  }

  Future<String> savePhoto(XFile photo) => _photoStore.save(photo);

  File photoFile(String name) => _photoStore.fileOf(name);

  TaskEither<CareFailure, Map<DateTime, double>> pastRain(DateTime start, DateTime end) =>
      TaskEither(() async {
        final profile = (await _lawnRepository.profile().run()).toNullable();
        if (profile == null) return left(CareFailure.noProfile);

        final today = CarePlanner.dateOnly(DateTime.now());
        final last = end.isAfter(today) ? today : end;
        if (last.isBefore(start)) return right(const {});

        final result = await _forecastRepository
            .pastRain(profile.location, start: start, end: last)
            .run();
        return result.mapLeft((_) => CareFailure.forecast);
      });

  Future<bool> markFertilized(DateTime today) async {
    final date = CarePlanner.dateOnly(today);
    final saved = await _updateProfile((profile) => profile.copyWith(lastFertilizedOn: date));
    if (!saved) return false;

    return _updatePlan(
      (plan) => plan.copyWith(
        pinnedFertilizingOn: null,
        skippedFertilizingOn: plan.skippedFertilizingOn.where((d) => d.isAfter(date)).toList(),
      ),
    );
  }

  Future<bool> markMowed(DateTime today) =>
      _updateProfile((profile) => profile.copyWith(lastMowedOn: CarePlanner.dateOnly(today)));

  Future<bool> pinFertilizing(DateTime? date) => _updatePlan(
    (plan) => plan.copyWith(pinnedFertilizingOn: date == null ? null : CarePlanner.dateOnly(date)),
  );

  Future<bool> skipFertilizingCycle(DateTime nominal) => _updatePlan(
    (plan) => plan.copyWith(
      pinnedFertilizingOn: null,
      skippedFertilizingOn: [...plan.skippedFertilizingOn, CarePlanner.dateOnly(nominal)],
    ),
  );

  Future<bool> restoreFertilizingCycle(DateTime nominal) => _updatePlan(
    (plan) => plan.copyWith(
      skippedFertilizingOn: plan.skippedFertilizingOn
          .where((d) => d != CarePlanner.dateOnly(nominal))
          .toList(),
    ),
  );

  Future<bool> skipEntry(CareKind kind, DateTime date) => _updatePlan(
    (plan) => plan.copyWith(
      skipped: [
        ...plan.skipped,
        SkippedEntry(kind: kind, date: CarePlanner.dateOnly(date)),
      ],
    ),
  );

  Future<bool> restoreEntry(CareKind kind, DateTime date) {
    final entry = SkippedEntry(kind: kind, date: CarePlanner.dateOnly(date));
    return _updatePlan(
      (plan) => plan.copyWith(skipped: plan.skipped.where((s) => s != entry).toList()),
    );
  }

  Future<bool> saveTask(PlannedTask task) => _updatePlan((plan) {
    final others = plan.tasks.where((t) => t.id != task.id);
    return plan.copyWith(tasks: [...others, task]);
  });

  Future<bool> deleteTask(String id) =>
      _updatePlan((plan) => plan.copyWith(tasks: plan.tasks.where((t) => t.id != id).toList()));

  void refresh() => _changes.add(null);

  Future<void> dispose() => _changes.close();

  List<PlannedTask> _missingProgramTasks(CarePlan plan, LawnProfile profile) {
    final id = plan.activeProgramId;
    if (id == null) return const [];

    final existingIds = {for (final t in plan.tasks) t.id};
    if (id.startsWith(CustomProgram.idPrefix)) {
      final custom = plan.customPrograms.firstWhereOrNull(
        (p) => '${CustomProgram.idPrefix}${p.id}' == id,
      );
      if (custom == null) return const [];
      return _programs.customTasks(
        program: custom,
        areaSqm: profile.areaSqm,
        season: profile.season,
        today: DateTime.now(),
        existingIds: existingIds,
      );
    }

    final program = programById(id);
    if (program == null) return const [];
    return _programs.missingTasks(
      program: program,
      areaSqm: profile.areaSqm,
      today: DateTime.now(),
      existingIds: existingIds,
    );
  }

  Future<CarePlan> _translatedProgramNotes(CarePlan plan, LawnProfile profile) async {
    final program = programById(plan.activeProgramId);
    if (program == null) return plan;

    final tasks = _programs.translatedNotes(
      program: program,
      areaSqm: profile.areaSqm,
      tasks: plan.tasks,
    );
    if (const ListEquality<PlannedTask>().equals(tasks, plan.tasks)) return plan;

    final updated = plan.copyWith(tasks: tasks);
    final saved = await _planRepository.save(updated).run();
    return saved.isRight() ? updated : plan;
  }

  Future<CarePlan> _withProgramTasks(CarePlan plan, LawnProfile profile) async {
    final missing = _missingProgramTasks(plan, profile);
    if (missing.isEmpty) return plan;

    final updated = plan.copyWith(tasks: [...plan.tasks, ...missing]);
    final saved = await _planRepository.save(updated).run();
    return saved.isRight() ? updated : plan;
  }

  Future<Either<CareFailure, WeatherReport>> _report(LawnLocation location) async {
    final cached = _cachedReport;
    if (cached != null &&
        cached.location == location &&
        DateTime.now().difference(cached.fetchedAt) < _forecastMaxAge) {
      return right(cached.report);
    }

    final result = await _forecastRepository.report(location, days: reportDays).run();
    return result.match(
      (_) => cached?.location == location ? right(cached!.report) : left(CareFailure.forecast),
      (report) {
        _cachedReport = (location: location, fetchedAt: DateTime.now(), report: report);
        return right(report);
      },
    );
  }

  Future<bool> _updateProfile(LawnProfile Function(LawnProfile profile) change) async {
    final profile = (await _lawnRepository.profile().run()).toNullable();
    if (profile == null) return false;

    final saved = await _lawnRepository.save(change(profile)).run();
    return _notifyIf(saved.isRight());
  }

  Future<bool> _updateJournal(
    List<JournalEntry> Function(List<JournalEntry> entries) change,
  ) async {
    final journal = await _journalRepository.journal().run();
    final saved = await _journalRepository
        .save(journal.copyWith(entries: change(journal.entries)))
        .run();
    return _notifyIf(saved.isRight());
  }

  Future<bool> _updatePlan(CarePlan Function(CarePlan plan) change) async {
    final plan = await _planRepository.plan().run();
    final saved = await _planRepository.save(change(plan)).run();
    return _notifyIf(saved.isRight());
  }

  bool _notifyIf(bool saved) {
    if (saved) _changes.add(null);
    return saved;
  }
}
