import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:vos_flutter/common/services/notification_handler.dart';
import 'package:vos_flutter/common/services/push_token_manager.dart';

class OneSignalService {
  static const String _appId = "810ec89b-1b22-4e8c-969d-1fc0520e918a";
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static OSNotificationClickEvent? _cachedClickEvent;
  static bool _notificationHandled = false;
  bool _initialized = false;
  bool _listenerRegistered = false;

  final PushTokenManager _tokenManager = PushTokenManager();
  final NotificationHandler _notificationHandler = NotificationHandler();

  /// Khởi tạo OneSignal service
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_appId);

    await _setupUserTags();
    await _requestPermission();
    await OneSignal.User.pushSubscription.optIn();

    OneSignal.Notifications.lifecycleInit();

    // Chỉ đăng ký listener một lần để tránh duplicate
    if (!_listenerRegistered) {
      OneSignal.Notifications.addClickListener(
        _notificationHandler.handleNotificationClick,
      );
      _listenerRegistered = true;
    }
  }

  Future<void> _setupUserTags() async {
    await OneSignal.User.addTagWithKey("test_user", "true");
    await OneSignal.User.addTags({"test_user": "true"});
  }

  Future<void> _requestPermission() async {
    if (!OneSignal.Notifications.permission) {
      await OneSignal.Notifications.requestPermission(true);
    }
  }

  Future<void> handlePendingNavigation() async {
    if (!_notificationHandled && _cachedClickEvent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 500));
        await _notificationHandler.handleNotificationClick(_cachedClickEvent!);
        _cachedClickEvent = null;
        _notificationHandled = true;
      });
    }
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
