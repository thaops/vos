import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/utils/check_awaiting_services.dart';
import 'package:vos_flutter/common/widgets/custom_text_field.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/controller/login_controller.dart';

class FrameLogin extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final LoginController controllerLogin;

  const FrameLogin({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.controllerLogin,
  });

  @override
  Widget build(BuildContext context) {
    CheckAwaitingServices checkAwaitingServices = CheckAwaitingServices(
      GetStorage(),
    );

    return FutureBuilder<bool>(
      future: checkAwaitingServices.getawaiting(),
      builder: (context, snapshot) {
        bool awaiting = snapshot.data ?? false;
        if (awaiting) {
          return _buildAppleReview(
            usernameController: usernameController,
            passwordController: passwordController,
            controllerLogin: controllerLogin,
            context: context,
          );
        } else {
          // Always show the modern login form
          return _buildModernLoginForm(context, controllerLogin);
        }
      },
    );
  }
}

Widget _buildModernLoginForm(
  BuildContext context,
  LoginController controllerLogin,
) {
  return Container(
    padding: EdgeInsets.all(32.w),
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
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Đăng nhập để tiếp tục',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),

        // Username Field
        _buildTextField(
          controller: controllerLogin.usernameController,
          label: 'Tên đăng nhập',
          hint: 'Nhập tên đăng nhập của bạn',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 20.h),

        // Password Field
        Obx(
          () => _buildTextField(
            controller: controllerLogin.passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            icon: Icons.lock_outline,
            isPassword: true,
            showPassword: controllerLogin.showPassword.value,
            onTogglePassword: controllerLogin.togglePasswordVisibility,
          ),
        ),
        SizedBox(height: 16.h),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
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
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Login Button
        Obx(() => _buildLoginButton(controllerLogin)),
        SizedBox(height: 20.h),

        // Remember Me
        Obx(
          () => Row(
            children: [
              Checkbox(
                value: controllerLogin.rememberMe.value,
                onChanged: (value) => controllerLogin.toggleRememberMe(),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Text(
                'Ghi nhớ đăng nhập',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
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
  bool showPassword = false,
  VoidCallback? onTogglePassword,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller,
        obscureText: isPassword && !showPassword,
        style: TextStyle(fontSize: 15.sp, color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                    size: 18.sp,
                  ),
                  onPressed: onTogglePassword,
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
            vertical: 14.h,
          ),
        ),
      ),
    ],
  );
}

Widget _buildLoginButton(LoginController controllerLogin) {
  return Container(
    height: 50.h,
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
      onPressed: controllerLogin.isLoading.value
          ? null
          : () {
              controllerLogin.loginFramework(Get.context!);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: controllerLogin.isLoading.value
          ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Đăng nhập',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    ),
  );
}

// Legacy method for Apple Review - keeping for compatibility
Widget _buildAppleReview({
  required TextEditingController usernameController,
  required TextEditingController passwordController,
  required LoginController controllerLogin,
  required BuildContext context,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(controller: usernameController, hintText: 'Username'),
          SizedBox(height: 20),
          CustomTextField(
            controller: passwordController,
            hintText: 'Password',
            suffixIcon: Icons.visibility,
            obscureText: true,
            maxLines: 1,
          ),
          SizedBox(height: 35),
          Container(
            width: Get.width,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                controllerLogin.loginFramework(context);
              },
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}
