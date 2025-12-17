import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/constants/storage_keys.dart';
import 'package:vos_flutter/common/utils/auth_utils.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';

class NotificationHandler {
  bool _isHandling = false;

  Future<void> handleNotificationClick(OSNotificationClickEvent event) async {
    if (_isHandling) {
      debugPrint("⚠️ Notification đang được xử lý, bỏ qua");
      return;
    }

    _isHandling = true;
    debugPrint("🔔 Notification clicked: ${event.notification.additionalData}");

    try {
      final jsonContent = event.notification.additionalData?["JsonContent"];
      debugPrint("jsonContent: $jsonContent");
      if (jsonContent == null) {
        _isHandling = false;
        return;
      }

      final requestNumber = _extractRequestNumber(jsonContent);
      debugPrint("requestNumber: $requestNumber");
      if (requestNumber == null) {
        _isHandling = false;
        return;
      }

      final vRegId = int.tryParse(requestNumber);
      if (vRegId == null) {
        debugPrint("Không thể parse request_number: $requestNumber");
        _isHandling = false;
        return;
      }

      await _navigateToTimeOffDetail(vRegId);
    } catch (e) {
      debugPrint("Lỗi khi xử lý notification: $e");
    } finally {
      Future.delayed(Duration(seconds: 1), () {
        _isHandling = false;
      });
    }
  }

  String? _extractRequestNumber(dynamic jsonContent) {
    try {
      Map<String, dynamic>? jsonData;

      if (jsonContent is String) {
        jsonData = jsonDecode(jsonContent) as Map<String, dynamic>?;
      } else if (jsonContent is Map) {
        jsonData = jsonContent as Map<String, dynamic>?;
      }

      if (jsonData == null) return null;

      final customData = jsonData["custom_data"];
      if (customData is! Map) return null;

      return customData["REQUEST_NUMBER:"]?.toString() ??
          customData["request_number:"]?.toString() ??
          customData["REQUEST_NUMBER"]?.toString() ??
          customData["request_number"]?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> _navigateToTimeOffDetail(int vRegId) async {
    debugPrint("✅ Điều hướng timeOffDetail với vRegId: $vRegId");

    // ✅ Lưu pending để MainScreen xử lý (tránh race với SplashController)
    GetStorage().write(StorageKeys.pendingTimeOffDetailVRegId, vRegId);

    final loggedIn = await AuthUtils.isLoggedIn();
    if (!loggedIn) {
      debugPrint("❌ Chưa login → về login (giữ pending vRegId=$vRegId)");
      if (Get.currentRoute != AppRouter.login) {
        await Get.offAllNamed(AppRouter.login);
      }
      return;
    }

    // Đảm bảo app vào main trước (SplashController đôi khi sẽ offAllNamed main)
    if (Get.currentRoute != AppRouter.main) {
      await Get.offAllNamed(AppRouter.main);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Nếu main đã sẵn sàng, có thể điều hướng ngay (hoặc để MainScreen consume)
    if (Get.currentRoute == AppRouter.timeOffDetail) {
      debugPrint("⚠️ Đã ở detail screen, bỏ qua navigation");
      return;
    }

    await Get.toNamed(
      AppRouter.timeOffDetail,
      arguments: TimeOffDetailArgs(vRegId: vRegId),
      preventDuplicates: true,
    );

    // consume pending vì đã navigate thành công
    GetStorage().remove(StorageKeys.pendingTimeOffDetailVRegId);
    debugPrint("✅ Đã điều hướng detail thành công (vRegId=$vRegId)");
  }
}
