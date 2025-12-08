import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_button.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_menu_item.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/unlink_viags_button.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/viags_account_info_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/viags_connection_status_card.dart';
import 'package:vos_flutter/router/app_router.dart';

class ProfileContent extends StatelessWidget {
  final ProfileController controller;

  const ProfileContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.userProfile.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderCard(user: user, controller: controller),
          SizedBox(height: 16.h),
          Obx(() {
            // Nếu awaiting approval = true → ẩn tất cả liên quan đến VIAGS
            if (controller.isAwaitingApproval.value) {
              return const SizedBox.shrink();
            }

            if (controller.isViagsLinked.value) {
              return Column(
                children: [
                  ViagsConnectionStatusCard(),
                  SizedBox(height: 16.h),
                  ViagsAccountInfoCard(user: user, controller: controller),
                  SizedBox(height: 24.h),
                  UnlinkViagsButton(controller: controller),
                ],
              );
            } else {
              return Column(
                children: [
                  LinkViagsButton(controller: controller),
                  SizedBox(height: 24.h),
                ],
              );
            }
          }),
          SizedBox(height: 24.h),
          _buildMenuSection(),
          SizedBox(height: 32.h),
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
            'Thông tin',
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
