import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/banner/binding/banner_binding.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
import 'package:vos_flutter/feature/home/binding/home_function_binding.dart';
import 'package:vos_flutter/feature/home/presentation/controller/home_function_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/router/app_router.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo BannerBinding nếu chưa có
    if (!Get.isRegistered<BannerController>()) {
      BannerBinding().dependencies();
    }
    
    // Khởi tạo HomeFunctionBinding nếu chưa có
    if (!Get.isRegistered<HomeFunctionController>()) {
      HomeFunctionBinding().dependencies();
    }
    
    // Load data sau khi widget được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      
      // Listen userProfile changes để reload banner khi link VIAGS thành công
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

  void _loadData() {
    try {
      print('🔄 _loadData called');
      if (!Get.isRegistered<ProfileController>()) {
        print('⚠️ ProfileController not registered');
        return;
      }
      
      final profileController = Get.find<ProfileController>();
      final token = profileController.userProfile.value?.token ?? '';
      final userId = profileController.userProfile.value?.userId ?? 0;
      
      print('📊 Profile data - token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "empty"}, userId: $userId');
      
      if (token.isEmpty) {
        print('⚠️ Token is empty, skipping banner load');
        return;
      }
      
      // Load banners với token từ VIAGS
      if (Get.isRegistered<BannerController>()) {
        final bannerController = Get.find<BannerController>();
        if (userId > 0) {
          print('🚀 Calling loadBanners with userId: $userId');
          // Token từ VIAGS không cần prefix "Bearer "
          bannerController.loadBanners(token, userId);
        } else {
          print('⚠️ userId is 0, skipping banner load');
        }
      } else {
        print('⚠️ BannerController not registered');
      }
      
      // Load home functions với token từ VIAGS
      if (Get.isRegistered<HomeFunctionController>()) {
        final homeFunctionController = Get.find<HomeFunctionController>();
        print('🚀 Calling loadHomeFunctions with lsStatus: TEST;product');
        // ls_Status: "TEST;product" theo API
        homeFunctionController.loadHomeFunctions(token, 'TEST;product');
      } else {
        print('⚠️ HomeFunctionController not registered');
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // QUAN TRỌNG: Check logout state TRƯỚC KHI build bất kỳ widget nào
    // Điều này ngăn rebuild khi đang logout
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.isLoggingOut) {
          // Đang logout → return empty widget để tránh rebuild
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: const SizedBox.shrink(),
          );
        }
      }
    } catch (e) {
      // Controller không tồn tại → có thể đang logout
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006884),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Thông báo',
                'Tính năng thông báo đang được phát triển',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            _buildBannerSection(),
            SizedBox(height: 20.h),

            // Home Functions Section
            _buildHomeFunctionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    if (!Get.isRegistered<BannerController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<BannerController>();
    
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Error state
      if (controller.error.value.isNotEmpty) {
        print('❌ Banner error: ${controller.error.value}');
        return const SizedBox.shrink();
      }

      // Empty state
      if (controller.banners.isEmpty) {
        print('⚠️ Banner list is empty');
        return const SizedBox.shrink();
      }

      print('✅ Displaying ${controller.banners.length} banners');

      // Banner list
      return Container(
        height: 180.h,
        margin: EdgeInsets.symmetric(horizontal: 0.w),
        child: PageView.builder(
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            final banner = controller.banners[index];
            return Container(
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('❌ Banner image error: $error');
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.error_outline, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHomeFunctionsSection() {
    if (!Get.isRegistered<HomeFunctionController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<HomeFunctionController>();
    
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Error state
      if (controller.error.value.isNotEmpty) {
        print('❌ Home function error: ${controller.error.value}');
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Center(
            child: Text(
              controller.error.value,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      // Empty state
      if (controller.sessions.isEmpty) {
        print('⚠️ Home function sessions list is empty');
        return const SizedBox.shrink();
      }

      print('✅ Displaying ${controller.sessions.length} home function sessions');

      // Sessions list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.sessions.map((session) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Title
              if (session.sessionName.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    session.sessionName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              // Function Items Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: session.listItems.length,
                itemBuilder: (context, index) {
                  final item = session.listItems[index];
                  return _buildFunctionItem(item);
                },
              ),
              SizedBox(height: 24.h),
            ],
          );
        }).toList(),
      );
    });
  }

  void _handleFunctionAction(String action) {
    switch (action) {
      case 'UyQuyen':
        // Navigate to authorize screen
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

  Widget _buildFunctionItem(item) {
    Color itemColor;
    try {
      itemColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      itemColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        // Handle tap action
        if (item.action.isNotEmpty) {
          _handleFunctionAction(item.action);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Image
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: item.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.apps,
                          color: itemColor,
                          size: 24.sp,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.apps,
                      color: itemColor,
                      size: 24.sp,
                    ),
            ),
            SizedBox(height: 8.h),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
