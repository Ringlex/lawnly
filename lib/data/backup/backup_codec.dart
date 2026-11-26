import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

enum BackupFailure { invalidFile, newerVersion, nothingToExport, storage }

class BackupException implements Exception {
  const BackupException(this.failure);

  final BackupFailure failure;

  @override
  String toString() => 'BackupException(${failure.name})';
}

class BackupData {
  const BackupData({required this.createdAt, required this.values, required this.photos});

  final DateTime createdAt;
  final Map<String, String> values;
  final Map<String, Uint8List> photos;
}

abstract final class BackupCodec {
  static const version = 1;
  static const _format = 'lawnly-backup';
  static const _manifestName = 'backup.json';
  static const _photoFolder = 'photos/';
  static final _safePhotoName = RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9]+$');

  static bool isSafePhotoName(String name) => _safePhotoName.hasMatch(name);

  static Uint8List encode(BackupData data) {
    final manifest = utf8.encode(
      jsonEncode({
        'format': _format,
        'version': version,
        'createdAt': data.createdAt.toIso8601String(),
        'values': data.values,
      }),
    );
    final archive = Archive()..addFile(ArchiveFile.bytes(_manifestName, manifest));
    for (final MapEntry(key: name, value: bytes) in data.photos.entries) {
      archive.addFile(ArchiveFile.noCompress('$_photoFolder$name', bytes.length, bytes));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  static BackupData decode(Uint8List bytes) {
    try {
      return _decode(ZipDecoder().decodeBytes(bytes, verify: true));
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupFailure.invalidFile);
    }
  }

  static BackupData _decode(Archive archive) {
    final manifestBytes = archive.findFile(_manifestName)?.readBytes();
    if (manifestBytes == null) throw const BackupException(BackupFailure.invalidFile);

    final manifest = jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
    if (manifest['format'] != _format) throw const BackupException(BackupFailure.invalidFile);
    if (manifest['version'] as int > version) {
      throw const BackupException(BackupFailure.newerVersion);
    }

    final photos = <String, Uint8List>{};
    for (final file in archive.files) {
      if (!file.isFile || !file.name.startsWith(_photoFolder)) continue;
      final name = file.name.substring(_photoFolder.length);
      final content = file.readBytes();
      if (isSafePhotoName(name) && content != null) photos[name] = content;
    }

    return BackupData(
      createdAt: DateTime.parse(manifest['createdAt'] as String),
      values: (manifest['values'] as Map<String, dynamic>).cast<String, String>(),
      photos: photos,
    );
  }
}
