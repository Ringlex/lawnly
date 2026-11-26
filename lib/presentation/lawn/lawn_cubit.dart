import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/journal/season_summary.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/state_type.dart';

part 'lawn_cubit.freezed.dart';

@freezed
abstract class LawnState with _$LawnState {
  const factory LawnState({
    @Default(StateType.loading) StateType type,
    LawnProfile? profile,
    @Default([]) List<JournalEntry> observations,
    JournalEntry? lastPhMeasurement,
  }) = _LawnState;
}

class LawnCubit extends Cubit<LawnState> {
  LawnCubit({required CareService careService, DateTime Function() now = DateTime.now})
    : _careService = careService,
      _now = now,
      super(const LawnState()) {
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

    final summary = SeasonSummary.from(entries: entries, profile: profile, today: _now());
    emit(
      LawnState(
        type: StateType.loaded,
        profile: profile,
        observations: summary.observations,
        lastPhMeasurement: entries.firstWhereOrNull(
          (e) => e.kind == JournalKind.measurement && e.ph != null,
        ),
      ),
    );
  }

  Future<bool> save(LawnProfile profile) => _careService.saveProfile(profile);

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
