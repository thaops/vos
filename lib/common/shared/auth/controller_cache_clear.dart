import 'package:get/get.dart';
// import 'package:vos_flutter/feature/private_app_shell/filter_user/controller/filter_user_controller.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';

/// Service để clear cache của các controllers cụ thể
class ControllerCacheClear {
  /// Clear tất cả controllers và reset state (KHÔNG reset GetX hoàn toàn)
  static void clearControllersOnly() {
    try {
      // Clear Filter User Controller - DISABLED: Module deleted
      // if (Get.isRegistered<FilterUserController>()) {
      //   final filterUserController = Get.find<FilterUserController>();
      //   filterUserController.employeeIdToDepartment.clear();
      //   filterUserController.userList.clear();
      // }

      // Clear Profile Controller
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.logout();
      }

      // KHÔNG gọi Get.reset() để tránh xóa GetMaterialApp context
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  /// Clear tất cả controllers và reset state (DÀNH CHO TRƯỜNG HỢP ĐẶC BIỆT)
  static void clearAllControllers() {
    try {
      // Clear Filter User Controller - DISABLED: Module deleted
      // if (Get.isRegistered<FilterUserController>()) {
      //   final filterUserController = Get.find<FilterUserController>();
      //   filterUserController.employeeIdToDepartment.clear();
      //   filterUserController.userList.clear();
      // }

      // Clear Profile Controller
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.logout();
      }

      // Clear tất cả GetX dependencies (CHỈ DÙNG KHI CẦN THIẾT)
      Get.reset();
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  /// Clear chỉ leave management controllers
  static void clearLeaveControllers() {
    try {} catch (e) {
      print('Error clearing leave controllers: $e');
    }
  }

  /// Clear chỉ user filter controllers
  static void clearUserControllers() {
    try {
      // DISABLED: FilterUserController module deleted
      // if (Get.isRegistered<FilterUserController>()) {
      //   final controller = Get.find<FilterUserController>();
      //   controller.employeeIdToDepartment.clear();
      //   controller.userList.clear();
      // }

      if (Get.isRegistered<ProfileController>()) {
        final controller = Get.find<ProfileController>();
        controller.logout();
      }
    } catch (e) {
      print('Error clearing user controllers: $e');
    }
  }
}
