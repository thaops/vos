import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class UserOverlayWidget extends StatelessWidget {
  final ProfileController? profileController;

  const UserOverlayWidget({super.key, this.profileController});

  @override
  Widget build(BuildContext context) {
    if (profileController == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final userProfile = profileController!.userProfile.value;
      final googleUser = profileController!.googleUser.value;

      // CHỈ hiển thị khi có userProfile VÀ có userName không rỗng
      String? userName;
      String? avatarUrl;

      if (userProfile != null && userProfile.userName.isNotEmpty) {
        userName = userProfile.userName;
      } else if (googleUser != null &&
          googleUser.displayName != null &&
          googleUser.displayName!.isNotEmpty) {
        userName = googleUser.displayName;
        avatarUrl = googleUser.photoURL;
      }

      // Không có name → ẩn
      if (userName == null || userName.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.person, size: 20.sp, color: Colors.white),
                    ),
                  )
                : Icon(Icons.person, size: 20.sp, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          // Tên người dùng
          Text(
            userName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
