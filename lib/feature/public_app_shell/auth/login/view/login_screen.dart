import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/img/img.dart';
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
                  _buildLogo(controller),
                  SizedBox(height: isTablet ? 80.h : 40.h),
                  _buildLoginCard(controller, isTablet, isDesktop),
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

  Widget _buildLoginCard(
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
            isLoading ? 'Đang đăng nhập...' : 'Đăng nhập bằng Google',
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

  Widget _buildInstruction(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      child: Column(children: []),
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
            child: Image.asset(Img.logo),
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
