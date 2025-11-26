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
    final hasWebArgs =
        controller.args?.isWebType == true && controller.url != null;

    // Nếu có URL từ args (type WEB), load trực tiếp
    if (hasWebArgs) {
      return _buildWebViewScreen(
        url: controller.url!,
        title: controller.title ?? 'News Detail',
        token: controller.vacsToken,
      );
    }

    // Nếu không có URL, dùng logic cũ (load từ controller)
    return _AppNewsDetailScreen(
      title: controller.title ?? 'News Detail',
      controller: controller,
    );
  }

  Widget _buildWebViewScreen({
    required String url,
    required String title,
    String? token,
  }) {
    return _WebViewScreen(url: url, title: title, token: token);
  }
}

class _AppNewsDetailScreen extends StatefulWidget {
  final String title;
  final NewsDetailController controller;

  const _AppNewsDetailScreen({required this.title, required this.controller});

  @override
  State<_AppNewsDetailScreen> createState() => _AppNewsDetailScreenState();
}

class _AppNewsDetailScreenState extends State<_AppNewsDetailScreen> {
  late final WebViewController _webViewController;
  String? _lastHtmlContent;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      );

    // Listen changes từ controller
    ever(widget.controller.selectedNewsDetail, (newsDetail) {
      if (newsDetail?.content != null && newsDetail!.content!.isNotEmpty) {
        _loadContent(newsDetail.content!);
      }
    });

    // Load initial content
    final newsDetail = widget.controller.selectedNewsDetail.value;
    if (newsDetail?.content != null && newsDetail!.content!.isNotEmpty) {
      _loadContent(newsDetail.content!);
    }
  }

  void _loadContent(String htmlContent) {
    if (_lastHtmlContent != htmlContent) {
      _lastHtmlContent = htmlContent;
      _webViewController.loadRequest(
        Uri.dataFromString(
          htmlContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
    }
  }

  void _reload() {
    // Reload từ controller
    final id = widget.controller.id;
    if (id != null && id.isNotEmpty) {
      widget.controller.getArticleDetail(id);
    } else {
      // Nếu không có id, reload WebView hiện tại
      if (_lastHtmlContent != null) {
        _webViewController.loadRequest(
          Uri.dataFromString(
            _lastHtmlContent!,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
        iconRightfirst: Icons.refresh,
        functionfirst: _reload,
      ),
      body: Obx(() {
        if (widget.controller.status == ControllerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final newsDetail = widget.controller.selectedNewsDetail.value;
        if (newsDetail == null) {
          return const Center(child: Text('No data'));
        }

        final htmlContent = newsDetail.content ?? '';
        if (htmlContent.isEmpty) {
          return const Center(child: Text('No content available'));
        }

        // Content sẽ được load tự động qua ever() listener
        return WebViewWidget(controller: _webViewController);
      }),
    );
  }
}

class _WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? token;

  const _WebViewScreen({required this.url, required this.title, this.token});

  @override
  State<_WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<_WebViewScreen> {
  late final WebViewController webViewController;
  late final Uri _initialUri;
  Map<String, String>? _requestHeaders;

  @override
  void initState() {
    print('widget.token: ${widget.token}');
    super.initState();
    _initialUri = Uri.parse(widget.url);
    _requestHeaders = (widget.token?.isNotEmpty ?? false)
        ? {'X-Token': widget.token!}
        : null;

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      );

    _loadInitialRequest();
  }

  void _reload() {
    _loadInitialRequest();
  }

  void _loadInitialRequest() {
    if (_requestHeaders != null && _requestHeaders!.isNotEmpty) {
      webViewController.loadRequest(_initialUri, headers: _requestHeaders!);
      return;
    }
    webViewController.loadRequest(_initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
        iconRightfirst: Icons.refresh,
        functionfirst: _reload,
      ),
      body: WebViewWidget(controller: webViewController),
    );
  }
}
