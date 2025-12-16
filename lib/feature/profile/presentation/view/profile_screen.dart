import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/logout_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_menu_item.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/viags_connection_status_card.dart';
import 'package:vos_flutter/router/app_router.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Đảm bảo ProfileBinding được gọi trước
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'Cá nhân ', isBack: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1000
              ? 1000.0
              : constraints.maxWidth;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Obx(() {
              final hasGoogleUser = controller.googleUser.value != null;
              final hasUserProfile = controller.userProfile.value != null;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (hasUserProfile)
                      ProfileHeaderCard(
                        user: controller.userProfile.value!,
                        controller: controller,
                      )
                    else if (hasGoogleUser)
                      GoogleUserHeaderCard(
                        user: controller.googleUser.value!,
                        controller: controller,
                      ),
                    // Hiển thị trạng thái đã liên kết nếu đã liên kết VOS
                    Obx(() {
                      if (controller.isViagsLinked.value) {
                        return Column(
                          children: [
                            SizedBox(height: 16.h),
                            const ViagsConnectionStatusCard(),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: 24.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          ProfileMenuItem(
                            icon: Icons.person_outline,
                            title: 'Thông tin cá nhân',
                            onTap: () => Get.toNamed(AppRouter.personalInfo),
                          ),
                          ProfileMenuItem(
                            icon: Icons.description_outlined,
                            title: 'Trung tâm hỗ trợ',
                            onTap: () => Get.toNamed(AppRouter.terms),
                          ),

                          SizedBox(height: 16.h),
                          Obx(() {
                            final shouldShowLogout =
                                controller.isViagsLinked.value;

                            if (!shouldShowLogout) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: InkWell(
                                onTap: () => LogoutDialog.show(controller),
                                child: Container(
                                  child: Row(
                                    spacing: 14.w,
                                    children: [
                                      Icon(Icons.logout, color: Colors.red),
                                      Text(
                                        'Đăng xuất',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
