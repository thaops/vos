import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/login/presentation/controller/login_controller.dart';

class LoginCardWidget extends StatelessWidget {
  final LoginController controller;
  final bool isTablet;
  final bool isDesktop;
  const LoginCardWidget({super.key, required this.controller, required this.isTablet, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500.w : (isTablet ? 400.w : double.infinity),
        ),
        child: _buildModernLoginCard(controller, isTablet),
      ),
    );
  }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chào mừng trở lại',
                style: TextStyle(
                  fontSize: isTablet ? 28.sp : 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 8.w),
              Text(
                '👋',
                style: TextStyle(
                  fontSize: isTablet ? 28.sp : 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Đăng nhập bằng tài khoản Google của bạn',
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Google Sign In Button
          _buildGoogleSignInButton(controller, isTablet),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton(LoginController controller, bool isTablet) {
    return Obx(() {
      final isLoading = controller.isLoading;
      return Container(
        height: isTablet ? 56.h : 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : () => controller.signInWithGoogle(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[800],
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          icon: isLoading
              ? SizedBox(
                  width: isTablet ? 24.w : 20.w,
                  height: isTablet ? 24.h : 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : Container(
                  width: isTablet ? 24.w : 20.w,
                  height: isTablet ? 24.h : 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: isTablet ? 18.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ),
          label: Text(
            isLoading ? 'Đang đăng nhập...' : 'Tiếp tục với Google',
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
      );
    });
  }


