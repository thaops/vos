import 'package:get_storage/get_storage.dart';
import 'notification_intent.dart';

class PendingIntentStorage {
  static const _key = 'pending_notification_intent';

  Future<void> _ensureStorageReady() async {
    try {
      await GetStorage.init();
    } catch (_) {}
  }

  Future<void> save(NotificationIntent intent) async {
    await _ensureStorageReady();

    if (intent is TimeOffDetailIntent) {
      await GetStorage().write(_key, {
        'type': 'time_off_detail',
        'vRegId': intent.vRegId,
      });
    }
  }

  Future<NotificationIntent?> consume() async {
    await _ensureStorageReady();

    final data = GetStorage().read<Map<String, dynamic>>(_key);
    if (data == null) return null;

    GetStorage().remove(_key);

    switch (data['type']) {
      case 'time_off_detail':
        final vRegId = data['vRegId'] as int?;
        if (vRegId != null) {
          return TimeOffDetailIntent(vRegId);
        }
    }

    return null;
  }

  Future<bool> hasPending() async {
    await _ensureStorageReady();
    return GetStorage().read(_key) != null;
  }
}
