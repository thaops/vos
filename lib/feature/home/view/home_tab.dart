import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
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
  final List<Worker> _workers = <Worker>[];

  // ✅ Flutter thuần: State để lưu banner data
  List<Banner> _banners = [];
  bool _isLoadingBanners = false;
  String? _bannerError;
  String? _userName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    // ✅ Controllers đã được đăng ký bởi MainBinding (gắn vào route /main)
    // Không cần gọi binding ở đây nữa để tránh SmartManagement dọn nhầm controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupBannerListener();
      _setupProfileListener();
    });
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
    _workers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupBannerListener() {
    if (!Get.isRegistered<BannerController>()) {
      return;
    }

    try {
      final bannerController = Get.find<BannerController>();

      // Listen to banner changes
      _workers.add(
        ever(bannerController.banners, (banners) {
          if (mounted) {
            setState(() {
              _banners = List<Banner>.from(banners);
            });
          }
        }),
      );

      // Listen to loading state
      _workers.add(
        ever(bannerController.isLoading, (isLoading) {
          if (mounted) {
            setState(() {
              _isLoadingBanners = isLoading;
            });
          }
        }),
      );

      // Listen to error state
      _workers.add(
        ever(bannerController.error, (error) {
          if (mounted) {
            setState(() {
              _bannerError = error.isEmpty ? null : error;
            });
          }
        }),
      );
    } catch (e) {
      print('⚠️ Error setting up banner listener: $e');
    }
  }

  // ✅ Flutter thuần: Setup listener cho ProfileController
  void _setupProfileListener() {
    if (!Get.isRegistered<ProfileController>()) {
      return;
    }

    try {
      final profileController = Get.find<ProfileController>();

      // Listen to user profile changes
      _workers.add(
        ever(profileController.userProfile, (userProfile) {
          if (mounted) {
            setState(() {
              if (userProfile != null && userProfile.userName.isNotEmpty) {
                _userName = userProfile.userName;
                _avatarUrl = null; // Profile không có avatar URL
              } else {
                _userName = null;
                _avatarUrl = null;
              }
            });
          }
        }),
      );

      // Listen to Google user changes
      _workers.add(
        ever(profileController.googleUser, (googleUser) {
          if (mounted) {
            setState(() {
              if (googleUser != null &&
                  googleUser.displayName != null &&
                  googleUser.displayName!.isNotEmpty) {
                _userName = googleUser.displayName;
                _avatarUrl = googleUser.photoURL;
              } else if (_userName == null) {
                _userName = null;
                _avatarUrl = null;
              }
            });
          }
        }),
      );
    } catch (e) {
      print('⚠️ Error setting up profile listener: $e');
    }
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
        // ✅ Cache-first: load cache persist trước để vào Home thấy ngay
        bannerController.loadCachedBanners(userId);
        final hasCache = bannerController.banners.isNotEmpty;
        bannerController.loadBanners(token, userId, silent: hasCache);
      }

      if (Get.isRegistered<HomeFunctionController>()) {
        final homeFunctionController = Get.find<HomeFunctionController>();
        final hasCache = homeFunctionController.sessions.isNotEmpty;
        homeFunctionController.loadHomeFunctions(
          token,
          'TEST;product',
          silent: hasCache,
        );
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
          // ✅ Flutter thuần: Truyền banner data qua constructor
          BannerSectionWidget(
            banners: _banners,
            isLoading: _isLoadingBanners,
            error: _bannerError,
            userName: _userName,
            avatarUrl: _avatarUrl,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (kIsWeb || (!kIsWeb && Platform.isMacOS))
                        ? 1200
                        : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: (kIsWeb || (!kIsWeb && Platform.isMacOS))
                          ? 24.w
                          : 16.w,
                      right: (kIsWeb || (!kIsWeb && Platform.isMacOS))
                          ? 24.w
                          : 16.w,
                      top: (kIsWeb || (!kIsWeb && Platform.isMacOS))
                          ? 24.h
                          : 16.h,
                      bottom: (kIsWeb || (!kIsWeb && Platform.isMacOS))
                          ? 24.h
                          : 16.h,
                    ),
                    child: HomeFunctionsSectionWidget(
                      onActionTap: _handleFunctionAction,
                    ),
                  ),
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
      case 'Phep':
        Get.toNamed(AppRouter.timeOff);
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
