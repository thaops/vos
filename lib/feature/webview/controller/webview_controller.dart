import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTabController extends GetxController {
  late WebViewController webViewController;
  final RxString currentUrl = ''.obs;
  final RxBool isLoading = true.obs;
  String? _lastLoadedUrl;
  DateTime? _lastLoadTime;

  // URL mặc định - có thể config
  final String defaultUrl = 'https://project.viags.vn';

  @override
  void onInit() {
    super.onInit();
    _initializeWebView();
  }

  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // Clear cache and cookies for fresh session
            webViewController.clearCache();
            webViewController.clearLocalStorage();

            final now = DateTime.now();
            // Chỉ log nếu URL khác hoặc đã qua ít nhất 1 giây
            if (_lastLoadedUrl != url ||
                _lastLoadTime == null ||
                now.difference(_lastLoadTime!).inSeconds > 1) {
              _lastLoadedUrl = url;
              _lastLoadTime = now;
            }
            isLoading.value = true;
            currentUrl.value = url;
          },
          onPageFinished: (url) {
            final now = DateTime.now();
            // Chỉ log nếu URL khác hoặc đã qua ít nhất 1 giây
            if (_lastLoadedUrl != url ||
                _lastLoadTime == null ||
                now.difference(_lastLoadTime!).inSeconds > 1) {
              _lastLoadedUrl = url;
              _lastLoadTime = now;
            }
            isLoading.value = false;
          },
          onWebResourceError: (error) {



            isLoading.value = false;
          },
          onNavigationRequest: (request) {
            if (currentUrl.value == request.url && isLoading.value) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(defaultUrl));
  }

  void loadUrl(String url) {
    if (currentUrl.value != url) {
      Future.delayed(const Duration(milliseconds: 200), () {
        webViewController.loadRequest(Uri.parse(url));
      });
    }
  }

  void goBack() {
    webViewController.goBack();
  }

  void goForward() {
    webViewController.goForward();
  }

  void reload() {
    webViewController.reload();
  }
}
