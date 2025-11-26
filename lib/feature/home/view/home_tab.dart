import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/binding/banner_binding.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
import 'package:vos_flutter/feature/home/binding/home_function_binding.dart';
import 'package:vos_flutter/feature/home/presentation/controller/home_function_controller.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/banner_section_widget.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/home_functions_section_widget.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/router/app_router.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BannerController>()) {
      BannerBinding().dependencies();
    }

    if (!Get.isRegistered<HomeFunctionController>()) {
      HomeFunctionBinding().dependencies();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();

      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        ever(profileController.userProfile, (userProfile) {
          if (userProfile != null && userProfile.token.isNotEmpty) {
            _loadData();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    try {
      if (!Get.isRegistered<ProfileController>()) {
        return;
      }

      final profileController = Get.find<ProfileController>();
      final token = profileController.userProfile.value?.token ?? '';
      final userId = profileController.userProfile.value?.userId ?? 0;

      if (token.isEmpty) {
        return;
      }

      // ✅ Sửa: Chỉ tìm BannerController, KHÔNG đăng ký lại (tránh duplicate)
      // BannerController đã được đăng ký trong initState()
      BannerController? bannerController;
      try {
        if (Get.isRegistered<BannerController>()) {
          bannerController = Get.find<BannerController>();
        }
      } catch (e) {
        print('⚠️ BannerController not found in _loadData: $e');
      }

      if (bannerController != null && userId > 0) {
        bannerController.loadBanners(token, userId);
      }

      if (Get.isRegistered<HomeFunctionController>()) {
        final homeFunctionController = Get.find<HomeFunctionController>();
        homeFunctionController.loadHomeFunctions(token, 'TEST;product');
      }
    } catch (e) {
      // Silent error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.isLoggingOut) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: const SizedBox.shrink(),
          );
        }
      }
    } catch (e) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          BannerSectionWidget(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: 16.h,
                ),
                child: HomeFunctionsSectionWidget(
                  onActionTap: _handleFunctionAction,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFunctionAction(String action) {
    switch (action) {
      case 'UyQuyen':
        Get.toNamed(AppRouter.authorize);
        break;
      default:
        Get.snackbar(
          'Thông báo',
          'Tính năng $action đang được phát triển',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }
}
