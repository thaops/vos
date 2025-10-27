import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTabController extends GetxController {
  late WebViewController webViewController;
  final RxString currentUrl = ''.obs;
  final RxBool isLoading = true.obs;

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
            currentUrl.value = url;
          },
          onPageFinished: (url) {
            isLoading.value = false;
          },
        ),
      )
      ..loadRequest(Uri.parse(defaultUrl));
  }

  void loadUrl(String url) {
    webViewController.loadRequest(Uri.parse(url));
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
