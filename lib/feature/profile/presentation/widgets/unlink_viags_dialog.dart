import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class UnlinkViagsDialog {
  static void show(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Hủy kết nối',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn hủy kết nối với VOS Account?',
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
            onPressed: () => _handleUnlink(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Hủy kết nối',
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

  static Future<void> _handleUnlink(ProfileController controller) async {
    Get.back();

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
              Text('Đang hủy kết nối...', style: TextStyle(fontSize: 16.sp)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final success = await controller.unlinkViagsAccount();
    Get.back();

    if (success) {
      await controller.refreshAll();

      Get.snackbar(
        'Thành công',
        'Đã hủy kết nối với VOS Account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể hủy kết nối',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}

