import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/profile/presentation/view/profile_screen.dart';
import 'package:vos_flutter/feature/home/view/home_tab.dart';
import 'package:vos_flutter/feature/news/presentation/view/news_screen.dart';
import 'package:vos_flutter/feature/news/binding/news_binding.dart';
import 'package:vos_flutter/feature/news/presentation/controller/news_controller.dart';
// import 'package:vos_flutter/common/services/navigation_service.dart'; // DISABLED: Module deleted

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Chỉ tạo controller nếu chưa tồn tại
    // Tránh tạo nhiều instance gây crash Syncfusion Chart
    if (!Get.isRegistered<ProfileController>()) {
      ProfileBinding().dependencies();
    }

    // Khởi tạo NewsBinding để đăng ký NewsController
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }

    // Khởi tạo _selectedIndex dựa trên isEmployee
    // Kiểm tra từ ProfileController nếu có, nếu không thì check profile trực tiếp
    bool isEmployee = false;
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        isEmployee = profileController.isEmployee.value;
      } else {
        // Fallback: check profile từ storage
        final profile = _storage.read('user_profile_data');
        isEmployee = profile != null;
      }
    } catch (e) {
      // Nếu có lỗi, mặc định là false
      isEmployee = false;
    }
    _selectedIndex = isEmployee
        ? 0
        : 1; // Nếu không phải nhân viên, bắt đầu từ WebView (index 1)

    // NavigationService.setTabChangeCallback(_onTabTapped); // DISABLED: Module deleted
  }

  // Lấy danh sách screens dựa trên isEmployee
  // QUAN TRỌNG: Check logout state để tránh rebuild HomeTab khi đang logout
  List<Widget> _getScreens() {
    try {
      // Check logout state trước
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.isLoggingOut) {
          // Đang logout → không trả về HomeTab để tránh rebuild
          return [const NewsScreen(), ProfileScreen()];
        }
      }
    } catch (e) {
      // Controller không tồn tại → có thể đang logout
      return [const NewsScreen(), ProfileScreen()];
    }

    // Kiểm tra từ ProfileController nếu có
    bool isEmployee = false;
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        isEmployee = profileController.isEmployee.value;
      } else {
        // Fallback: check profile từ storage
        final profile = _storage.read('user_profile_data');
        isEmployee = profile != null;
      }
    } catch (e) {
      isEmployee = false;
    }

    if (isEmployee) {
      return [const HomeTab(), const NewsScreen(), ProfileScreen()];
    } else {
      return [const NewsScreen(), ProfileScreen()];
    }
  }

  // Lấy index thực tế dựa trên isEmployee
  int _getActualIndex() {
    // Kiểm tra từ ProfileController nếu có
    bool isEmployee = false;
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        isEmployee = profileController.isEmployee.value;
      } else {
        // Fallback: check profile từ storage
        final profile = _storage.read('user_profile_data');
        isEmployee = profile != null;
      }
    } catch (e) {
      isEmployee = false;
    }

    if (isEmployee) {
      return _selectedIndex;
    } else {
      // Nếu không phải nhân viên:
      // _selectedIndex 0 (home) → _actualIndex 0 (webview)
      // _selectedIndex 1 (webview) → _actualIndex 0 (webview)
      // _selectedIndex 2 (profile) → _actualIndex 1 (profile)
      if (_selectedIndex == 0) {
        return 0; // Home → WebView (index 0)
      } else if (_selectedIndex == 1) {
        return 0; // WebView → WebView (index 0)
      } else {
        return 1; // Profile → Profile (index 1)
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      // Kiểm tra từ ProfileController nếu có
      bool isEmployee = false;
      try {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          isEmployee = profileController.isEmployee.value;
        } else {
          // Fallback: check profile từ storage
          final profile = _storage.read('user_profile_data');
          isEmployee = profile != null;
        }
      } catch (e) {
        isEmployee = false;
      }

      if (isEmployee) {
        // Nhân viên: index trực tiếp
        _selectedIndex = index;
      } else {
        // Không phải nhân viên:
        // index 0 (webview) → _selectedIndex 1
        // index 1 (profile) → _selectedIndex 2
        _selectedIndex = index + 1;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _getActualIndex(), children: _getScreens()),
      bottomNavigationBar: Builder(
        builder: (context) {
          // Kiểm tra từ ProfileController nếu có (reactive)
          return Obx(() {
            bool isEmployee = false;
            try {
              if (Get.isRegistered<ProfileController>()) {
                final profileController = Get.find<ProfileController>();
                isEmployee = profileController.isEmployee.value;
              } else {
                // Fallback: check profile từ storage
                final profile = _storage.read('user_profile_data');
                isEmployee = profile != null;
              }
            } catch (e) {
              isEmployee = false;
            }

          return Container(
            color: Colors.white,
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
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
                selectedIndex: isEmployee
                    ? _selectedIndex
                    : (_selectedIndex == 0 ? 0 : _selectedIndex - 1),
                onDestinationSelected: _onTabTapped,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                indicatorColor: AppColors.primary.withOpacity(0.8),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  // Chỉ hiển thị tab Home nếu là nhân viên
                  if (isEmployee)
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
                      Icons.article_outlined,
                      color: Colors.grey.shade600,
                    ),
                    selectedIcon: Icon(Icons.article, color: Colors.white),
                    label: 'Tin tức',
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
          });
        },
      ),
    );
  }
}
