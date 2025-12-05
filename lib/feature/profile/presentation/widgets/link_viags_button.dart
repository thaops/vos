import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/router/app_router.dart';

class LinkViagsButton extends StatelessWidget {
  final ProfileController controller;

  const LinkViagsButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEmployee = controller.isEmployee.value;
      final isViagsLinked = controller.isViagsLinked.value;

      // Chỉ hiển thị nếu chưa liên kết VÀ không phải nhân viên
      if (isViagsLinked || isEmployee) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: _buildActionButton(
          icon: Icons.link,
          title: 'Liên kết tài khoản đã xác minh',
          onTap: () => Get.toNamed(AppRouter.linkViags),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
