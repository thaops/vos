import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/binding/banner_binding.dart';
import 'package:vos_flutter/feature/home/binding/home_function_binding.dart';
import 'package:vos_flutter/feature/news/binding/news_binding.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';

/// MainBinding - Đăng ký tất cả dependencies cần thiết cho MainScreen.
///
/// Việc gắn binding vào route `/main` thay vì đăng ký trong widget `initState()`
/// giúp GetX quản lý lifecycle đúng cách, tránh bị SmartManagement dọn nhầm
/// controller khi điều hướng từ các route khác (ví dụ: `/profile/link-viags`).
class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Profile (cần cho navigation bar và user info)
    if (!Get.isRegistered<ProfileBinding>()) {
      ProfileBinding().dependencies();
    }

    // News (tab Tin tức)
    NewsBinding().dependencies();

    // Banner (section banner trên HomeTab)
    BannerBinding().dependencies();

    // Home Functions (section chức năng trên HomeTab)
    HomeFunctionBinding().dependencies();
  }
}
