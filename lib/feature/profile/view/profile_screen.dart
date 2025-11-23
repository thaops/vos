import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Reload isEmployee khi screen được init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().reloadEmployeeStatus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload isEmployee mỗi khi screen được hiển thị (khi switch tab)
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().reloadEmployeeStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo ProfileBinding được gọi trước
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }
    
    // Controller sẽ được tạo bởi ProfileBinding
    final controller = Get.find<ProfileController>();

    // QUAN TRỌNG: Reload isEmployee và isViagsLinked từ storage TRƯỚC KHI Obx() build
    // Đảm bảo giá trị được sync với storage (đặc biệt khi chọn "Không" trong login screen)
    controller.reloadEmployeeStatus();
    controller.reloadViagsStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          return Obx(() {
            // Check context mounted trước khi rebuild
            if (!context.mounted) {
              return const SizedBox.shrink();
            }

            try {
              final hasGoogleUser = controller.googleUser.value != null;
              final hasUserProfile = controller.userProfile.value != null;

              if (!hasGoogleUser && !hasUserProfile) {
                return _buildNotLoggedInState(controller);
              }

              // ✅ ƯU TIÊN: Hiển thị VACS profile nếu có (profile từ VACS)
              if (hasUserProfile) {
                return _buildProfileContent(controller);
              }

              // Nếu không có VACS profile nhưng có Google user thì hiển thị Google user
              if (hasGoogleUser) {
                return _buildGoogleUserContent(controller);
              }

              // Fallback
              return _buildNotLoggedInState(controller);
            } catch (e) {
              // Controller đã bị dispose hoặc không tồn tại
              return const SizedBox.shrink();
            }
          });
        },
      ),
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

  Widget _buildProfileContent(ProfileController controller) {
    final user = controller.userProfile.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(user),
          SizedBox(height: 24.h),
          _buildPersonalInfo(user, controller),
          SizedBox(height: 24.h),
          _buildCompanyInfo(user),
          SizedBox(height: 24.h),
          _buildActionSection(controller),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(UserProfile user) {
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

  Widget _buildGoogleUserHeader(
    GoogleUserDto user,
    ProfileController controller,
  ) {
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
          // Avatar with photo
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: user.photoURL != null && user.photoURL!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.photoURL!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          SizedBox(height: 16.h),

          // Name
          Text(
            user.displayName ?? 'Người dùng Google',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          // Email - ưu tiên viagsEmail nếu đã liên kết
          Obx(() {
            String email;
            if (controller.isViagsLinked.value &&
                controller.viagsEmail.value.isNotEmpty) {
              // Đã liên kết VIAGS → dùng email từ VIAGS
              email = controller.viagsEmail.value;
            } else if (user.email != null && user.email!.isNotEmpty) {
              // Chưa liên kết → dùng email từ Google user
              email = user.email!;
            } else {
              return const SizedBox.shrink();
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                email,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoogleUserContent(ProfileController controller) {
    final googleUser = controller.googleUser.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGoogleUserHeader(googleUser, controller),
          SizedBox(height: 24.h),
          _buildGoogleUserInfo(googleUser, controller),
          SizedBox(height: 24.h),
          _buildActionSection(controller),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildGoogleUserInfo(
    GoogleUserDto user,
    ProfileController controller,
  ) {
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
              // Đã liên kết VIAGS → dùng email từ VIAGS
              email = controller.viagsEmail.value;
            } else if (user.email != null && user.email!.isNotEmpty) {
              // Chưa liên kết → dùng email từ Google user
              email = user.email!;
            } else {
              return const SizedBox.shrink();
            }

            return _buildInfoItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onTap: email.isNotEmpty && email != 'dev@namphuongso.com'
                  ? () => _launchEmail(email)
                  : null,
            );
          }),
          if (user.displayName != null && user.displayName!.isNotEmpty)
            _buildInfoItem(
              icon: Icons.badge_outlined,
              label: 'Tên hiển thị',
              value: user.displayName!,
            ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState(ProfileController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80.sp, color: Colors.grey[400]),
            SizedBox(height: 24.h),
            Text(
              'Chưa đăng nhập',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vui lòng đăng nhập để xem thông tin cá nhân',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRouter.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Đăng nhập bằng Google',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(
    UserProfile user,
    ProfileController controller,
  ) {
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
          Obx(() {
            // Sử dụng reactive values để email tự động cập nhật khi liên kết
            // QUAN TRỌNG: Ưu tiên viagsEmail nếu đã liên kết, sau đó mới dùng userProfile.email
            String email;

            if (controller.isViagsLinked.value &&
                controller.viagsEmail.value.isNotEmpty) {
              // Đã liên kết VIAGS → dùng email từ VIAGS
              email = controller.viagsEmail.value;
            } else if (controller.userProfile.value != null &&
                controller.userProfile.value!.email.isNotEmpty) {
              // Chưa liên kết → dùng email từ userProfile
              email = controller.userProfile.value!.email;
            } else {
              // Fallback
              email = 'dev@namphuongso.com';
            }

            return _buildInfoItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onTap: email.isNotEmpty && email != 'dev@namphuongso.com'
                  ? () => _launchEmail(email)
                  : null,
            );
          }),
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

  Widget _buildCompanyInfo(UserProfile user) {
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
          // Chỉ hiển thị nút liên kết nếu:
          // 1. Chưa liên kết VIAGS
          // 2. Không phải nhân viên (không có tab Home)
          // Nếu đã là nhân viên (có tab Home) thì không hiển thị nút liên kết
          Obx(() {
            // Đảm bảo reload trước khi đọc giá trị (để sync với storage)
            // Điều này đảm bảo khi chọn "Không" trong login screen, giá trị được cập nhật
            controller.reloadEmployeeStatus();
            controller.reloadViagsStatus();

            final isEmployee = controller.isEmployee.value;
            final isViagsLinked = controller.isViagsLinked.value;

            // Debug: In ra giá trị để kiểm tra
            // print('🔍 ProfileScreen - isEmployee: $isEmployee, isViagsLinked: $isViagsLinked');

            // Chỉ hiển thị nếu chưa liên kết VÀ không phải nhân viên
            if (!isViagsLinked && !isEmployee) {
              return Column(
                children: [
                  _buildActionButton(
                    icon: Icons.link,
                    title: 'Liên kết acc VIAGS',
                    onTap: () => Get.toNamed(AppRouter.linkViags),
                  ),
                  SizedBox(height: 12.h),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
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
            onPressed: () async {
              Get.back(); // Đóng dialog trước

              // Hiển thị loading indicator
              Get.dialog(
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Đang đăng xuất...',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                // 1. Clear auth và storage (KHÔNG thay đổi reactive values)
                await controller.logout();

                // 2. Navigate TRƯỚC để dispose widget tree (bao gồm chart trong home_tab)
                // Phải navigate TRƯỚC để tránh mutate disposed widgets
                Get.offAllNamed(AppRouter.login);

                // 3. Đóng loading dialog SAU KHI navigate (safe vì đã navigate)
                // Dùng Future.microtask để đảm bảo navigate hoàn tất trước
                Future.microtask(() {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                });
              } catch (e) {
                // Navigate ngay lập tức dù có lỗi
                Get.offAllNamed(AppRouter.login);

                // Đóng loading dialog sau khi navigate
                Future.microtask(() {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                });

                // Hiển thị lỗi sau khi navigate
                Future.microtask(() {
                  Get.snackbar(
                    'Lỗi',
                    'Có lỗi xảy ra khi đăng xuất: ${e.toString()}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade800,
                  );
                });
              }
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
