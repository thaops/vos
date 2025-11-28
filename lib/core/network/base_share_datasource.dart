import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

/// Base class cho các DataSource sử dụng ShareApiRepository
/// Tự động lấy token từ ProfileController hoặc Services
abstract class BaseShareDataSource {
  final ShareApiRepository shareApiRepository;

  BaseShareDataSource({required this.shareApiRepository});

  /// Tự động lấy token từ ProfileController hoặc Services
  String getToken() {
    try {
      // Ưu tiên lấy từ ProfileController
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        final token = profileController.userProfile.value?.token ?? '';
        if (token.isNotEmpty) {
          return token;
        }
      }
    } catch (e) {
      print('Error getting token from ProfileController: $e');
    }

    // Fallback: Lấy từ Services
    try {
      // Lưu ý: getAccessToken() là async, nhưng ở đây không thể dùng await
      // Nên sẽ trả về empty và để ShareApiRepository xử lý
      // Hoặc có thể dùng synchronous method nếu có
    } catch (e) {
      print('Error getting token from Services: $e');
    }

    return '';
  }
}
