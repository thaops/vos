import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MultiWebViewTabController extends GetxController {
  final RxList<WebViewTab> tabs = <WebViewTab>[].obs;
  final RxInt activeTabIndex = 0.obs;
  final RxBool isAppBarVisible = true.obs;
  final RxBool isFullScreenMode = false.obs;
  final RxDouble scrollOffset = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _addMainTab('https://project.viags.vn', 'Trang chủ');
  }

  void _addMainTab(String url, String title) {
    final mainTab = WebViewTab(
      id: 'main_tab',
      url: url,
      title: title,
      parentId: null, // Tab chính không có parent
    );
    mainTab.initializeWebView();
    tabs.add(mainTab);
    activeTabIndex.value = 0;
  }

  void _addNewTab(String url, String title) {
    final newTab = WebViewTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title,
    );

    newTab.initializeWebView();
    tabs.add(newTab);
    activeTabIndex.value = tabs.length - 1;
  }

  // Get main tab ID
  String? get mainTabId =>
      tabs.firstWhereOrNull((tab) => tab.parentId == null)?.id;

  // Add child tab to a parent
  void addChildTab(String parentId, String url, String title) {
    final childTab = WebViewTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title,
      parentId: parentId,
    );
    childTab.initializeWebView();
    tabs.add(childTab);

    // Update parent tab's children list
    final parentTab = tabs.firstWhere((tab) => tab.id == parentId);
    parentTab.childrenIds.add(childTab.id);

    // Giữ nguyên tab hiện tại, không chuyển đến tab mới
    // activeTabIndex.value = tabs.length - 1; // Removed
  }

  void addNewTab(String url, String title) {
    _addNewTab(url, title);
  }

  void switchToTab(int index) {
    if (index >= 0 && index < tabs.length) {
      activeTabIndex.value = index;
    }
  }

  void closeTab(int index) {
    if (index >= 0 && index < tabs.length) {
      final tab = tabs[index];

      // Không cho phép xóa tab chính
      if (tab.parentId == null) {
        return;
      }

      // Xóa tab con
      tab.dispose();
      tabs.removeAt(index);

      // Cập nhật parent tab's children list
      final parentTab = tabs.firstWhere((t) => t.id == tab.parentId);
      parentTab.childrenIds.remove(tab.id);

      // Adjust active tab index
      if (activeTabIndex.value >= tabs.length) {
        activeTabIndex.value = tabs.length - 1;
      } else if (activeTabIndex.value > index) {
        activeTabIndex.value--;
      }
    }
  }

  // Close tab by ID (for cascade delete)
  void closeTabById(String tabId) {
    final index = tabs.indexWhere((tab) => tab.id == tabId);
    if (index != -1) {
      closeTab(index);
    }
  }

  void onNavigationRequest(NavigationRequest request) {
    // Không tự tạo tab mới, chỉ navigate trong tab hiện tại
    final currentTab = tabs[activeTabIndex.value];
    currentTab.webViewController.loadRequest(Uri.parse(request.url));
  }

  void toggleFullScreenMode() {
    isFullScreenMode.value = !isFullScreenMode.value;
    if (isFullScreenMode.value) {
      isAppBarVisible.value = false;
      // Hide status bar and navigation bar for true full-screen
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } else {
      isAppBarVisible.value = true;
      // Show status bar and navigation bar
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  // Method để ẩn/hiện bottom navigation từ MainScreen
  void setBottomNavVisibility(bool visible) {
    // This will be called from MainScreen to hide/show bottom nav
    // We'll implement this in MainScreen
  }

  void updateScrollOffset(double offset) {
    scrollOffset.value = offset;

    // Auto-hide AppBar logic
    if (!isFullScreenMode.value) {
      if (offset > 100 && isAppBarVisible.value) {
        // Scroll down - hide AppBar
        isAppBarVisible.value = false;
      } else if (offset < 50 && !isAppBarVisible.value) {
        // Scroll up - show AppBar
        isAppBarVisible.value = true;
      }
    }
  }

  void showAppBar() {
    if (isFullScreenMode.value) {
      // Temporarily show AppBar in full-screen mode
      isAppBarVisible.value = true;
      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (isFullScreenMode.value) {
          isAppBarVisible.value = false;
        }
      });
    } else {
      isAppBarVisible.value = true;
    }
  }

  @override
  void onClose() {
    for (var tab in tabs) {
      tab.dispose();
    }
    super.onClose();
  }
}

class WebViewTab {
  final String id;
  final String url;
  final String title;
  final String? parentId; // null = tab cha, có value = tab con
  final List<String> childrenIds; // Danh sách tab con
  late WebViewController webViewController;
  final RxBool isLoading = true.obs;
  final RxString currentUrl = ''.obs;
  String? _lastLoadedUrl;
  DateTime? _lastLoadTime;

  WebViewTab({
    required this.id,
    required this.url,
    required this.title,
    this.parentId,
    List<String>? childrenIds,
  }) : childrenIds = childrenIds ?? [];

