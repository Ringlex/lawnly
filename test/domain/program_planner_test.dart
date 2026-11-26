import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/icl_programs.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/growing_season.dart';
import 'package:lawnly/domain/plan/program_planner.dart';

void main() {
  const planner = ProgramPlanner();
  final premium = programById('icl-overseed-premium')!;

  List<PlannedTask> plan(DateTime today, {Set<String> existing = const {}}) =>
      planner.missingTasks(
          program: premium, areaSqm: 250, today: today, existingIds: existing);

  test('liczba nawożeń w programie zgadza się z jego opisem', () {
    const expected = {
      'icl-one': 1,
      'icl-two': 2,
      'icl-three': 3,
      'icl-overseed-eco': 1,
      'icl-overseed-standard': 2,
      'icl-overseed-premium': 3,
      'mgg-four-steps': 4,
      'yara-complex-lawn': 3,
    };

    for (final MapEntry(key: id, value: count) in expected.entries) {
      final fertilizing =
          programById(id)!.steps.where((s) => s.kind == CareKind.fertilizing);

      expect(fertilizing, hasLength(count), reason: id);
    }
  });

  test('katalog zawiera programy ICL z unikalnymi identyfikatorami', () {
    final ids = iclPrograms.programs.map((p) => p.id).toList();

    expect(ids, hasLength(6));
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('program Mr. Green Grass ma cztery kroki z dawką 30–40 g/m²', () {
    final program = programById('mgg-four-steps')!;
    final tasks = planner.missingTasks(
      program: program,
      areaSqm: 200,
      today: DateTime(2026, 2, 1),
      existingIds: const {},
    );

    expect(tasks, hasLength(4));
    expect(
      tasks.first.note,
      startsWith(
        'Nawóz wczesnowiosenny – Szybka regeneracja · 30–40 g/m² (średnio 35) × 200 m² = 7,0 kg',
      ),
    );
    expect(tasks.last.date, DateTime(2026, 10, 16));
  });

  test('program YaraMila ma trzy aplikacje, ostatnią w lipcu', () {
    final tasks = planner.missingTasks(
      program: programById('yara-complex-lawn')!,
      areaSqm: 100,
      today: DateTime(2026, 2, 1),
      existingIds: const {},
    );

    expect(tasks, hasLength(3));
    expect(tasks.last.date.month, DateTime.july);
    expect(
        tasks.first.note,
        startsWith(
            'YaraMila Complex · 25–30 g/m² (średnio 27,5) × 100 m² = 2,8 kg'));
  });

  test('zabiegi w przyszłości lądują w środku okna', () {
    final tasks = plan(DateTime(2026, 2, 1));
    final maintenance =
        tasks.firstWhere((t) => t.id.endsWith(':maintenance:2026'));

    expect(maintenance.date, DateTime(2026, 3, 31));
    expect(maintenance.kind, CareKind.fertilizing);
  });

  test('zabieg z trwającego okna jest planowany na dziś', () {
    final tasks = plan(DateTime(2026, 5, 25));
    final allRound = tasks.firstWhere((t) => t.id.endsWith(':allround:2026'));

    expect(allRound.date, DateTime(2026, 5, 25));
  });

  test('zabieg, którego okno minęło, przechodzi na kolejny rok', () {
    final tasks = plan(DateTime(2026, 10, 30));

    expect(tasks.firstWhere((t) => t.id.endsWith(':maintenance:2027')).date,
        DateTime(2027, 3, 31));
    expect(tasks.where((t) => t.id.endsWith(':prewinter:2026')), isEmpty);
  });

  test('istniejące zabiegi nie są dublowane', () {
    final first = plan(DateTime(2026, 2, 1));
    final again =
        plan(DateTime(2026, 2, 1), existing: {for (final t in first) t.id});

    expect(again, isEmpty);
  });

  test('notatka zawiera produkt, dawkę i ilość dla powierzchni', () {
    final tasks = plan(DateTime(2026, 2, 1));
    final allRound = tasks.firstWhere((t) => t.id.endsWith(':allround:2026'));
    final sowing =
        tasks.firstWhere((t) => t.id.endsWith(':overseed-spring:2026'));

    expect(
      allRound.note,
      startsWith('Landscaper Pro All Round · 45 g/m² × 250 m² = 11,3 kg'),
    );
    expect(allRound.note, endsWith('Źródło: icl-growingsolutions.com'));
    expect(sowing.kind, CareKind.overseeding);
    expect(sowing.note,
        'Dosiewka nasion Landscaper Pro\nŹródło: icl-growingsolutions.com');
  });

  test('zabiegi programu da się odróżnić od własnych zadań', () {
    final task = plan(DateTime(2026, 2, 1)).first;

    expect(ProgramPlanner.isProgramTask(task), isTrue);
    expect(
      ProgramPlanner.isProgramTask(
        PlannedTask(id: '1', kind: CareKind.other, date: DateTime(2026)),
      ),
      isFalse,
    );
  });

  test('zabiegi programu mają stałe terminy', () {
    final tasks = plan(DateTime(2026, 2, 1));

    expect(tasks.every((t) => !t.flexible), isTrue);
  });

  test('własny plan: terminy co N dni w obrębie sezonu, od daty startu', () {
    final custom = CustomProgram(
      id: 'a',
      name: 'Mój',
      product: 'Nawóz X',
      doseGramsPerSqm: 30,
      intervalDays: 30,
      startDate: DateTime(2026, 5, 1),
    );
    final tasks = planner.customTasks(
      program: custom,
      areaSqm: 100,
      season: const GrowingSeason(),
      today: DateTime(2026, 5, 10),
      existingIds: const {},
    );

    expect(tasks.map((t) => t.date), [
      DateTime(2026, 5, 31),
      DateTime(2026, 6, 30),
      DateTime(2026, 7, 30),
      DateTime(2026, 8, 29),
      DateTime(2026, 9, 28),
      DateTime(2026, 10, 28),
    ]);
    expect(tasks.first.note, 'Nawóz X · 30 g/m² × 100 m² = 3,0 kg');
    expect(tasks.every((t) => !t.flexible && ProgramPlanner.isProgramTask(t)),
        isTrue);
  });
}
