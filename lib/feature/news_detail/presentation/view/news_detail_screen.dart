import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/feature/news_detail/presentation/controller/news_detail_controller.dart';

class NewsDetailScreen extends GetView<NewsDetailController> {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _ReactiveAppBar(controller: controller),
      body: Obx(() {
        if (controller.status == ControllerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final newsDetail = controller.selectedNewsDetail.value;
        if (newsDetail == null) {
          return const Center(child: Text('No data'));
        }

        final htmlContent = newsDetail.content ?? '';
        if (htmlContent.isEmpty) {
          return const Center(child: Text('No content available'));
        }

        final webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          )
          ..loadRequest(
            Uri.dataFromString(
              htmlContent,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ),
          );

        return WebViewWidget(controller: webViewController);
      }),
    );
  }
}

class _ReactiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NewsDetailController controller;

  const _ReactiveAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBarWidget(
        title: controller.selectedNewsDetail.value?.title ?? 'News Detail',
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
