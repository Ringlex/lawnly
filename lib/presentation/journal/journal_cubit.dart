import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/journal/season_summary.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/state_type.dart';

part 'journal_cubit.freezed.dart';

enum JournalFilter { all, fertilizing, mowing, notes, photos }

@freezed
abstract class JournalState with _$JournalState {
  const JournalState._();

  const factory JournalState({
    @Default(StateType.loading) StateType type,
    LawnProfile? profile,
    @Default([]) List<JournalEntry> entries,
    @Default(JournalFilter.all) JournalFilter filter,
    SeasonSummary? summary,
  }) = _JournalState;

  List<JournalEntry> get visible => entries.where(_matches).toList();

  bool _matches(JournalEntry entry) => switch (filter) {
    JournalFilter.all => true,
    JournalFilter.fertilizing => entry.careKind == CareKind.fertilizing,
    JournalFilter.mowing => entry.careKind == CareKind.mowing,
    JournalFilter.notes => entry.kind != JournalKind.care,
    JournalFilter.photos => entry.photos.isNotEmpty,
  };

  JournalEntry? byId(String id) => entries.where((e) => e.id == id).firstOrNull;
}

class JournalCubit extends Cubit<JournalState> {
  JournalCubit({required CareService careService, DateTime Function() now = DateTime.now})
    : _careService = careService,
      _now = now,
      super(const JournalState()) {
    _changes = _careService.changes.listen((_) => load());
  }

  final CareService _careService;
  final DateTime Function() _now;
  late final StreamSubscription<void> _changes;

  Future<void> load() async {
    final profile = (await _careService.profile().run()).toNullable();
    final entries = await _careService.journal().run();
    if (isClosed) return;
    if (profile == null) {
      emit(state.copyWith(type: StateType.error));
      return;
    }

    emit(
      state.copyWith(
        type: StateType.loaded,
        profile: profile,
        entries: entries,
        summary: SeasonSummary.from(entries: entries, profile: profile, today: _now()),
      ),
    );
  }

  void setFilter(JournalFilter filter) => emit(state.copyWith(filter: filter));

  Future<bool> save(JournalEntry entry) => _careService.saveJournalEntry(entry);

  Future<bool> delete(JournalEntry entry) => _careService.deleteJournalEntry(entry);

  Future<bool> confirmRain(JournalEntry entry, {required bool rained}) =>
      _careService.saveJournalEntry(entry.copyWith(rainConfirmed: rained));

  Future<String> savePhoto(XFile photo) => _careService.savePhoto(photo);

  File photoFile(String name) => _careService.photoFile(name);

  Future<Map<DateTime, double>?> rainAfter(DateTime date, {int days = 3}) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(start.year, start.month, start.day + days - 1);
    final result = await _careService.pastRain(start, end).run();
    return result.toNullable();
  }

  Future<double?> seasonRain() async {
    final summary = state.summary;
    if (summary == null) return null;
    final result = await _careService.pastRain(summary.start, summary.end).run();
    return result.toNullable()?.values.fold<double>(0, (sum, mm) => sum + mm);
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
