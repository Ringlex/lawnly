import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';

typedef LawnListing = ({String id, LawnProfile profile});

class LawnDirectory {
  LawnDirectory._(this._adapter, this._ids, String activeId) : _activeId = ValueNotifier(activeId);

  static const mainId = 'main';
  static const profileKey = 'lawn_profile';
  static const _indexKey = 'lawn_index';

  final StorageAdapter _adapter;
  final List<String> _ids;
  final ValueNotifier<String> _activeId;

  ValueListenable<String> get activeId => _activeId;

  static Future<LawnDirectory> load(StorageAdapter adapter) async {
    try {
      final raw = await adapter.read(key: _indexKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final ids = (json['ids'] as List<dynamic>).cast<String>().toList();
        final active = json['activeId'] as String;
        if (ids.contains(active)) return LawnDirectory._(adapter, ids, active);
      }
    } on Object catch (error) {
      debugPrint('LawnDirectory: $error');
    }
    return LawnDirectory._(adapter, [mainId], mainId);
  }

  String scopedKey(String key, [String? id]) {
    final lawnId = id ?? _activeId.value;
    return lawnId == mainId ? key : '$key:$lawnId';
  }

  Future<List<LawnListing>> lawns() async {
    final result = <LawnListing>[];
    for (final id in _ids) {
      final profile = await _profileOf(id);
      if (profile != null) result.add((id: id, profile: profile));
    }
    return result;
  }

  Future<void> select(String id) async {
    if (!_ids.contains(id) || id == _activeId.value) return;
    await _persist(_ids, id);
    _activeId.value = id;
  }

  Future<void> add(String id, LawnProfile profile) async {
    await _adapter.write(key: scopedKey(profileKey, id), value: jsonEncode(profile.toJson()));
    await _persist([..._ids, id], id);
    _ids.add(id);
    _activeId.value = id;
  }

  Future<LawnProfile?> _profileOf(String id) async {
    try {
      final raw = await _adapter.read(key: scopedKey(profileKey, id));
      return raw == null ? null : LawnProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (error) {
      debugPrint('LawnDirectory: $error');
      return null;
    }
  }

  Future<void> _persist(List<String> ids, String activeId) =>
      _adapter.write(key: _indexKey, value: jsonEncode({'ids': ids, 'activeId': activeId}));
}
