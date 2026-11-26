import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lawnly/core/fpdarts.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/local/storable.dart';

enum SingleValueStoreFailure { fatal, notFound }

class SingleValueStore<T extends Storable> {
  const SingleValueStore({
    required StorageAdapter adapter,
    required String key,
    required T Function(Map<String, dynamic> json) fromJson,
    bool removeWhenInvalid = true,
  }) : assert(null is! T),
       _adapter = adapter,
       _key = key,
       _fromJson = fromJson,
       _removeWhenInvalid = removeWhenInvalid;

  final StorageAdapter _adapter;

  final String _key;

  final T Function(Map<String, dynamic> json) _fromJson;

  final bool _removeWhenInvalid;

  TaskEither<SingleValueStoreFailure, Unit> write({required T value}) =>
      tryCatchE<SingleValueStoreFailure, Unit>(() async {
        await _adapter.write(key: _key, value: jsonEncode(value.toJson()));
        return right(unit);
      }, (_, _) => SingleValueStoreFailure.fatal);

  TaskEither<SingleValueStoreFailure, T> read() => tryCatchE<SingleValueStoreFailure, T>(
    () async {
      final value = await _adapter.read(key: _key);
      if (value == null) {
        return left(SingleValueStoreFailure.notFound);
      }
      return right(_fromJson(jsonDecode(value) as Map<String, dynamic>));
    },
    (_, _) => SingleValueStoreFailure.fatal,
    onErrorRun: () async {
      if (_removeWhenInvalid) {
        await delete().run();
      }
    },
  );

  TaskEither<SingleValueStoreFailure, Unit> delete() =>
      tryCatchE<SingleValueStoreFailure, Unit>(() async {
        await _adapter.delete(key: _key);
        return right(unit);
      }, (_, _) => SingleValueStoreFailure.fatal);
}
