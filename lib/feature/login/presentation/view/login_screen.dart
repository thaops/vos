import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/img/img.dart';
import 'package:vos_flutter/feature/login/presentation/controller/login_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/widgets/widgets/background_fill_view.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

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

        final screenHeight = constraints.maxHeight;
        final topPadding = screenHeight * 0.1;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                left: isDesktop ? 40.w : 20.w,
                right: isDesktop ? 40.w : 20.w,
                bottom: isTablet ? 30.h : 20.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLogo(controller),
                  SizedBox(height: isTablet ? 60.h : 48.h),
                  _buildWelcomeSection(controller, isTablet),
                  SizedBox(height: 32.h),
                  _buildGoogleSignInButton(controller, isTablet),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildWelcomeSection(LoginController controller, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
            ),
            SizedBox(width: 8.w),
            Text('👋', style: TextStyle(fontSize: isTablet ? 28.sp : 24.sp)),
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
      ],
    );
  }

  Widget _buildGoogleSignInButton(LoginController controller, bool isTablet) {
    return Obx(() {
      final isLoading = controller.isLoading;
      return Center(
        child: Container(
          height: isTablet ? 56.h : 50.h,
          constraints: BoxConstraints(minWidth: double.infinity),
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
                : Image.asset(
                    Img.google,
                    width: isTablet ? 24.w : 20.w,
                    height: isTablet ? 24.h : 20.h,
                    fit: BoxFit.contain,
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
        ),
      );
    });
  }
}
