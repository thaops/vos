import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/news/domain/models/news_extension.dart';
import 'package:vos_flutter/feature/news/presentation/controller/news_controller.dart';
import 'package:vos_flutter/feature/news_v2/widgets/news_card.dart';

class NewsScreen extends GetView<NewsController> {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return NewsCard(
                newsItem: item.toNewsItemModel(),
                onTap: () {
                  Get.toNamed('/news-detail', arguments: item.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
