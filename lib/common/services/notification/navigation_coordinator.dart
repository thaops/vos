import 'package:get/get.dart';
import 'package:vos_flutter/common/utils/auth_utils.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/view/time_off_detail_screen.dart';
import 'package:vos_flutter/feature/time_off_detail/binding/time_off_detail_binding.dart';
import 'notification_intent.dart';
import 'pending_intent_storage.dart';

class NavigationCoordinator {
  final PendingIntentStorage _storage;

  NavigationCoordinator({PendingIntentStorage? storage})
      : _storage = storage ?? PendingIntentStorage();

  Future<void> handle(NotificationIntent intent) async {
    await _waitForRouterReady();

    final isLoggedIn = await AuthUtils.isLoggedIn();

    if (!isLoggedIn) {
      await _storage.save(intent);

      await _waitForRouterReady();
      if (Get.currentRoute != AppRouter.login) {
        Get.offAllNamed(AppRouter.login);
      }
      return;
    }

    if (intent is TimeOffDetailIntent) {
      await _navigateToTimeOffDetail(intent.vRegId);
    }
  }

  Future<void> handlePendingAfterLogin() async {
    final pending = await _storage.consume();
    if (pending != null) {
      await handle(pending);
    }
  }

  Future<bool> hasPending() => _storage.hasPending();

  Future<void> _waitForRouterReady() async {
    int retryCount = 0;
    const maxRetries = 10;

    while (retryCount < maxRetries) {
      final route = Get.currentRoute;
      if (route.isNotEmpty || Get.key.currentState != null) {
        return;
      }

      await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
      retryCount++;
    }
  }

  Future<void> _navigateToTimeOffDetail(int vRegId) async {
    await _waitForRouterReady();

    final currentRoute = Get.currentRoute;

    if (currentRoute == AppRouter.timeOffDetail) {
      Get.off(
        () => const TimeOffDetailScreen(),
        arguments: TimeOffDetailArgs(vRegId: vRegId),
        binding: TimeOffDetailBinding(),
      );
      return;
    }

    if (currentRoute != AppRouter.main && currentRoute.isNotEmpty) {
      await Get.offAllNamed(AppRouter.main);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    Get.toNamed(
      AppRouter.timeOffDetail,
      arguments: TimeOffDetailArgs(vRegId: vRegId),
    );
  }
}

