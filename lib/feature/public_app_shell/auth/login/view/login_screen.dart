import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/img/img.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/controller/login_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/widgets/widgets/background_fill_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BackgroundFillView(
          child: _buildResponsiveLayout(controller, context),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    LoginController controller,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 1200;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 30.h : 20.h,
                horizontal: isDesktop ? 40.w : 20.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isTablet ? 80.h : 40.h),
                    child: _buildLogo(controller),
                  ),
                  SizedBox(height: isTablet ? 40.h : 20.h),

                  _buildLoginForm(controller, isTablet, isDesktop),
                  SizedBox(height: isTablet ? 60.h : 40.h),
                  _buildInstruction(context, isTablet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(
    LoginController controller,
    bool isTablet,
    bool isDesktop,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500.w : (isTablet ? 400.w : double.infinity),
        ),
        child: _buildModernLoginCard(controller, isTablet),
      ),
    );
  }

  Widget _buildModernLoginCard(LoginController controller, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 40.w : 32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Chào mừng trở lại! 👋',
            style: TextStyle(
              fontSize: isTablet ? 28.sp : 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Đăng nhập để tiếp tục',
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Username Field
          _buildTextField(
            controller: controller.usernameController,
            label: 'Tên đăng nhập',
            hint: 'Nhập tên đăng nhập của bạn',
            icon: Icons.person_outline,
            isTablet: isTablet,
          ),
          SizedBox(height: 20.h),

          // Password Field
          _buildTextField(
            controller: controller.passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            icon: Icons.lock_outline,
            isPassword: true,
            isTablet: isTablet,
          ),
          SizedBox(height: 16.h),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                Get.snackbar(
                  'Thông báo',
                  'Tính năng quên mật khẩu đang được phát triển',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: isTablet ? 14.sp : 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Login Button
          _buildLoginButton(controller, isTablet),
          SizedBox(height: 20.h),

          // Remember Me
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (value) =>
                      controller.rememberMe.value = value ?? false,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Text(
                'Ghi nhớ đăng nhập',
                style: TextStyle(
                  fontSize: isTablet ? 14.sp : 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14.sp : 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(
            fontSize: isTablet ? 16.sp : 15.sp,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: isTablet ? 15.sp : 14.sp,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
              size: isTablet ? 22.sp : 20.sp,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: isTablet ? 20.sp : 18.sp,
                    ),
                    onPressed: () {
                      // TODO: Implement password visibility toggle
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: isTablet ? 16.h : 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(LoginController controller, bool isTablet) {
    return Obx(
      () => Container(
        height: isTablet ? 56.h : 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
          onPressed: controller.isLoading.value
              ? null
              : () {
                  controller.usernameController.text = 'NamPhuong';
                  controller.passwordController.text = 'NamPhuong@1234';
                  controller.loginFramework(Get.context!);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  width: isTablet ? 24.w : 20.w,
                  height: isTablet ? 24.h : 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: isTablet ? 16.sp : 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      child: Column(children: [
        ],
      ),
    );
  }

  Widget _buildLogo(LoginController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final logoWidth = isTablet ? 300.w : 250.w;
        final logoHeight = isTablet ? 165.h : 137.h;

        return GestureDetector(
          child: Container(
            width: logoWidth,
            height: logoHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  size: isTablet ? 60.sp : 50.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Text(
                  'VOS',
                  style: TextStyle(
                    fontSize: isTablet ? 24.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Flutter App',
                  style: TextStyle(
                    fontSize: isTablet ? 14.sp : 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            controller.tapCount++;
            controller.showConfigDialog();
          },
        );
      },
    );
  }
}
