import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/services/notification/notification_intent.dart';
import 'package:vos_flutter/common/services/notification/pending_intent_storage.dart';
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
        retryCount++;
        await Future.delayed(Duration(milliseconds: 500));
        continue;
      }

      final routeInfo = _getRouteInfo(type, id);

      try {
        final loggedIn = await AuthUtils.isLoggedIn();
        if (!loggedIn) {
          if (routeInfo.route == AppRouter.timeOffDetail &&
              routeInfo.arguments is TimeOffDetailArgs) {
            final args = routeInfo.arguments as TimeOffDetailArgs;
            await PendingIntentStorage().save(TimeOffDetailIntent(args.vRegId));
          }
          await Get.offAllNamed(AppRouter.login);
          return;
        }

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
      } catch (_) {
        return;
      }
    }
  }

  static ({String route, dynamic arguments}) _getRouteInfo(
    NotificationType type,
    String id,
  ) {
    switch (type) {
      case NotificationType.leaveRequest:
        final vRegId = int.tryParse(id);
        if (vRegId != null) {
          return (
            route: AppRouter.timeOffDetail,
            arguments: TimeOffDetailArgs(vRegId: vRegId),
          );
        } else {
          return (route: AppRouter.main, arguments: null);
        }
      case NotificationType.task:
        return (route: AppRouter.profile, arguments: {'taskId': id});
      default:
        return (route: AppRouter.main, arguments: null);
    }
  }
}
