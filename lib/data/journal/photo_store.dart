import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class PhotoStore {
  PhotoStore._(this._directory);

  static Future<PhotoStore> create() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/journal_photos');
    await directory.create(recursive: true);
    return PhotoStore._(directory);
  }

  final Directory _directory;

  Future<String> save(XFile photo) async {
    final extension = photo.path.contains('.') ? photo.path.split('.').last : 'jpg';
    final name = '${DateTime.now().microsecondsSinceEpoch}.$extension';
    await photo.saveTo('${_directory.path}/$name');
    return name;
  }

  File fileOf(String name) => File('${_directory.path}/$name');

  Future<void> delete(String name) async {
    try {
      final file = fileOf(name);
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (error, stackTrace) {
      logWarning('PhotoStore: nie udało się usunąć $name', error, stackTrace);
    }
  }
}
