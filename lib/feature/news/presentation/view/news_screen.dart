import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/news/binding/news_binding.dart';
import 'package:vos_flutter/feature/news/domain/models/news_extension.dart';
import 'package:vos_flutter/feature/news/presentation/controller/news_controller.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail_args.dart';
import 'package:vos_flutter/feature/news/presentation/widgets/news_card.dart';
import 'package:vos_flutter/router/app_router.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, NewsController controller) {
    controller.onSearchChanged(value);

    // Cancel timer cũ nếu có
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      // Nếu rỗng, refresh ngay lập tức
      controller.onRefresh();
      return;
    }

    // Tạo timer mới với delay 600ms
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      controller.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NewsController>()) {
      return Scaffold(
        appBar: AppBarWidget(title: 'VĂN HÓA - TIN TỨC', isBack: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'VĂN HÓA - TIN TỨC', isBack: false),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(value, controller),
              onSubmitted: (value) {
                // Cancel debounce timer khi submit
                _debounceTimer?.cancel();
                controller.onSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tin tức...',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.sp,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        // Cancel debounce timer khi clear
                        _debounceTimer?.cancel();
                        _searchController.clear();
                        controller.onSearchChanged('');
                        controller.onRefresh();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
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
                  borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          // News list
          Expanded(
            child: Obx(() {
              final data = controller.news;
              if (data.isEmpty &&
                  controller.status == ControllerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.value.isNotEmpty
                        ? 'Không tìm thấy kết quả'
                        : 'No data',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = data[index];
                          return NewsCard(
                            newsItem: item.toNewsItemModel(),
                            onTap: () {
                              Get.toNamed(
                                AppRouter.newsDetail,
                                arguments: NewsDetailArgs(
                                  id: item.id,
                                  title: item.title,
                                  categoryCode: item.categoryCode,
                                ),
                              );
                            },
                          );
                        }, childCount: data.length),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
