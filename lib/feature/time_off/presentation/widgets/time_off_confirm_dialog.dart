import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

enum TimeOffDialogType {
  cancel, // Màu đỏ - Hủy đơn
  recall, // Màu vàng - Thu hồi
  sendApprove, // Màu xanh - Gửi phê duyệt
}

class TimeOffConfirmDialog extends StatelessWidget {
  final TimeOffDialogType type;
  final String title;
  final String message;

  const TimeOffConfirmDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  static Future<bool?> show({
    required TimeOffDialogType type,
    required String title,
    required String message,
  }) {
    return Get.dialog<bool>(
      TimeOffConfirmDialog(type: type, title: title, message: message),
      barrierDismissible: false,
    );
  }

  Color get _iconColor {
    switch (type) {
      case TimeOffDialogType.cancel:
        return Colors.red;
      case TimeOffDialogType.recall:
        return Colors.orange.shade700;
      case TimeOffDialogType.sendApprove:
        return AppColors.primary;
    }
  }

  Color get _titleColor {
    switch (type) {
      case TimeOffDialogType.cancel:
        return const Color(0xFF00838F); // Teal đậm
      case TimeOffDialogType.recall:
        return Colors.orange.shade700; // Vàng cam
      case TimeOffDialogType.sendApprove:
        return AppColors.primary; // Xanh primary
    }
  }

  IconData get _iconData {
    switch (type) {
      case TimeOffDialogType.cancel:
        return Icons.close_rounded;
      case TimeOffDialogType.recall:
        return Icons.undo_rounded;
      case TimeOffDialogType.sendApprove:
        return Icons.send_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 320.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _iconColor,
              ),
              child: Icon(_iconData, color: Colors.white, size: 32.sp),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Action buttons
            Row(
              children: [
                // Nút "Không"
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Không',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Nút "Có"
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Có',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
