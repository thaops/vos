import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final userAgent = _getUserAgent();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // setBackgroundColor không được hỗ trợ trên macOS
    if (!Platform.isMacOS) {
      _webViewController.setBackgroundColor(Colors.white);
    }

    _webViewController.setUserAgent(userAgent);

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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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
    final id = widget.controller.id;
    if (id != null && id.isNotEmpty) {
      widget.controller.getArticleDetail(id);
    } else {
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

  String _getUserAgent() {
    if (kIsWeb) {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else if (Platform.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    } else if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }
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
  bool _hasUnlinked = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initialUri = Uri.parse(widget.url);
    _requestHeaders = (widget.token?.isNotEmpty ?? false)
        ? {'X-Token': widget.token!}
        : null;

    // User agent phù hợp với platform
    final userAgent = _getUserAgent();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // setBackgroundColor không được hỗ trợ trên macOS
    if (!Platform.isMacOS) {
      webViewController.setBackgroundColor(Colors.white);
    }

    webViewController.setUserAgent(userAgent);

    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          _checkErrorUrl(url);
        },
        onPageFinished: (url) {
          _checkErrorUrl(url);
        },
      ),
    );

    _loadInitialRequest();
  }

  void _checkErrorUrl(String url) {
    if (_hasUnlinked) return;
  final isErrorUrl = url.contains('https://share-web.viags.vn/Error') ||
        url.contains('https://share-web.viags.vn/Error/Index');
    if (isErrorUrl) {
      _handleUnlinkViags();
    }
  }

   Future<void> _handleUnlinkViags() async {
    if (_hasUnlinked) return; // Tránh gọi nhiều lần
    _hasUnlinked = true;

    try {
      // Lấy ProfileController từ GetX
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        await profileController.unlinkViagsAccount(context);
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
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

  String _getUserAgent() {
    if (kIsWeb) {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else if (Platform.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    } else if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }
  }
}