  void initializeWebView() async {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'ScrollChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = message.message;
            if (data.startsWith('scroll:')) {
              final scrollData = data.substring(7);
              final parts = scrollData.split(',');
              if (parts.length >= 2) {
                final scrollTop = double.tryParse(parts[0]) ?? 0.0;

                final controller = Get.find<MultiWebViewTabController>();
                controller.updateScrollOffset(scrollTop);
              }
            }
          } catch (e) {
            // Ignore parsing errors
          }
        },
      )
      ..addJavaScriptChannel(
        'LoginChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final token = message.message;
            print('✅ Received token from web: $token');
            // TODO: Lưu token vào storage hoặc gửi lên server
            // Ví dụ: SharedPreferences, Hive, hoặc API call
          } catch (e) {
            print('❌ Error handling login token: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // ✅ KHÔNG clear cache và localStorage trong onPageStarted
            // Chỉ log thông tin
            final now = DateTime.now();
            if (_lastLoadedUrl != url ||
                _lastLoadTime == null ||
                now.difference(_lastLoadTime!).inSeconds > 1) {
              print('MultiWebView started loading: $url');
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
              print('MultiWebView finished loading: $url');
              _lastLoadedUrl = url;
              _lastLoadTime = now;
            }
            isLoading.value = false;
            _injectScrollListener();

            // ✅ Kiểm tra cookies sau khi load xong (đặc biệt sau login)
            _checkCookies();

            // ✅ Debug chi tiết nếu URL chứa login hoặc home
            if (url.contains('login') ||
                url.contains('home') ||
                url.contains('dashboard')) {
              debugLoginProcess();
            }
          },
          onWebResourceError: (error) {
            print('❌ MultiWebView Error Details:');
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
            }

            isLoading.value = false;
          },
          onNavigationRequest: (request) {
            print('MultiWebView navigation request: ${request.url}');

            // Prevent duplicate navigation to same URL
            if (currentUrl.value == request.url && isLoading.value) {
              print(
                'Preventing duplicate MultiWebView navigation to: ${request.url}',
              );
              return NavigationDecision.prevent;
            }

            // Chỉ navigate trong tab hiện tại, không tạo tab mới
            return NavigationDecision.navigate;
          },
        ),
      );

    // ✅ Chỉ clear cache một lần duy nhất khi khởi tạo
    await webViewController.clearCache();
    await webViewController.clearLocalStorage();

    // ✅ Bật CookieManager để lưu trữ cookies đúng cách
    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      print('🍪 Android WebView debugging enabled');
    }

    // Load URL
    webViewController.loadRequest(Uri.parse(url));
  }

  void _injectScrollListener() {
    // Inject JavaScript to detect scroll events
    webViewController.runJavaScript('''
      let lastScrollTop = 0;
      let ticking = false;
      
      function updateScrollPosition() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const direction = scrollTop > lastScrollTop ? 'down' : 'up';
        
        // Send scroll data to Flutter via JavaScript channel
        ScrollChannel.postMessage('scroll:' + scrollTop + ',' + direction);
        
        lastScrollTop = scrollTop;
        ticking = false;
      }
      
      function requestTick() {
        if (!ticking) {
          requestAnimationFrame(updateScrollPosition);
          ticking = true;
        }
      }
      
      window.addEventListener('scroll', requestTick, { passive: true });
    ''');
  }

  // ✅ Kiểm tra cookies sau khi load xong
  void _checkCookies() {
    webViewController
        .runJavaScriptReturningResult('document.cookie')
        .then((value) {
          final cookies = value.toString();
          print('🍪 Current cookies: $cookies');

          // Kiểm tra các loại session cookie phổ biến
          if (cookies.contains('ASP.NET_SessionId') ||
              cookies.contains('PHPSESSID') ||
              cookies.contains('JSESSIONID') ||
              cookies.contains('session_id') ||
              cookies.contains('token') ||
              cookies.contains('auth')) {
            print('✅ Found authentication cookies!');

            // Log chi tiết session cookie
            if (cookies.contains('ASP.NET_SessionId')) {
              final sessionMatch = RegExp(
                r'ASP\.NET_SessionId=([^;]+)',
              ).firstMatch(cookies);
              if (sessionMatch != null) {
                print('🔑 ASP.NET Session ID: ${sessionMatch.group(1)}');
              }
            }
          } else {
            print('⚠️ No authentication cookies found');
            print('💡 This might be why login shows "Invalid Data"');
          }
        })
        .catchError((error) {
          print('❌ Error checking cookies: $error');
        });
  }

  // ✅ Debug method để kiểm tra chi tiết quá trình login
  void debugLoginProcess() {
    print('🔍 === DEBUG LOGIN PROCESS ===');

    // Kiểm tra cookies hiện tại
    _checkCookies();

    // Kiểm tra localStorage
    webViewController
        .runJavaScriptReturningResult('localStorage.getItem("user")')
        .then((value) {
          print('💾 localStorage user: $value');
        })
        .catchError((error) {
          print('❌ Error checking localStorage: $error');
        });

    // Kiểm tra sessionStorage
    webViewController
        .runJavaScriptReturningResult('sessionStorage.getItem("auth")')
        .then((value) {
          print('🗂️ sessionStorage auth: $value');
        })
        .catchError((error) {
          print('❌ Error checking sessionStorage: $error');
        });

    print('🔍 === END DEBUG ===');
  }

  void dispose() {
    // Cleanup nếu cần
  }
}
