import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/router/app_router.dart';

class LogoutDialog {
  static void show(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleLogout(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleLogout(ProfileController controller) async {
    Get.back();

    // Show loading
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text('Đang đăng xuất...', style: TextStyle(fontSize: 16.sp)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await controller.logout();
      Get.offAllNamed(AppRouter.login);
      Future.microtask(() {
        if (Get.isDialogOpen ?? false) Get.back();
      });
    } catch (e) {
      Get.offAllNamed(AppRouter.login);
      Future.microtask(() {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar(
          'Lỗi',
          'Có lỗi xảy ra khi đăng xuất: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      });
    }
  }
}

