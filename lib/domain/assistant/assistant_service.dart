import 'package:lawnly/core/l10n/current_l10n.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/data/assistant/assistant_client.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';
import 'package:lawnly/data/assistant/install_id_store.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';

enum LawnProblem { yellowPatches, dryGrass, moss, weeds, bareSpots, fungus, molehills, grubs }

class AssistantService {
  AssistantService({
    required AssistantClient? client,
    required InstallIdStore installIds,
    required CareService careService,
  }) : _client = client,
       _installIds = installIds,
       _careService = careService;

  final AssistantClient? _client;
  final InstallIdStore _installIds;
  final CareService _careService;

  static const _journalEntries = 15;
  static const _pastRainDays = 14;
  static const _forecastDays = 7;

  bool get isAvailable => _client != null;

  TaskEither<AssistantFailure, AssistantQuota> quota() => TaskEither(() async {
    final client = _client;
    if (client == null) return left(AssistantFailure.unknown);
    return client.quota(installId: await _installIds.installId()).run();
  });

  TaskEither<AssistantFailure, WithQuota<Diagnosis>> diagnose({
    required LawnProblem problem,
    required String problemLabel,
    String? description,
    String? since,
    List<XFile> photos = const [],
  }) => TaskEither(() async {
    final client = _client;
    if (client == null) return left(AssistantFailure.unknown);
    return client
        .diagnose(
          installId: await _installIds.installId(),
          context: await _context(),
          problem: problemLabel,
          description: description,
          since: since,
          photos: photos,
        )
        .run();
  });

  TaskEither<AssistantFailure, WithQuota<AssistantAnswer>> ask({
    required String question,
    List<({bool fromUser, String text})> history = const [],
    List<XFile> photos = const [],
  }) => TaskEither(() async {
    final client = _client;
    if (client == null) return left(AssistantFailure.unknown);
    return client
        .ask(
          installId: await _installIds.installId(),
          context: await _context(),
          question: question,
          history: history,
          photos: photos,
        )
        .run();
  });

  TaskEither<AssistantFailure, Unit> report({
    required ReportReason reason,
    required String content,
    required String kind,
    String? note,
  }) => TaskEither(() async {
    final client = _client;
    if (client == null) return left(AssistantFailure.unknown);
    return client
        .report(
          installId: await _installIds.installId(),
          reason: reason,
          content: content,
          kind: kind,
          note: note,
        )
        .run();
  });

  Future<bool> addToCalendar(SuggestedAction action, DateTime date) => _careService.saveTask(
    PlannedTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: action.kind,
      date: CarePlanner.dateOnly(date),
      note: [action.title, action.when].where((t) => t.isNotEmpty).join(' · '),
    ),
  );

  Future<bool> saveToJournal({
    required LawnProblem problem,
    required String note,
    List<XFile> photos = const [],
  }) async {
    final saved = <String>[];
    for (final photo in photos) {
      saved.add(await _careService.savePhoto(photo));
    }
    return _careService.saveJournalEntry(
      JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        kind: JournalKind.observation,
        date: DateTime.now(),
        tags: {?_tagOf(problem)},
        note: note,
        photos: saved,
      ),
    );
  }

  static ObservationTag? _tagOf(LawnProblem problem) => switch (problem) {
    LawnProblem.yellowPatches => ObservationTag.yellowPatches,
    LawnProblem.moss => ObservationTag.moss,
    LawnProblem.weeds => ObservationTag.weeds,
    LawnProblem.bareSpots => ObservationTag.bareSpots,
    LawnProblem.grubs => ObservationTag.grubs,
    LawnProblem.molehills => ObservationTag.molehill,
    LawnProblem.dryGrass || LawnProblem.fungus => null,
  };

  Future<Map<String, dynamic>> _context() async {
    final today = CarePlanner.dateOnly(DateTime.now());
    final profile = (await _careService.profile().run()).toNullable();
    final journal = await _careService.journal().run();
    final weather = (await _careService.weather().run()).toNullable();
    final pastRain =
        (await _careService
                .pastRain(today.subtract(const Duration(days: _pastRainDays)), today)
                .run())
            .toNullable();

    String day(DateTime date) => date.toIso8601String().substring(0, 10);
    String monthDay(int month, int day) =>
        '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    return {
      'language': currentLanguageCode,
      'today': day(today),
      if (profile != null) 'lawn': _lawn(profile, day, monthDay),
      'weather': {
        if (pastRain != null)
          'pastDays': [
            for (final MapEntry(key: date, value: mm) in pastRain.entries)
              {'date': day(date), 'rainMm': mm},
          ],
        if (weather != null)
          'forecast': [
            for (final d in weather.$2.days.take(_forecastDays))
              {
                'date': day(d.date),
                'maxTempC': d.maxTempC,
                'minTempC': ?d.minTempC,
                'rainMm': d.rainMm,
                'rainChance': ?d.rainChance,
              },
          ],
      },
      'journal': [
        for (final entry in journal.take(_journalEntries))
          {'date': day(entry.date), 'title': _journalTitle(entry)},
      ],
    };
  }

  static Map<String, dynamic> _lawn(
    LawnProfile p,
    String Function(DateTime) day,
    String Function(int, int) monthDay,
  ) => {
    'location': ?p.location.label,
    'areaSqm': p.areaSqm,
    'establishedOn': day(p.establishedOn).substring(0, 7),
    'establishment': p.establishment.name,
    'sun': p.sun.name,
    'grassMix': p.grassMix.name,
    'soil': p.soil.name,
    'soilPh': ?p.soilPh,
    'watering': p.watering.name,
    'manualWateringMethod': ?p.manualWateringMethod?.name,
    'mowingIntervalDays': p.mowingIntervalDays,
    'mowingHeightCm': ?p.mowingHeightCm,
    'fertilizingIntervalDays': p.fertilizingIntervalDays,
    if (p.lastFertilizedOn case final d?) 'lastFertilizedOn': day(d),
    if (p.lastMowedOn case final d?) 'lastMowedOn': day(d),
    'seasonStart': monthDay(p.seasonStartMonth, p.seasonStartDay),
    'seasonEnd': monthDay(p.seasonEndMonth, p.seasonEndDay),
  };

  static String _journalTitle(JournalEntry entry) {
    final strings = currentL10n();
    final note = entry.note?.trim();
    final kind = switch (entry.kind) {
      JournalKind.care when entry.careKind != null => strings.careKind(entry.careKind!.name),
      _ => strings.journalKind(entry.kind.name),
    };
    final parts = <String>[
      kind.toLowerCase(),
      for (final tag in entry.tags) strings.observationTag(tag.name).toLowerCase(),
      if (entry.ph case final ph?) 'pH $ph',
      ?entry.product,
      if (entry.npk case final npk?) 'NPK $npk',
      if (note != null && note.isNotEmpty) note,
    ];
    return parts.join(', ');
  }
}
