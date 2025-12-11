import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/logout_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/not_logged_in_state.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_menu_item.dart';
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
      appBar: AppBarWidget(title: 'Thông tin', isBack: false),
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

              if (!hasGoogleUser && !hasUserProfile) {
                return const NotLoggedInState();
              }

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
                    SizedBox(height: 24.h),
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      onTap: () => Get.toNamed(AppRouter.personalInfo),
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Điều khoản',
                      onTap: () => Get.toNamed(AppRouter.terms),
                    ),
                    SizedBox(height: 32.h),
                    Obx(() {
                      final shouldShowLogout =
                          !controller.isAwaitingApproval.value &&
                          controller.isViagsLinked.value;

                      if (!shouldShowLogout) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: CustomButton(
                          text: 'Đăng xuất',
                          color: Colors.red,
                          textColor: Colors.white,
                          height: 50,
                          fontSize: 16,
                          width: double.infinity,
                          onPressed: () => LogoutDialog.show(controller),
                        ),
                      );
                    }),
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
