import 'package:flutter/foundation.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';

class LawnService {
  const LawnService({
    required LawnDirectory directory,
    required NotificationScheduler notifications,
  }) : _directory = directory,
       _notifications = notifications;

  final LawnDirectory _directory;
  final NotificationScheduler _notifications;

  ValueListenable<String> get activeId => _directory.activeId;

  Future<List<LawnListing>> lawns() => _directory.lawns();

  Future<void> select(String id) async {
    if (id == activeId.value) return;
    await _notifications.forgetPlan();
    await _directory.select(id);
  }

  Future<bool> add(LawnProfile profile) async {
    try {
      await _notifications.forgetPlan();
      await _directory.add(DateTime.now().microsecondsSinceEpoch.toString(), profile);
      return true;
    } on Object catch (error) {
      debugPrint('LawnService: $error');
      return false;
    }
  }
}
