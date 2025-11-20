import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/img/img.dart';
import 'package:vos_flutter/feature/login/presentation/controller/login_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/widgets/widgets/background_fill_view.dart';
import 'package:vos_flutter/feature/login/presentation/widget/login_card_widget.dart';

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
                  LoginCardWidget(controller: controller, isTablet: isTablet, isDesktop: isDesktop),
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