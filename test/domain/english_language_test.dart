import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/current_l10n.dart';
import 'package:lawnly/core/l10n/language_controller.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/program_planner.dart';

class _MemoryStorage extends StorageAdapter {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async => values[key] = value;

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}

void main() {
  const planner = ProgramPlanner();
  final program = programById('mgg-four-steps')!;

  tearDown(() => Intl.defaultLocale = null);

  List<PlannedTask> tasks() => planner.missingTasks(
    program: program,
    areaSqm: 100,
    today: DateTime(2026, 2, 1),
    existingIds: const {},
  );

  test('język telefonu inny niż polski daje angielski', () async {
    final controller = await LanguageController.load(
      _MemoryStorage(),
      deviceLocale: () => const Locale('de'),
    );

    expect(controller.locale.value, const Locale('en'));
    expect(currentL10n().navToday, 'Today');
  });

  test('ręczny wybór języka wygrywa z telefonem i zostaje zapisany', () async {
    final storage = _MemoryStorage();
    final controller = await LanguageController.load(
      storage,
      deviceLocale: () => const Locale('pl'),
    );

    await controller.select(AppLanguage.en);
    final reloaded = await LanguageController.load(storage, deviceLocale: () => const Locale('pl'));

    expect(reloaded.preference, AppLanguage.en);
    expect(reloaded.locale.value, const Locale('en'));
  });

  test('notatka programu po angielsku ma kropkę dziesiętną i angielskie opisy', () {
    Intl.defaultLocale = 'en';

    final note = tasks().first.note!;

    expect(note, contains('30–40 g/m² (average 35) × 100 m² = 3.5 kg'));
    expect(note, contains('Source: mrgreengrass.pl'));
    expect(note, contains('After mowing to 5 cm'));
  });

  test('po zmianie języka tłumaczone są tylko niezmienione notatki', () {
    Intl.defaultLocale = 'pl';
    final polish = tasks();
    final edited = polish[1].copyWith(note: 'moja notatka');
    final done = polish[2].copyWith(doneOn: DateTime(2026, 7, 1));
    Intl.defaultLocale = 'en';

    final translated = planner.translatedNotes(
      program: program,
      areaSqm: 100,
      tasks: [polish[0], edited, done],
    );

    expect(translated[0].note, contains('Source: mrgreengrass.pl'));
    expect(translated[1].note, 'moja notatka');
    expect(translated[2].note, done.note);
  });

  test('każdy program ma angielską nazwę i opis bez polskich znaków', () {
    final polishLetters = RegExp('[ąćęłńóśźż]', caseSensitive: false);

    for (final source in programSources) {
      for (final program in source.programs) {
        expect(program.name.en, isNot(contains(polishLetters)), reason: program.id);
        expect(program.summary.en, isNot(contains(polishLetters)), reason: program.id);
        for (final step in program.steps) {
          expect(step.note?.en ?? '', isNot(contains(polishLetters)), reason: step.id);
        }
      }
    }
  });
}
