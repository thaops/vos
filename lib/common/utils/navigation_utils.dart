import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/constants/storage_keys.dart';
import 'package:vos_flutter/common/utils/auth_utils.dart';
import 'package:vos_flutter/common/utils/notification_utils.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';

class NavigationUtils {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateByNotificationType({
    required NotificationType type,
    required String id,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      final context = navigatorKey.currentContext;
      if (context == null) {
        print(
          "❌ Navigator context is null! Retrying ($retryCount/$maxRetries)",
        );
        retryCount++;
        await Future.delayed(Duration(milliseconds: 500));
        continue;
      }

      final routeInfo = _getRouteInfo(type, id);
      print("🚀 Navigating to: ${routeInfo.route} with id: $id");

      try {
        final loggedIn = await AuthUtils.isLoggedIn();
        if (!loggedIn) {
          // Lưu pending nếu là timeOffDetail
          if (routeInfo.route == AppRouter.timeOffDetail &&
              routeInfo.arguments is TimeOffDetailArgs) {
            final args = routeInfo.arguments as TimeOffDetailArgs;
            GetStorage().write(
              StorageKeys.pendingTimeOffDetailVRegId,
              args.vRegId,
            );
          }
          await Get.offAllNamed(AppRouter.login);
          return;
        }

        // Ensure main trước khi đi sâu
        if (Get.currentRoute != AppRouter.main) {
          await Get.offAllNamed(AppRouter.main);
          await Future.delayed(const Duration(milliseconds: 300));
        }

        await Get.toNamed(
          routeInfo.route,
          arguments: routeInfo.arguments,
          preventDuplicates: true,
        );
        return;
      } catch (e) {
        print("❌ Navigation error: $e");
        return;
      }
    }
    print("❌ Failed to navigate after $maxRetries retries");
  }

  static ({String route, dynamic arguments}) _getRouteInfo(
    NotificationType type,
    String id,
  ) {
    switch (type) {
      case NotificationType.leaveRequest:
        // Parse id từ string sang int và điều hướng trực tiếp đến detail
        final vRegId = int.tryParse(id);
        if (vRegId != null) {
          return (
            route: AppRouter.timeOffDetail,
            arguments: TimeOffDetailArgs(vRegId: vRegId),
          );
        } else {
          print("❌ Không thể parse id thành int: $id");
          return (route: AppRouter.main, arguments: null);
        }
      case NotificationType.task: // Xử lý trường hợp thông báo nhiệm vụ
        return (route: AppRouter.profile, arguments: {'taskId': id});
      default: // Xử lý các loại thông báo khác hoặc không xác định
        return (route: AppRouter.main, arguments: null);
    }
  }
}
