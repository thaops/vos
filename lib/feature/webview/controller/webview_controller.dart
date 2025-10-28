import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vos_flutter/common/utils/webview_debug_utils.dart';

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
    _testUrlBeforeLoad();
    _initializeWebView();
  }

  void _testUrlBeforeLoad() async {
    print('🧪 Pre-testing default URL...');
    await WebViewDebugUtils.testUrl(defaultUrl);
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
              print('WebView started loading: $url');
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
              print('WebView finished loading: $url');
              _lastLoadedUrl = url;
              _lastLoadTime = now;
            }
            isLoading.value = false;
          },
          onWebResourceError: (error) {
            print('❌ WebView Error Details:');
            print('   Description: ${error.description}');
            print('   Error Code: ${error.errorCode}');
            print('   Error Type: ${error.errorType}');
            print('   Is For Main Frame: ${error.isForMainFrame}');
            print('   Current URL: ${currentUrl.value}');

            // Handle specific error types
            if (error.description.contains('ERR_HTTP_RESPONSE_CODE_FAILURE')) {
              print('🚨 HTTP Response Code Failure detected!');
              print(
                '   This usually means server returned 4xx or 5xx status code',
              );
              print(
                '   Check server logs or try accessing URL directly in browser',
              );

              // Test URL directly to get more details
              if (currentUrl.value.isNotEmpty) {
                print('🔍 Testing URL directly...');
                WebViewDebugUtils.testUrl(currentUrl.value);
              }
            }

            isLoading.value = false;
          },
          onNavigationRequest: (request) {
            print('WebView navigation request: ${request.url}');

            // Prevent duplicate navigation to same URL
            if (currentUrl.value == request.url && isLoading.value) {
              print('Preventing duplicate navigation to: ${request.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(defaultUrl));
  }

  void loadUrl(String url) {
    // Thêm delay nhỏ để tránh load quá nhanh và prevent duplicate
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
