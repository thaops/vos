import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NewsController>()) {
      return Scaffold(
        appBar: AppBarWidget(title: 'News', isBack: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'News', isBack: false),
      body: Obx(() {
        final data = controller.news;
        if (data.isEmpty && controller.status == ControllerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (data.isEmpty) {
          return const Center(child: Text('No data'));
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = data[index];
                      return NewsCard(
                        newsItem: item.toNewsItemModel(),
                        onTap: () {
                          Get.toNamed(
                            AppRouter.newsDetail,
                            arguments: NewsDetailArgs(id: item.id, title: item.title),
                          );
                        },
                      );
                    },
                    childCount: data.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
