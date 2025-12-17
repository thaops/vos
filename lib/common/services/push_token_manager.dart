import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:vos_flutter/core/network/api_endpoints.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/common/services/device_info_helper.dart';

/// Quản lý push token: lấy token, lưu trữ, và đăng ký với backend
class PushTokenManager {
  static const String _storageKeyLastToken = 'last_push_token';
  static String? _sentToken;
  final GetStorage _storage = GetStorage();

  /// Lấy push token từ OneSignal
  Future<String?> getPushToken() async {
    final status = OneSignal.User.pushSubscription;
    debugPrint(
      "getPushToken: optedIn=${status.optedIn}, id=${status.id}",
    );
    return status.id;
  }

  /// Đăng ký token với backend (chỉ gửi nếu token mới)
  Future<void> registerTokenToBackend(String token) async {
    if (_isTokenAlreadySent(token)) return;

    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceUUID = const Uuid().v4();

      final data = {
        "deviceUUID": deviceUUID,
        "pushToken": token,
        "devicePlatform": deviceInfo['platform'],
        "deviceOS": deviceInfo['osVersion'],
        "deviceModel": deviceInfo['deviceName'],
        "deviceName": deviceInfo['deviceName'],
        "appBuild": packageInfo.buildNumber,
        "appVersion": packageInfo.version,
        "appLanguage": "vi-VN",
      };

      final dio = DioApi();
      await dio.post(ApiEndpoints.notification, data: data);

      _markTokenAsSent(token);
      debugPrint("✅ Token đã được đăng ký thành công");
    } catch (e) {
      debugPrint("❌ Gửi token thất bại: $e");
    }
  }

  /// Lắng nghe token changes và tự động đăng ký
  Future<void> listenForToken() async {
    // Thử lấy token ngay lập tức (retry 3 lần)
    for (int i = 0; i < 3; i++) {
      final token = await getPushToken();
      if (token != null) {
        await registerTokenToBackend(token);
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    }

    // Lắng nghe token changes
    OneSignal.User.pushSubscription.addObserver((state) {
      if (state.current.id != null && state.current.optedIn) {
        registerTokenToBackend(state.current.id!);
      }
    });
  }

  /// Kiểm tra token đã được gửi chưa
  bool _isTokenAlreadySent(String token) {
    if (_sentToken == token) {
      debugPrint("Token đã được gửi, bỏ qua");
      return true;
    }

    final lastToken = _storage.read<String>(_storageKeyLastToken);
    if (lastToken == token) {
      debugPrint("Token đã được lưu trước đây, bỏ qua");
      _sentToken = token;
      return true;
    }

    return false;
  }

  /// Đánh dấu token đã được gửi
  void _markTokenAsSent(String token) {
    _sentToken = token;
    _storage.write(_storageKeyLastToken, token);
  }

  /// Xóa cache token
  static Future<void> clearCache() async {
    _sentToken = null;
    final box = GetStorage();
    await box.remove(_storageKeyLastToken);
  }
}

