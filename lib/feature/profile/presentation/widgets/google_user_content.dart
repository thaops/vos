import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_info_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_button.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_menu_item.dart';
import 'package:vos_flutter/router/app_router.dart';

class GoogleUserContent extends StatelessWidget {
  final ProfileController controller;

  const GoogleUserContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final googleUser = controller.googleUser.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Obx(() {
            // Nếu awaiting approval = true → ẩn nút liên kết VIAGS và thông tin tài khoản
            if (controller.isAwaitingApproval.value) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                          GoogleUserHeaderCard(user: googleUser, controller: controller),
              SizedBox(height: 24.h),

                LinkViagsButton(controller: controller),
                SizedBox(height: 24.h),
                GoogleUserInfoCard(user: googleUser, controller: controller),
              ],
            );
          }),
          SizedBox(height: 24.h),
          _buildMenuSection(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Thông tin và chính sách',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        ProfileMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Chính sách bảo mật',
          onTap: () => Get.toNamed(AppRouter.privacyPolicy),
        ),
        ProfileMenuItem(
          icon: Icons.description_outlined,
          title: 'Điều khoản sử dụng',
          onTap: () => Get.toNamed(AppRouter.termsOfService),
        ),
        ProfileMenuItem(
          icon: Icons.info_outline,
          title: 'Về Viags',
          onTap: () => Get.toNamed(AppRouter.about),
        ),
      ],
    );
  }
}
