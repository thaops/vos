import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/profile_info_item.dart';

class GoogleUserInfoCard extends StatelessWidget {
  final GoogleUserDto user;
  final ProfileController controller;

  const GoogleUserInfoCard({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản Google',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20.h),
          // Email - ưu tiên viagsEmail nếu đã liên kết
          Obx(() {
            String email;
            if (controller.isViagsLinked.value &&
                controller.viagsEmail.value.isNotEmpty) {
              email = controller.viagsEmail.value;
            } else if (user.email != null && user.email!.isNotEmpty) {
              email = user.email!;
            } else {
              return const SizedBox.shrink();
            }

            return ProfileInfoItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onTap: email.isNotEmpty && email != 'dev@namphuongso.com'
                  ? () => _launchEmail(email)
                  : null,
            );
          }),
          if (user.displayName != null && user.displayName!.isNotEmpty)
            ProfileInfoItem(
              icon: Icons.badge_outlined,
              label: 'Tên hiển thị',
              value: user.displayName!,
            ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

