import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract class BackupFileGateway {
  const BackupFileGateway();

  Future<bool> save({required String fileName, required Uint8List bytes});

  Future<Uint8List?> pick();
}

class SystemBackupFileGateway extends BackupFileGateway {
  const SystemBackupFileGateway();

  @override
  Future<bool> save({required String fileName, required Uint8List bytes}) async =>
      await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: 'application/zip') !=
      null;

  @override
  Future<Uint8List?> pick() async => (await FilePicker.pickFile())?.readAsBytes();
}
