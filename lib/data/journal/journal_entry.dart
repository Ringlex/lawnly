import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/local/storable.dart';
import 'package:lawnly/data/plan/care_plan.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

enum JournalKind { care, observation, photo, measurement }

enum ObservationTag { moss, weeds, yellowPatches, bareSpots, grubs, molehill }

enum DoseUnit { gramsPerSqm, mlPerSqm }

@freezed
abstract class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required JournalKind kind,
    required DateTime date,
    CareKind? careKind,
    String? note,
    @Default([]) List<String> photos,
    @Default({}) Set<ObservationTag> tags,
    double? ph,
    String? product,
    String? npk,
    double? dose,
    @Default(DoseUnit.gramsPerSqm) DoseUnit doseUnit,
    double? mowingHeightCm,
    int? wateringMinutes,
    double? wateringLitres,
    bool? rainConfirmed,
    int? cycleDay,
    int? interval,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}

@freezed
abstract class Journal with _$Journal implements Storable {
  const factory Journal({@Default([]) List<JournalEntry> entries}) = _Journal;

  factory Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);
}
