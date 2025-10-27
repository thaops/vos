import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controller/multi_webview_controller.dart';

class MultiWebViewTab extends StatelessWidget {
  const MultiWebViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MultiWebViewTabController());

    return Obx(
      () => Scaffold(
        appBar: controller.isAppBarVisible.value
            ? AppBar(
                title: Text(
                  controller.tabs.isNotEmpty
                      ? controller.tabs[controller.activeTabIndex.value].title
                      : 'WebView',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                backgroundColor: const Color(0xFF006884),
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  // Full-screen toggle button
                  IconButton(
                    icon: Icon(
                      controller.isFullScreenMode.value
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.toggleFullScreenMode(),
                    tooltip: controller.isFullScreenMode.value
                        ? 'Thoát toàn màn hình'
                        : 'Toàn màn hình',
                  ),
                  // Tab switcher button
                  IconButton(
                    icon: const Icon(Icons.tab_rounded, color: Colors.white),
                    onPressed: () => _showTabSwitcher(context, controller),
                    tooltip: 'Xem tất cả tabs',
                  ),
                  // New tab button
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () {
                      if (controller.mainTabId != null) {
                        controller.addChildTab(
                          controller.mainTabId!,
                          'https://project.viags.vn',
                          'Tab mới',
                        );
                      }
                    },
                    tooltip: 'Tạo tab mới',
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (controller.tabs.isNotEmpty) {
                        final activeTab =
                            controller.tabs[controller.activeTabIndex.value];
                        activeTab.webViewController.reload();
                      }
                    },
                    tooltip: 'Làm mới trang',
                  ),
                ],
              )
            : null,
        body: Obx(() {
          if (controller.tabs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeTab = controller.tabs[controller.activeTabIndex.value];

          return Stack(
            children: [
              // WebView with scroll detection
              GestureDetector(
                onTap: () {
                  // Tap to show AppBar in full-screen mode
                  if (controller.isFullScreenMode.value) {
                    controller.showAppBar();
                  }
                },
                child: WebViewWidget(controller: activeTab.webViewController),
              ),

              // Loading indicator
              if (activeTab.isLoading.value)
                const Center(child: CircularProgressIndicator()),

              // Full-screen mode indicator
              if (controller.isFullScreenMode.value &&
                  !controller.isAppBarVisible.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Chạm để hiện thanh điều hướng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.fullscreen_exit_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  controller.toggleFullScreenMode(),
                              tooltip: 'Thoát toàn màn hình',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showTabSwitcher(
    BuildContext context,
    MultiWebViewTabController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tabs (${controller.tabs.length})',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderButton(
                        icon: Icons.add_rounded,
                        onPressed: () {
                          if (controller.mainTabId != null) {
                            controller.addChildTab(
                              controller.mainTabId!,
                              'https://project.viags.vn',
                              'Tab mới',
                            );
                          }
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 12.w),
                      _buildHeaderButton(
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.pop(context),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Tabs list
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: controller.tabs.length,
                  itemBuilder: (context, index) {
                    final tab = controller.tabs[index];
                    final isActive = index == controller.activeTabIndex.value;
                    final isParent = tab.parentId == null;
                    final isMainTab = tab.id == controller.mainTabId;

                    return Container(
                      margin: EdgeInsets.only(
                        left: isParent ? 0 : 20.w, // Indent cho tab con
                        bottom: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.grey[50] : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isActive
                              ? Colors.grey[400]!
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: () {
                            controller.switchToTab(index);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                // Favicon/Icon
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: isMainTab
                                        ? Colors.blue[600]
                                        : isActive
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    isParent
                                        ? Icons.web_rounded
                                        : Icons.subdirectory_arrow_right,
                                    color: isMainTab
                                        ? Colors.white
                                        : isActive
                                        ? Colors.white
                                        : Colors.grey[600],
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tab.title,
                                        style: TextStyle(
                                          fontWeight: isActive
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isActive
                                              ? Colors.grey[900]
                                              : Colors.grey[800],
                                          fontSize: 15.sp,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        isParent
                                            ? '${tab.childrenIds.length} tab con'
                                            : tab.currentUrl.value,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12.sp,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Close button - chỉ hiện cho tab con
                                if (!isMainTab)
                                  _buildCloseButton(
                                    onPressed: () {
                                      controller.closeTab(index);
                                      if (controller.tabs.isEmpty) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: isSecondary ? Colors.grey[100] : Colors.grey[900],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: onPressed,
          child: Icon(
            icon,
            color: isSecondary ? Colors.grey[600] : Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton({required VoidCallback onPressed}) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.r),
          onTap: onPressed,
          child: Icon(
            Icons.close_rounded,
            size: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
