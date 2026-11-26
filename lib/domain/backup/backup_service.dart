import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:lawnly/core/l10n/language_controller.dart';
import 'package:lawnly/data/backup/backup_codec.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/journal/journal_repository.dart';
import 'package:lawnly/data/journal/photo_store.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/plan/plan_repository.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';

typedef BackupSummary = ({DateTime createdAt, int lawns, int photos});

class BackupService {
  const BackupService({
    required StorageAdapter storage,
    required LawnDirectory lawns,
    required PhotoStore photos,
    required LanguageController language,
    required NotificationScheduler notifications,
    DateTime Function() now = DateTime.now,
  }) : _storage = storage,
       _lawns = lawns,
       _photos = photos,
       _language = language,
       _notifications = notifications,
       _now = now;

  final StorageAdapter _storage;
  final LawnDirectory _lawns;
  final PhotoStore _photos;
  final LanguageController _language;
  final NotificationScheduler _notifications;
  final DateTime Function() _now;

  static final _lawnId = RegExp('^(${LawnDirectory.mainId}|[0-9]+)\$');

  static const _globalKeys = [
    NotificationPrefsRepository.storageKey,
    LanguageController.storageKey,
  ];

  static final Map<String, void Function(Map<String, dynamic>)> _lawnParsers = {
    LawnDirectory.profileKey: LawnProfile.fromJson,
    PlanRepository.storageKey: CarePlan.fromJson,
    JournalRepository.storageKey: Journal.fromJson,
  };

  String fileName() => 'lawnly-backup-${_now().toIso8601String().substring(0, 10)}.zip';

  Future<Uint8List> export() async {
    final values = await _read(_allKeys(_lawns.ids));
    values.removeWhere((key, value) => !_isReadable(key, value));
    if (!values.keys.any(_isProfileKey)) {
      throw const BackupException(BackupFailure.nothingToExport);
    }
    values[LawnDirectory.indexKey] = jsonEncode({
      'ids': _lawns.ids,
      'activeId': _lawns.activeId.value,
    });

    final data = BackupData(
      createdAt: _now(),
      values: values,
      photos: await _readPhotos(_photoNames(values)),
    );
    return Isolate.run(() => BackupCodec.encode(data));
  }

  Future<BackupData> open(Uint8List bytes) async {
    final data = await Isolate.run(() => BackupCodec.decode(bytes));
    _validate(data);
    return data;
  }

  BackupSummary summaryOf(BackupData data) => (
    createdAt: data.createdAt,
    lawns: data.values.keys.where(_isProfileKey).length,
    photos: data.photos.length,
  );

  Future<void> restore(BackupData data) async {
    _validate(data);
    final keys = {..._allKeys(_lawns.ids), ..._allKeys(_idsOf(data.values))};
    final previous = await _read(keys);
    final added = <String>[];

    try {
      await _writePhotos(data.photos, added);
      await _replace(keys, data.values);
    } catch (error, stackTrace) {
      logWarning('BackupService: restore failed', error, stackTrace);
      await _replace(keys, previous);
      await _deletePhotos(added);
      throw const BackupException(BackupFailure.storage);
    }

    await _deletePhotos(_photoNames(previous).difference(_photoNames(data.values)));
    await _reload();
  }

  Future<void> _reload() async {
    await _notifications.forgetPlan();
    await _lawns.reload();
    await _language.reload();
    await _notifications.confirmPermission();
  }

  void _validate(BackupData data) {
    try {
      final index = jsonDecode(data.values[LawnDirectory.indexKey]!) as Map<String, dynamic>;
      final ids = _idsOf(data.values);
      final activeId = index['activeId'] as String;
      final valid =
          ids.every(_lawnId.hasMatch) &&
          ids.contains(activeId) &&
          data.values.containsKey(_lawns.scopedKey(LawnDirectory.profileKey, activeId)) &&
          data.values.keys.every(_allKeys(ids).contains) &&
          data.values.entries.every((entry) => _isReadable(entry.key, entry.value));
      if (valid) return;
    } catch (error, stackTrace) {
      logWarning('BackupService: invalid backup', error, stackTrace);
    }
    throw const BackupException(BackupFailure.invalidFile);
  }

  static List<String> _idsOf(Map<String, String> values) {
    final index = jsonDecode(values[LawnDirectory.indexKey]!) as Map<String, dynamic>;
    return (index['ids'] as List<dynamic>).cast<String>().toList();
  }

  Set<String> _allKeys(List<String> ids) => {
    for (final id in ids)
      for (final key in _lawnParsers.keys) _lawns.scopedKey(key, id),
    ..._globalKeys,
    LawnDirectory.indexKey,
  };

  static String _baseKey(String key) => key.split(':').first;

  static bool _isProfileKey(String key) => _baseKey(key) == LawnDirectory.profileKey;

  static bool _isReadable(String key, String value) {
    try {
      if (key == LanguageController.storageKey) return true;
      final json = jsonDecode(value) as Map<String, dynamic>;
      _lawnParsers[_baseKey(key)]?.call(json);
      if (key == NotificationPrefsRepository.storageKey) NotificationPrefs.fromJson(json);
      return true;
    } catch (error) {
      logWarning('BackupService: unreadable value $key', error);
      return false;
    }
  }

  static Set<String> _photoNames(Map<String, String> values) => {
    for (final MapEntry(:key, :value) in values.entries)
      if (_baseKey(key) == JournalRepository.storageKey && _isReadable(key, value))
        for (final entry in Journal.fromJson(jsonDecode(value) as Map<String, dynamic>).entries)
          ...entry.photos.where(BackupCodec.isSafePhotoName),
  };

  Future<Map<String, String>> _read(Set<String> keys) async => {
    for (final key in keys) key: ?await _storage.read(key: key),
  };

  Future<void> _replace(Set<String> keys, Map<String, String> values) async {
    for (final key in keys) {
      final value = values[key];
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    }
  }

  Future<Map<String, Uint8List>> _readPhotos(Set<String> names) async => {
    for (final name in names)
      if (await _photos.fileOf(name).exists()) name: await _photos.fileOf(name).readAsBytes(),
  };

  Future<void> _writePhotos(Map<String, Uint8List> photos, List<String> added) async {
    for (final MapEntry(key: name, value: bytes) in photos.entries) {
      if (!await _photos.fileOf(name).exists()) added.add(name);
      await _photos.write(name, bytes);
    }
  }

  Future<void> _deletePhotos(Iterable<String> names) async {
    for (final name in names) {
      await _photos.delete(name);
    }
  }
}
