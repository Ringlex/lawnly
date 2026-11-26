import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';

enum AppLanguage { system, pl, en }

class LanguageController {
  LanguageController._(this._adapter, this._preference, this._deviceLocale)
    : _locale = ValueNotifier(_resolve(_preference, _deviceLocale())) {
    _applyToIntl();
  }

  static const _key = 'app_language';

  final StorageAdapter _adapter;
  final Locale Function() _deviceLocale;
  final ValueNotifier<Locale> _locale;
  AppLanguage _preference;

  ValueListenable<Locale> get locale => _locale;

  AppLanguage get preference => _preference;

  static Future<LanguageController> load(
    StorageAdapter adapter, {
    Locale Function()? deviceLocale,
  }) async {
    String? stored;
    try {
      stored = await adapter.read(key: _key);
    } on Object catch (error) {
      debugPrint('LanguageController: $error');
    }
    return LanguageController._(
      adapter,
      AppLanguage.values.asNameMap()[stored] ?? AppLanguage.system,
      deviceLocale ?? () => WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  Future<void> select(AppLanguage preference) async {
    _preference = preference;
    await _adapter.write(key: _key, value: preference.name);
    _refresh();
  }

  void deviceLocaleChanged() => _refresh();

  void _refresh() {
    final next = _resolve(_preference, _deviceLocale());
    if (next == _locale.value) return;
    Intl.defaultLocale = next.languageCode;
    _locale.value = next;
  }

  void _applyToIntl() => Intl.defaultLocale = _locale.value.languageCode;

  static Locale _resolve(AppLanguage preference, Locale device) => switch (preference) {
    AppLanguage.pl => const Locale('pl'),
    AppLanguage.en => const Locale('en'),
    AppLanguage.system => Locale(device.languageCode == 'pl' ? 'pl' : 'en'),
  };
}
