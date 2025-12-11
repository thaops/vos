import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/google_user_content.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/not_logged_in_state.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_content.dart';

class PersonalInfoScreen extends GetView<ProfileController> {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'Thông tin cá nhân', isBack: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1000
              ? 1000.0
              : constraints.maxWidth;

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
