import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:vos_flutter/common/services/notification_handler.dart';
import 'package:vos_flutter/common/services/push_token_manager.dart';

class OneSignalService {
  static const String _appId = "810ec89b-1b22-4e8c-969d-1fc0520e918a";
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  bool _initialized = false;
  bool _listenerRegistered = false;

  final PushTokenManager _tokenManager = PushTokenManager();
  final NotificationHandler _notificationHandler = NotificationHandler();

  Future<void> init() async {
    if (_initialized) return;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_appId);

    if (!_listenerRegistered) {
      OneSignal.Notifications.addClickListener(
        _notificationHandler.handleNotificationClick,
      );
      _listenerRegistered = true;
    }

    OneSignal.Notifications.lifecycleInit();

    _initialized = true;

    _setupUserTags();
    _requestPermission();
    OneSignal.User.pushSubscription.optIn();
  }

  void _setupUserTags() {
    Future.microtask(() async {
      try {
        await OneSignal.User.addTagWithKey("test_user", "true");
        await OneSignal.User.addTags({"test_user": "true"});
      } catch (_) {}
    });
  }

  void _requestPermission() {
    Future.microtask(() async {
      try {
        if (!OneSignal.Notifications.permission) {
          await OneSignal.Notifications.requestPermission(true);
        }
      } catch (_) {}
    });
  }

  Future<void> checkPermissionStatus() async {
    if (!OneSignal.Notifications.permission) {
      await OneSignal.Notifications.requestPermission(true);
    }
  }

  Future<void> listenForPushToken() async {
    await _tokenManager.listenForToken();
  }

  Future<String?> getPushToken() async {
    return _tokenManager.getPushToken();
  }

  Future<void> registerPushTokenToBackend(String token) async {
    await _tokenManager.registerTokenToBackend(token);
  }

  static Future<void> clearCachedToken() async {
    await PushTokenManager.clearCache();
  }
}
