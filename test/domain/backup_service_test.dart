import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/core/l10n/language_controller.dart';
import 'package:lawnly/data/backup/backup_codec.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/journal/photo_store.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/domain/backup/backup_service.dart';
import 'package:lawnly/domain/notifications/notification_planner.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _MemoryStorage extends StorageAdapter {
  final values = <String, String>{};
  String? failingKey;

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    if (key == failingKey) {
      failingKey = null;
      throw const FileSystemException('disk full');
    }
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}

class _Gateway extends NotificationGateway {
  _Gateway({required this.granted});

  final bool granted;

  @override
  Stream<String> get selections => const Stream.empty();

  @override
  Future<String?> launchPayload() async => null;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> replaceAll(List<PlannedNotification> notifications) async {}
}

class _Paths extends PathProviderPlatform {
  _Paths(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

typedef _Phone = ({
  _MemoryStorage storage,
  LawnDirectory lawns,
  PhotoStore photos,
  LanguageController language,
  BackupService service,
});

LawnProfile _profile(String name) => OnboardingDraft(
  name: name,
  location: const LawnLocation(latitude: 52.2, longitude: 21.0, label: 'Warszawa'),
  areaSqm: 250,
  establishedOn: DateTime(2022, 4),
).toProfile();

String _journalWith(List<String> photos) => jsonEncode(
  Journal(
    entries: [
      JournalEntry(id: '1', kind: JournalKind.photo, date: DateTime(2026, 5), photos: photos),
    ],
  ).toJson(),
);

Future<_Phone> _phone({bool notificationsGranted = true}) async {
  final directory = await Directory.systemTemp.createTemp('lawnly_backup');
  addTearDown(() => directory.delete(recursive: true));
  PathProviderPlatform.instance = _Paths(directory.path);

  final storage = _MemoryStorage();
  final lawns = await LawnDirectory.load(storage);
  final photos = await PhotoStore.create();
  final language = await LanguageController.load(storage, deviceLocale: () => const Locale('pl'));
  final service = BackupService(
    storage: storage,
    lawns: lawns,
    photos: photos,
    language: language,
    notifications: NotificationScheduler(
      gateway: _Gateway(granted: notificationsGranted),
      prefs: NotificationPrefsRepository(adapter: storage),
      state: NotificationStateRepository(adapter: storage),
    ),
    now: () => DateTime(2026, 5, 14),
  );
  return (storage: storage, lawns: lawns, photos: photos, language: language, service: service);
}

Future<Uint8List> _backupWithTwoLawns() async {
  final phone = await _phone();
  await phone.lawns.add('42', _profile('Za domem'));
  phone.storage.values
    ..['lawn_profile'] = jsonEncode(_profile('Przed domem').toJson())
    ..['lawn_index'] = jsonEncode({
      'ids': ['main', '42'],
      'activeId': '42',
    })
    ..['journal:42'] = _journalWith(['100.jpg', 'missing.jpg'])
    ..['notification_prefs'] = jsonEncode(const NotificationPrefs(enabled: true).toJson())
    ..['assistant.installId'] = 'secret';
  await phone.lawns.reload();
  await phone.language.select(AppLanguage.en);
  await phone.photos.write('100.jpg', Uint8List.fromList([1, 2, 3]));
  return phone.service.export();
}

Uint8List _zip(Map<String, String> files) {
  final archive = Archive();
  for (final MapEntry(:key, :value) in files.entries) {
    archive.addFile(ArchiveFile.bytes(key, utf8.encode(value)));
  }
  return ZipEncoder().encodeBytes(archive);
}

String _manifest(Map<String, String> values, {int version = BackupCodec.version}) => jsonEncode({
  'format': 'lawnly-backup',
  'version': version,
  'createdAt': DateTime(2026, 5, 14).toIso8601String(),
  'values': values,
});

Matcher _fails(BackupFailure failure) =>
    throwsA(isA<BackupException>().having((e) => e.failure, 'failure', failure));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores lawns, journal, photos and settings on another phone', () async {
    final bytes = await _backupWithTwoLawns();
    final phone = await _phone();

    final data = await phone.service.open(bytes);
    expect(phone.service.summaryOf(data).lawns, 2);
    expect(phone.service.summaryOf(data).photos, 1);

    await phone.service.restore(data);

    expect((await phone.lawns.lawns()).map((l) => l.profile.name), ['Przed domem', 'Za domem']);
    expect(phone.lawns.activeId.value, '42');
    expect(phone.language.preference, AppLanguage.en);
    expect(await phone.photos.fileOf('100.jpg').readAsBytes(), [1, 2, 3]);
    expect(phone.storage.values, contains('journal:42'));
    expect(phone.storage.values, isNot(contains('assistant.installId')));
  });

  test('replaces existing data and removes photos that are no longer used', () async {
    final bytes = await _backupWithTwoLawns();
    final phone = await _phone();
    await phone.lawns.add('7', _profile('Stary'));
    phone.storage.values
      ..['journal:7'] = _journalWith(['old.jpg'])
      ..['assistant.installId'] = 'mine';
    await phone.photos.write('old.jpg', Uint8List.fromList([9]));

    await phone.service.restore(await phone.service.open(bytes));

    expect(phone.storage.values, isNot(contains('lawn_profile:7')));
    expect(phone.storage.values, isNot(contains('journal:7')));
    expect(phone.storage.values['assistant.installId'], 'mine');
    expect(await phone.photos.fileOf('old.jpg').exists(), isFalse);
  });

  test('keeps the previous data when saving fails', () async {
    final bytes = await _backupWithTwoLawns();
    final phone = await _phone();
    await phone.lawns.add('7', _profile('Stary'));
    final before = Map.of(phone.storage.values);
    final data = await phone.service.open(bytes);
    phone.storage.failingKey = 'journal:42';

    await expectLater(phone.service.restore(data), _fails(BackupFailure.storage));

    expect(phone.storage.values, before);
    expect(await phone.photos.fileOf('100.jpg').exists(), isFalse);
  });

  test('turns notifications off when the new phone refuses permission', () async {
    final bytes = await _backupWithTwoLawns();
    final phone = await _phone(notificationsGranted: false);

    await phone.service.restore(await phone.service.open(bytes));

    final prefs = await NotificationPrefsRepository(adapter: phone.storage).load();
    expect(prefs.enabled, isFalse);
  });

  test('rejects files that are not valid backups', () async {
    final phone = await _phone();
    final index = jsonEncode({
      'ids': ['main'],
      'activeId': 'main',
    });

    for (final bytes in [
      Uint8List.fromList(utf8.encode('not a zip')),
      _zip({'other.txt': 'x'}),
      _zip({
        'backup.json': _manifest({'lawn_index': index}),
      }),
      _zip({
        'backup.json': _manifest({'lawn_index': index, 'lawn_profile': '{"broken":true}'}),
      }),
      _zip({
        'backup.json': _manifest({
          'lawn_index': index,
          'lawn_profile': jsonEncode(_profile('A').toJson()),
          'assistant.installId': 'injected',
        }),
      }),
    ]) {
      await expectLater(phone.service.open(bytes), _fails(BackupFailure.invalidFile));
    }
  });

  test('rejects a backup from a newer app version', () async {
    final phone = await _phone();

    await expectLater(
      phone.service.open(_zip({'backup.json': _manifest({}, version: 99)})),
      _fails(BackupFailure.newerVersion),
    );
  });

  test('ignores photo names that point outside the photo folder', () {
    final data = BackupCodec.decode(
      _zip({'backup.json': _manifest({}), 'photos/../evil.jpg': 'x', 'photos/ok.jpg': 'y'}),
    );

    expect(data.photos.keys, ['ok.jpg']);
  });

  test('has nothing to export before the first lawn exists', () async {
    final phone = await _phone();

    await expectLater(phone.service.export(), _fails(BackupFailure.nothingToExport));
  });
}
