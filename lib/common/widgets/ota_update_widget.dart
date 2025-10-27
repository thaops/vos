import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/controllers/splash_controller.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class OTAUpdateWidget extends StatelessWidget {
  const OTAUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();

    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Cập nhật ứng dụng',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Current patch info
            Obx(
              () => Row(
                children: [
                  Text(
                    'Phiên bản hiện tại: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Patch ${splashController.currentPatchNumber.value}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Update status
            Obx(
              () => Row(
                children: [
                  Icon(
                    splashController.hasUpdate.value
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color: splashController.hasUpdate.value
                        ? Colors.green
                        : Colors.blue,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    splashController.hasUpdate.value
                        ? 'Có cập nhật mới'
                        : 'Đã cập nhật mới nhất',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: splashController.hasUpdate.value
                          ? Colors.green
                          : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Check update button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: splashController.isCheckingUpdate.value
                      ? null
                      : () => splashController.checkForUpdates(),
                  icon: splashController.isCheckingUpdate.value
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.refresh, size: 18.sp),
                  label: Text(
                    splashController.isCheckingUpdate.value
                        ? 'Đang kiểm tra...'
                        : 'Kiểm tra cập nhật',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Info text
            Text(
              'Ứng dụng sẽ tự động kiểm tra và tải cập nhật khi khởi động.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
