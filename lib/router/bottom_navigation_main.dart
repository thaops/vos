import 'dart:io' show Platform;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

    // Mặc định _selectedIndex = 0
    // Sẽ được cập nhật lại trong build() khi ProfileController load xong
    _selectedIndex = 0;

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
      return [
        const HomeTab(),
        const NewsScreen(),
        ProfileScreen(),
      ];
    } else {
      return [const NewsScreen(), ProfileScreen()];
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
        // Nhân viên: index trực tiếp [HomeTab(0), NewsScreen(1), ProfileScreen(2)]
        _selectedIndex = index;
      } else {
        // Không phải nhân viên: [NewsScreen(0), ProfileScreen(1)]
        // NavigationBar chỉ có 2 tab: News (0) và Profile (1)
        // Map: News (0) → _selectedIndex = 0, Profile (1) → _selectedIndex = 1
        _selectedIndex = index;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb && Platform.isMacOS;

    return Scaffold(
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(78),
              child: _buildNavigationBar(isTop: true),
            )
          : null,
      body: Builder(
        builder: (context) {
          // Reactive với isEmployee để đảm bảo đồng bộ
          return Obx(() {
            bool isEmployee = false;
            try {
              if (Get.isRegistered<ProfileController>()) {
                final profileController = Get.find<ProfileController>();
                isEmployee = profileController.isEmployee.value;
              } else {
                final profile = _storage.read('user_profile_data');
                isEmployee = profile != null;
              }
            } catch (e) {
              isEmployee = false;
            }

            final screens = _getScreens();
            // Tính toán index thực tế dựa trên _selectedIndex và isEmployee
            // Employee: [HomeTab(0), NewsScreen(1), ProfileScreen(2)]
            // Non-employee: [NewsScreen(0), ProfileScreen(1)]
            int actualIndex;
            if (isEmployee) {
              actualIndex = _selectedIndex.clamp(0, screens.length - 1);
            } else {
              actualIndex = _selectedIndex.clamp(0, screens.length - 1);
            }

            // Đảm bảo actualIndex không vượt quá số lượng screens
            actualIndex = actualIndex.clamp(0, screens.length - 1);

            return IndexedStack(index: actualIndex, children: screens);
          });
        },
      ),
      bottomNavigationBar:
          isDesktop ? null : _buildNavigationBar(isTop: false),
    );
  }

  Widget _buildNavigationBar({required bool isTop}) {
    return Builder(
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

          // Nếu là macOS (isTop = true) → dùng style tab bar desktop
          if (isTop) {
            return SafeArea(
              top: true,
              bottom: false,
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (isEmployee)
                      _DesktopTabItem(
                        label: 'Trang chủ',
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        selected: _selectedIndex == 0,
                        onTap: () => _onTabTapped(0),
                      ),
                    _DesktopTabItem(
                      label: 'Tin tức',
                      icon: Icons.article_outlined,
                      selectedIcon: Icons.article,
                      selected: _selectedIndex == (isEmployee ? 1 : 0),
                      onTap: () => _onTabTapped(isEmployee ? 1 : 0),
                    ),
                    _DesktopTabItem(
                      label: 'Cá nhân',
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person_rounded,
                      selected: _selectedIndex == (isEmployee ? 2 : 1),
                      onTap: () => _onTabTapped(isEmployee ? 2 : 1),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            top: isTop,
            bottom: !isTop,
            child: Container(
              color: Colors.white,
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                      (Set<WidgetState> states) {
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
                      },
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: isEmployee
                      ? _selectedIndex.clamp(
                          0, 2) // Employee: 0 (Home), 1 (News), 2 (Profile)
                      : _selectedIndex.clamp(
                          0, 1), // Non-employee: 0 (News), 1 (Profile)
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
            ),
          );
        });
      },
    );
  }
}

class _DesktopTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
