import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/notifications/notification_planner.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';

class _MemoryAdapter extends StorageAdapter {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async => values[key] = value;

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}

class _FakeGateway extends NotificationGateway {
  List<PlannedNotification> last = const [];

  @override
  Stream<String> get selections => const Stream.empty();

  @override
  Future<String?> launchPayload() async => null;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceAll(List<PlannedNotification> notifications) async => last = notifications;
}

void main() {
  final now = DateTime(2026, 5, 10, 12);
  late _FakeGateway gateway;
  late NotificationScheduler scheduler;

  CalendarPlan fertilizingOn(DateTime date) => CalendarPlan(
    entries: [CareEntry(kind: CareKind.fertilizing, date: date, certainty: EntryCertainty.matched)],
    windows: const [],
  );

  setUp(() async {
    final adapter = _MemoryAdapter();
    gateway = _FakeGateway();
    scheduler = NotificationScheduler(
      gateway: gateway,
      prefs: NotificationPrefsRepository(adapter: adapter),
      state: NotificationStateRepository(adapter: adapter),
      now: () => now,
    );
    await scheduler.update(const NotificationPrefs(enabled: true));
  });

  test('przesunięcie nawożenia w ciągu 3 dni daje powiadomienie o zmianie planu', () async {
    await scheduler.reschedule(calendar: fertilizingOn(DateTime(2026, 5, 14)), forecast: const []);
    await scheduler.reschedule(calendar: fertilizingOn(DateTime(2026, 5, 12)), forecast: const []);

    final ids = gateway.last.map((n) => n.id);

    expect(ids, contains(NotificationScheduler.planChangeId));
  });

  test('pierwsze zaplanowanie nawożenia nie jest zmianą planu', () async {
    await scheduler.reschedule(calendar: fertilizingOn(DateTime(2026, 5, 12)), forecast: const []);

    final ids = gateway.last.map((n) => n.id);

    expect(ids, isNot(contains(NotificationScheduler.planChangeId)));
  });

  test('poza sezonem planowane jest jedno powiadomienie na start sezonu', () async {
    await scheduler.reschedule(
      calendar: const CalendarPlan(entries: [], windows: []),
      forecast: const [],
      seasonStartsOn: DateTime(2027, 3, 15),
    );

    final notification = gateway.last.single;

    expect(notification.id, NotificationScheduler.seasonStartId);
    expect(notification.at, DateTime(2027, 3, 15, NotificationPrefs.defaultMorningHour));
  });
}
