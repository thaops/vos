import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/banner_indicator_widget.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/banner_placeholder_widget.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/user_overlay_widget.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class BannerSectionWidget extends StatefulWidget {
  const BannerSectionWidget({super.key});

  @override
  State<BannerSectionWidget> createState() => _BannerSectionWidgetState();
}

class _BannerSectionWidgetState extends State<BannerSectionWidget> {
  PageController? _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  bool _autoScrollStarted = false;
  int _lastBannerCount = 0;
  bool _isInitializing = false; // ✅ Thêm flag để tránh reset khi đang khởi tạo

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController?.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll(int bannerCount) {
    // ✅ Tránh khởi động lại timer nếu đã đang chạy với cùng bannerCount
    if (_autoScrollStarted && _lastBannerCount == bannerCount) return;

    // Dừng timer cũ trước
    _stopBannerAutoScroll();

    if (bannerCount <= 1) return;

    // Nếu controller chưa attach vào PageView, đợi tới frame kế tiếp rồi thử lại
    if (_bannerPageController == null || !_bannerPageController!.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startBannerAutoScroll(bannerCount);
        }
      });
      return;
    }

    _lastBannerCount = bannerCount;
    _autoScrollStarted = true;

    // ✅ Thêm: Delay 2 giây trước khi bắt đầu auto scroll để đảm bảo ảnh đầu tiên đã load xong
    _bannerTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted ||
          _bannerPageController == null ||
          !_bannerPageController!.hasClients) {
        _autoScrollStarted = false;
        return;
      }

      // Bắt đầu auto scroll sau delay
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted ||
            _bannerPageController == null ||
            !_bannerPageController!.hasClients) {
          timer.cancel();
          _autoScrollStarted = false;
          return;
        }

        // ✅ Sửa: Lấy currentIndex từ PageController thay vì state để tránh race condition
        final currentPage =
            _bannerPageController!.page?.round() ?? _currentBannerIndex;
        final nextIndex = (currentPage + 1) % bannerCount;

        try {
          _bannerPageController!.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          // Ignore animation errors (controller might be disposed)
          timer.cancel();
          _autoScrollStarted = false;
        }
      });
    });
  }

  void _stopBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = null;
    _autoScrollStarted = false;
  }

  // ✅ Sửa: Khởi tạo/reset PageController an toàn
  void _initializePageController(int bannerCount) {
    // Chỉ reset nếu số lượng banner thay đổi
    if (_lastBannerCount == bannerCount && _bannerPageController != null) {
      return;
    }

    // Tránh reset khi đang khởi tạo
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;

    // ✅ Sửa: Dừng timer TRƯỚC KHI dispose PageController để tránh race condition
    _stopBannerAutoScroll();

    // Dispose controller cũ nếu có (chỉ khi không đang được sử dụng)
    if (_bannerPageController != null) {
      // Chỉ dispose nếu không có clients hoặc không đang animate
      if (!_bannerPageController!.hasClients) {
        _bannerPageController?.dispose();
      } else {
        // Nếu đang có clients, đợi một frame rồi dispose
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _bannerPageController != null) {
            try {
              _bannerPageController?.dispose();
            } catch (e) {
              // Ignore dispose errors
            }
          }
        });
      }
    }

    // Tạo controller mới
    _bannerPageController = PageController();
    _currentBannerIndex = 0;
    _lastBannerCount = bannerCount;
    _isInitializing = false;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Sửa: KHÔNG đăng ký BannerController trong build() - chỉ tìm instance đã tồn tại
    // BannerController phải được đăng ký trong HomeTab.initState() hoặc Binding
    BannerController? bannerController;
    try {
      if (Get.isRegistered<BannerController>()) {
        bannerController = Get.find<BannerController>();
      }
    } catch (e) {
      // Ignore errors - controller chưa được đăng ký
      print('⚠️ BannerController not found: $e');
    }

    if (bannerController == null) {
      return BannerPlaceholderWidget();
    }
    final controller = bannerController;
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    return Obx(() {
      // Tính chiều cao banner = 25-30% màn hình
      final screenHeight = MediaQuery.of(context).size.height;
      final bannerHeight = screenHeight * 0.28;

      // ✅ Loading state - hiển thị loading và dừng auto scroll
      if (controller.isLoading.value) {
        _stopBannerAutoScroll();
        // ✅ Reset PageController khi đang load để tránh hiển thị banners cũ
        if (_bannerPageController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _bannerPageController?.dispose();
              _bannerPageController = null;
              _currentBannerIndex = 0;
              _lastBannerCount = 0;
            }
          });
        }
        return Container(
          height: bannerHeight,
          color: Colors.grey[200],
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Lọc bỏ các banner có imageUrl rỗng hoặc null
      final validBanners = controller.banners
          .where((banner) => banner.imageUrl.isNotEmpty)
          .toList();

      // ✅ Error state hoặc empty state - hiển thị placeholder và dừng auto scroll
      if (controller.error.value.isNotEmpty || validBanners.isEmpty) {
        _stopBannerAutoScroll();
        // ✅ Reset PageController khi không có banners
        if (_bannerPageController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _bannerPageController?.dispose();
              _bannerPageController = null;
              _currentBannerIndex = 0;
              _lastBannerCount = 0;
            }
          });
        }
        return BannerPlaceholderWidget();
      }

      final bannerCount = validBanners.length;

      final needsInitialization =
          _bannerPageController == null || _lastBannerCount != bannerCount;

      if (needsInitialization && !_isInitializing) {
        _initializePageController(bannerCount);

        if (bannerCount > 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _startBannerAutoScroll(bannerCount);
            }
          });
        } else {
          _stopBannerAutoScroll();
        }
      } else if (bannerCount > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _startBannerAutoScroll(bannerCount);
          }
        });
      } else {
        _stopBannerAutoScroll();
      }

      // Banner với overlay
      return Stack(
        children: [
          // Banner - không bo góc, tràn lên appbar
          Container(
            height: bannerHeight,
            color: Colors
                .grey[200], // ✅ Thêm: Background color để tránh hiển thị màu xanh
            child: PageView.builder(
              key: ValueKey(
                'banner_$bannerCount',
              ), // ✅ Sửa: Force rebuild khi banner count thay đổi
              controller: _bannerPageController,
              physics: const PageScrollPhysics(),
              itemCount: validBanners.length,
              onPageChanged: (index) {
                if (!mounted) return; // ✅ Sửa: Check mounted trước khi setState
                setState(() {
                  _currentBannerIndex = index;
                });
                // ✅ Sửa: Không gọi _startBannerAutoScroll() ở đây
                // Timer đã được khởi động rồi, chỉ cần update index
              },
              itemBuilder: (context, index) {
                final banner = validBanners[index];
                // ✅ Kiểm tra lại imageUrl trước khi render - nếu rỗng thì hiển thị placeholder
                if (banner.imageUrl.isEmpty) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                }
                return Container(
                  color: Colors
                      .grey[200], // ✅ Background color để tránh hiển thị màu xanh khi đang load
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200], // ✅ Màu xám thay vì màu xanh
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey[600]!,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      // ✅ Hiển thị error widget với màu xám thay vì màu xanh
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                    // ✅ Cache image để tránh reload khi vuốt
                    memCacheWidth:
                        (MediaQuery.of(context).size.width *
                                MediaQuery.of(context).devicePixelRatio)
                            .round(),
                  ),
                );
              },
            ),
          ),

          // Gradient overlay từ trên xuống để tạo đổ bóng mạnh hơn
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.5, 0.8],
                  ),
                ),
              ),
            ),
          ),

          // Overlay: Avatar + Tên người dùng (góc trái trên)
          Positioned(
            left: 16.w,
            top: MediaQuery.of(context).padding.top + 16.h,
            child: UserOverlayWidget(profileController: profileController),
          ),

          // Icon thông báo (góc phải trên)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            right: 16.w,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
              onPressed: () {
                Get.snackbar(
                  'Thông báo',
                  'Tính năng thông báo đang được phát triển',
                );
              },
            ),
          ),

          // Banner indicator (dots) ở dưới cùng
          if (validBanners.length > 1)
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: BannerIndicatorWidget(
                totalCount: validBanners.length,
                currentIndex: _currentBannerIndex,
              ),
            ),
        ],
      );
    });
  }
}
