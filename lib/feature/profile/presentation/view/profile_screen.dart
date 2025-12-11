import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_content.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/not_logged_in_state.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_content.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/logout_dialog.dart';

/// Wrapper widget để làm cho Obx trở thành PreferredSizeWidget
class _ReactiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ProfileController controller;

  const _ReactiveAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ẩn icon logout nếu đang awaiting approval
      final shouldShowLogout =
          !controller.isAwaitingApproval.value &&
          controller.isViagsLinked.value;

      return AppBarWidget(
        title: 'Thông tin',
        isBack: false,
        iconRightfirst: shouldShowLogout ? Icons.logout : null,
        colorfirst: Colors.white,
        functionfirst: shouldShowLogout
            ? () => LogoutDialog.show(controller)
            : null,
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

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
      appBar: _ReactiveAppBar(controller: controller),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Obx(() {
                final hasGoogleUser = controller.googleUser.value != null;
                final hasUserProfile = controller.userProfile.value != null;

                if (!hasGoogleUser && !hasUserProfile) {
                  return const NotLoggedInState();
                }

                // Ưu tiên VACS profile nếu có
                if (hasUserProfile) {
                  return ProfileContent(controller: controller);
                }

                // Fallback Google user
                if (hasGoogleUser) {
                  return GoogleUserContent(controller: controller);
                }

                return const NotLoggedInState();
              }),
            ),
          );
        },
      ),
    );
  }
}
