import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfile user;
  final ProfileController controller;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          // Avatar with camera icon
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 50.sp,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Name
          Text(
            user.userName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          // Department
          Text(
            user.description.isNotEmpty
                ? user.description
                : 'Phòng Công nghệ thông tin',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          // Primary Email
          Obx(() {
            String email;
            // ✅ Chỉ hiển thị viagsEmail nếu thực sự có liên kết
            if (controller.isViagsLinked.value &&
                controller.viagsEmail.value.isNotEmpty) {
              email = controller.viagsEmail.value;
            } else if (user.email.isNotEmpty) {
              // ✅ Nếu không có liên kết VIAGS, hiển thị email từ userProfile
              email = user.email;
            } else {
              email = 'nguyenvana@gmail.com';
            }
            return Text(
              email,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            );
          }),
        ],
      ),
    );
  }
}

