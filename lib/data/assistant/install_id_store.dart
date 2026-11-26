import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class InstallIdStore {
  const InstallIdStore({required SharedPreferences preferences}) : _preferences = preferences;

  final SharedPreferences _preferences;

  static const _key = 'assistant.installId';

  Future<String> installId() async {
    final stored = _preferences.getString(_key);
    if (stored != null) return stored;

    final random = Random.secure();
    final id = List.generate(32, (_) => random.nextInt(16).toRadixString(16)).join();
    await _preferences.setString(_key, id);
    return id;
  }
}
