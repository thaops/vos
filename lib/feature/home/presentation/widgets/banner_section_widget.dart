import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/banner_indicator_widget.dart';
import 'package:vos_flutter/feature/home/presentation/widgets/banner_placeholder_widget.dart';

/// BannerSectionWidget - Flutter thuần, KHÔNG dùng GetX
class BannerSectionWidget extends StatefulWidget {
  final List<Banner> banners;
  final bool isLoading;
  final String? error;
  final String? userName;
  final String? avatarUrl;

  const BannerSectionWidget({
    super.key,
    required this.banners,
    this.isLoading = false,
    this.error,
    this.userName,
    this.avatarUrl,
  });

  @override
  State<BannerSectionWidget> createState() => _BannerSectionWidgetState();
}

class _BannerSectionWidgetState extends State<BannerSectionWidget> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentBannerIndex = 0;
  List<Banner> _cachedBanners = [];
  int _lastBannerCount = 0;

  @override
  void initState() {
    super.initState();
    print('🟢 BannerSectionWidget initState (Flutter thuần)');
  }

  @override
  void dispose() {
    print('🔴 BannerSectionWidget dispose');
    super.dispose();
  }

  @override
  void didUpdateWidget(BannerSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Chỉ update khi banner count thay đổi hoặc lần đầu load
    if (_lastBannerCount != widget.banners.length || _cachedBanners.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _cachedBanners = List.from(widget.banners);
            _lastBannerCount = widget.banners.length;
            if (_currentBannerIndex >= widget.banners.length) {
              _currentBannerIndex = 0;
            }
          });
        }
      });
    } else {
      // Update cache mà không rebuild CarouselSlider
      _cachedBanners = List.from(widget.banners);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính chiều cao banner
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.28;
    final shouldShowUserOverlay =
        widget.userName != null && widget.userName!.isNotEmpty;

    // Loading state: KHÔNG hiển thị spinner (tránh xấu UI khi hot restart/reload)
    if (widget.isLoading && widget.banners.isEmpty) {
      return _buildPlaceholderWithOverlay(
        context: context,
        bannerHeight: bannerHeight,
        shouldShowUserOverlay: shouldShowUserOverlay,
      );
    }

    // Lọc banners hợp lệ
    final validBanners = widget.banners
        .where((banner) => banner.imageUrl.isNotEmpty)
        .toList();

    // Empty state (ưu tiên cache: nếu có banner thì vẫn hiển thị dù error)
    if (validBanners.isEmpty) {
      return _buildPlaceholderWithOverlay(
        context: context,
        bannerHeight: bannerHeight,
        shouldShowUserOverlay: shouldShowUserOverlay,
      );
    }

    // ✅ Flutter thuần: Render CarouselSlider với cached banners
    return _buildBannerCarousel(
      context: context,
      bannerHeight: bannerHeight,
      validBanners: _cachedBanners.isEmpty ? validBanners : _cachedBanners,
      shouldShowUserOverlay: shouldShowUserOverlay,
    );
  }

  Widget _buildBannerCarousel({
    required BuildContext context,
    required double bannerHeight,
    required List<Banner> validBanners,
    required bool shouldShowUserOverlay,
  }) {
    final bannerCount = validBanners.length;

    return Stack(
      children: [
        // Banner CarouselSlider
        SizedBox(
          height: bannerHeight,
          child: CarouselSlider.builder(
            key: ValueKey('banner_carousel_$bannerCount'),
            carouselController: _carouselController,
            itemCount: validBanners.length,
            options: CarouselOptions(
              height: bannerHeight,
              viewportFraction: 1.0,
              autoPlay: bannerCount > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 500),
              autoPlayCurve: Curves.easeInOut,
              enableInfiniteScroll: bannerCount > 1,
              scrollPhysics: const PageScrollPhysics(),
              onPageChanged: (index, reason) {
                if (!mounted) return;
                setState(() {
                  _currentBannerIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              if (index < 0 || index >= validBanners.length) {
                return BannerPlaceholderWidget.withHeight(height: bannerHeight);
              }

              final banner = validBanners[index];

              if (banner.imageUrl.isEmpty) {
                return BannerPlaceholderWidget.withHeight(height: bannerHeight);
              }

              // ✅ Không nền xám: luôn render placeholder gradient + icon, ảnh load lên trên
              return Stack(
                fit: StackFit.expand,
                children: [
                  BannerPlaceholderWidget.withHeight(height: bannerHeight),
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) {
                      return BannerPlaceholderWidget.withHeight(
                        height: bannerHeight,
                      );
                    },
                    memCacheWidth:
                        (MediaQuery.of(context).size.width *
                                MediaQuery.of(context).devicePixelRatio)
                            .round(),
                  ),
                ],
              );
            },
          ),
        ),

        _buildGradientOverlay(),
        if (shouldShowUserOverlay)
          _buildUserOverlayPositioned(context: context),
        _buildNotificationButton(context),

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
  }

  Widget _buildPlaceholderWithOverlay({
    required BuildContext context,
    required double bannerHeight,
    required bool shouldShowUserOverlay,
  }) {
    return Stack(
      children: [
        BannerPlaceholderWidget.withHeight(height: bannerHeight),
        _buildGradientOverlay(),
        if (shouldShowUserOverlay)
          _buildUserOverlayPositioned(context: context),
        _buildNotificationButton(context),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
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
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      right: 16.w,
      child: IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 24.sp,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng thông báo đang được phát triển'),
            ),
          );
        },
      ),
    );
  }

  Positioned _buildUserOverlayPositioned({required BuildContext context}) {
    return Positioned(
      left: 16.w,
      top: MediaQuery.of(context).padding.top + 16.h,
      child: _buildUserOverlay(),
    );
  }

  // ✅ Flutter thuần: Build user overlay không dùng GetX
  Widget _buildUserOverlay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, size: 20.sp, color: Colors.white),
                  ),
                )
              : Icon(Icons.person, size: 20.sp, color: Colors.white),
        ),
        SizedBox(width: 10.w),
        // Tên người dùng
        Text(
          widget.userName!,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
