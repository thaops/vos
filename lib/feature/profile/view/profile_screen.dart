import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';
import 'package:vos_flutter/feature/profile/models/user_profile_model.dart';
import 'package:vos_flutter/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.userProfile.value == null) {
          return _buildLoadingState();
        }
        return _buildProfileContent(controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Hồ sơ cá nhân',
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: Colors.grey[600],
            size: 24.sp,
          ),
          onPressed: () {
            Get.snackbar('Cài đặt', 'Tính năng cài đặt đang được phát triển');
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tải thông tin...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileController controller) {
    final user = controller.userProfile.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(user),
          SizedBox(height: 24.h),
          _buildPersonalInfo(user),
          SizedBox(height: 24.h),
          _buildCompanyInfo(user),
          SizedBox(height: 24.h),
          _buildActionSection(controller),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(UserProfileModel user) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
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
        children: [
          // Avatar
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(Icons.person, size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),

          // Name
          Text(
            user.userName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          // User Code
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              user.userCode,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(UserProfileModel user) {
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
            'Thông tin cá nhân',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20.h),
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email.isNotEmpty ? user.email : 'dev@namphuongso.com',
            onTap: user.email.isNotEmpty
                ? () => _launchEmail(user.email)
                : null,
          ),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: user.phone.isNotEmpty ? user.phone : '0909090909',
            onTap: user.phone.isNotEmpty
                ? () => _launchPhone(user.phone)
                : null,
          ),
          _buildInfoItem(
            icon: Icons.badge_outlined,
            label: 'Loại tài khoản',
            value: _getUserTypeText(user.userType),
          ),
          _buildInfoItem(
            icon: Icons.security_outlined,
            label: 'Mức độ mật khẩu',
            value: _getPasswordLevelText(user.pwdLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(UserProfileModel user) {
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
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Thông tin công ty',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildCompanyItem('Tên công ty', user.companyNameVN),
          _buildCompanyItem('Mã công ty', user.companyCode),
          _buildCompanyItem('Mô tả', user.description),
          if (user.branchNameVN.isNotEmpty)
            _buildCompanyItem('Chi nhánh', user.branchNameVN),
          _buildCompanyItem('Ngôn ngữ', user.language),
          _buildCompanyItem('Loại đăng nhập', user.loginType),
        ],
      ),
    );
  }

  Widget _buildCompanyItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Chưa cập nhật',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            title: 'Chỉnh sửa thông tin',
            onTap: () {
              Get.snackbar(
                'Chỉnh sửa',
                'Tính năng chỉnh sửa đang được phát triển',
              );
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            onTap: () {
              Get.snackbar('Bảo mật', 'Tính năng bảo mật đang được phát triển');
            },
          ),
          SizedBox(height: 12.h),
          _buildActionButton(
            icon: Icons.logout,
            title: 'Đăng xuất',
            isDestructive: true,
            onTap: () => _showLogoutDialog(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.logout();
              Get.offAllNamed(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(String userType) {
    switch (userType) {
      case 'U':
        return 'Người dùng';
      case 'A':
        return 'Quản trị viên';
      case 'S':
        return 'Siêu quản trị viên';
      default:
        return 'Không xác định';
    }
  }

  String _getPasswordLevelText(String pwdLevel) {
    switch (pwdLevel) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'DIFFICULT':
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
