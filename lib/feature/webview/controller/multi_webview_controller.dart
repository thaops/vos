import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

    activeTabIndex.value = tabs.length - 1;
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

  WebViewTab({
    required this.id,
    required this.url,
    required this.title,
    this.parentId,
    List<String>? childrenIds,
  }) : childrenIds = childrenIds ?? [];

  void initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
            currentUrl.value = url;
          },
          onPageFinished: (url) {
            isLoading.value = false;
            _injectScrollListener();
          },
          onNavigationRequest: (request) {
            // Chỉ navigate trong tab hiện tại, không tạo tab mới
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
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

  void dispose() {
    // Cleanup nếu cần
  }
}
