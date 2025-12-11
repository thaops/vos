import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_menu_item.dart';
import 'package:vos_flutter/router/app_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'Điều khoản', isBack: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
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
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
