import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/profile/view/profile_screen.dart';
import 'package:vos_flutter/feature/home/view/home_tab.dart';
import 'package:vos_flutter/feature/webview/view/multi_webview_tab.dart';
import 'package:vos_flutter/feature/webview/controller/multi_webview_controller.dart';
// import 'package:vos_flutter/common/services/navigation_service.dart'; // DISABLED: Module deleted

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(ProfileController());
    // NavigationService.setTabChangeCallback(_onTabTapped); // DISABLED: Module deleted
  }

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const MultiWebViewTab(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Obx(() {
        // Check if WebView is in full-screen mode
        bool isWebViewFullScreen = false;
        try {
          final webViewController = Get.find<MultiWebViewTabController>();
          isWebViewFullScreen = webViewController.isFullScreenMode.value;
        } catch (e) {
          // Controller not found, not in WebView tab
        }

        return isWebViewFullScreen
            ? const SizedBox.shrink()
            : Container(
                color: Colors.white,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    navigationBarTheme: NavigationBarThemeData(
                      labelTextStyle:
                          WidgetStateProperty.resolveWith<TextStyle?>((
                            Set<WidgetState> states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              );
                            }
                            return TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            );
                          }),
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onTabTapped,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    indicatorColor: AppColors.primary.withOpacity(0.8),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      NavigationDestination(
                        icon: Icon(
                          Icons.home_outlined,
                          color: Colors.grey.shade600,
                        ),
                        selectedIcon: Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                        ),
                        label: 'Trang chủ',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.web_outlined,
                          color: Colors.grey.shade600,
                        ),
                        selectedIcon: Icon(
                          Icons.web_rounded,
                          color: Colors.white,
                        ),
                        label: 'WebView',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.person_outline,
                          color: Colors.grey.shade600,
                        ),
                        selectedIcon: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                        ),
                        label: 'Cá nhân',
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
