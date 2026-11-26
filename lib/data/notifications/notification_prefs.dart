import 'dart:convert';

import 'package:lawnly/data/local/adapter/storage_adapter.dart';

class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = false,
    this.fertilizing = true,
    this.watering = true,
    this.care = true,
    this.warnings = true,
    this.morningHour = defaultMorningHour,
  });

  static const defaultMorningHour = 7;
  static const quietFromHour = 21;
  static const quietUntilHour = 7;

  final bool enabled;
  final bool fertilizing;
  final bool watering;
  final bool care;
  final bool warnings;
  final int morningHour;

  NotificationPrefs copyWith({
    bool? enabled,
    bool? fertilizing,
    bool? watering,
    bool? care,
    bool? warnings,
    int? morningHour,
  }) => NotificationPrefs(
    enabled: enabled ?? this.enabled,
    fertilizing: fertilizing ?? this.fertilizing,
    watering: watering ?? this.watering,
    care: care ?? this.care,
    warnings: warnings ?? this.warnings,
    morningHour: morningHour ?? this.morningHour,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'fertilizing': fertilizing,
    'watering': watering,
    'care': care,
    'warnings': warnings,
    'morningHour': morningHour,
  };

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    const defaults = NotificationPrefs();
    bool flag(String key, bool fallback) => json[key] as bool? ?? fallback;
    final hour = json['morningHour'] as int? ?? defaultMorningHour;

    return NotificationPrefs(
      enabled: flag('enabled', defaults.enabled),
      fertilizing: flag('fertilizing', defaults.fertilizing),
      watering: flag('watering', defaults.watering),
      care: flag('care', defaults.care),
      warnings: flag('warnings', defaults.warnings),
      morningHour: hour.clamp(quietUntilHour, quietFromHour - 1),
    );
  }
}

class NotificationPrefsRepository {
  const NotificationPrefsRepository({required StorageAdapter adapter}) : _adapter = adapter;

  final StorageAdapter _adapter;

  static const storageKey = 'notification_prefs';

  Future<NotificationPrefs> load() async {
    try {
      final raw = await _adapter.read(key: storageKey);
      if (raw == null) return const NotificationPrefs();
      return NotificationPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const NotificationPrefs();
    }
  }

  Future<void> save(NotificationPrefs prefs) =>
      _adapter.write(key: storageKey, value: jsonEncode(prefs.toJson()));
}

class NotificationState {
  const NotificationState({this.baselineFertilizingOn, this.pendingMoveTo, this.pendingMoveAt});

  final DateTime? baselineFertilizingOn;
  final DateTime? pendingMoveTo;
  final DateTime? pendingMoveAt;

  Map<String, dynamic> toJson() => {
    'baselineFertilizingOn': baselineFertilizingOn?.toIso8601String(),
    'pendingMoveTo': pendingMoveTo?.toIso8601String(),
    'pendingMoveAt': pendingMoveAt?.toIso8601String(),
  };

  factory NotificationState.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) => DateTime.tryParse(json[key] as String? ?? '');
    return NotificationState(
      baselineFertilizingOn: date('baselineFertilizingOn'),
      pendingMoveTo: date('pendingMoveTo'),
      pendingMoveAt: date('pendingMoveAt'),
    );
  }
}

class NotificationStateRepository {
  const NotificationStateRepository({required StorageAdapter adapter}) : _adapter = adapter;

  final StorageAdapter _adapter;

  static const _key = 'notification_state';

  Future<NotificationState> load() async {
    try {
      final raw = await _adapter.read(key: _key);
      if (raw == null) return const NotificationState();
      return NotificationState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const NotificationState();
    }
  }

  Future<void> save(NotificationState state) =>
      _adapter.write(key: _key, value: jsonEncode(state.toJson()));
}
