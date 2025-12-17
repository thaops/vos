import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:vos_flutter/common/services/services.dart';
import 'package:vos_flutter/router/app_router.dart';

class AuthUtils {
  /// ✅ CHỈ check trạng thái login (không navigate)
  static Future<bool> isLoggedIn() async {
    try {
      final service = await Services.create();
      final token = await service.getAccessToken();
      return token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// ⚠️ Legacy API (trước đây vừa check vừa navigate)
  /// Nên migrate dần sang: `isLoggedIn()` và tự điều hướng ở caller.
  @Deprecated('Use isLoggedIn() and handle navigation in caller')
  static Future<void> checkLoginAndNavigate({VoidCallback? onLoggedIn}) async {
    try {
      final service = await Services.create();
      final accessToken = await service.getAccessToken();
      final isLoggedIn = accessToken.isNotEmpty;

      if (isLoggedIn) {
        await Future.delayed(Duration.zero); // Đảm bảo ổn định frame

        onLoggedIn?.call();
      } else {
        if (Get.currentRoute != AppRouter.login) {
          await Get.offAllNamed(AppRouter.login);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// Decode JWT token để lấy payload
  static Map<String, dynamic>? decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode payload (phần thứ 2)
      final payload = parts[1];

      // Thêm padding nếu cần
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error decoding JWT token: $e');
      return null;
    }
  }

  /// Lấy HR_ID từ JWT token
  static int? getHrIdFromToken(String token) {
    try {
      final payload = decodeJwtToken(token);
      if (payload == null) return null;

      // Thử các key có thể có HR_ID
      final hrId =
          payload['HR_ID'] as int? ??
          payload['HRID'] as int? ??
          payload['HrId'] as int? ??
          payload['hrId'] as int?;

      return hrId;
    } catch (e) {
      print('❌ Error getting HR_ID from token: $e');
      return null;
    }
  }
}
