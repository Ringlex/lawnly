import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';

class LawnScopedStorageAdapter extends StorageAdapter {
  const LawnScopedStorageAdapter({required StorageAdapter adapter, required LawnDirectory lawns})
    : _adapter = adapter,
      _lawns = lawns;

  final StorageAdapter _adapter;
  final LawnDirectory _lawns;

  @override
  Future<String?> read({required String key}) => _adapter.read(key: _lawns.scopedKey(key));

  @override
  Future<void> write({required String key, required String value}) =>
      _adapter.write(key: _lawns.scopedKey(key), value: value);

  @override
  Future<void> delete({required String key}) => _adapter.delete(key: _lawns.scopedKey(key));
}
