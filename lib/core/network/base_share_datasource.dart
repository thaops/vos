import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

    // Fallback: lấy từ cache (GetStorage)
    try {
      final storage = GetStorage();

      final cachedProfile = storage.read('user_profile_data');
      if (cachedProfile is Map) {
        final token =
            (cachedProfile['Token'] as String?) ??
            (cachedProfile['token'] as String?);
        if (token != null && token.isNotEmpty) {
          return token;
        }
      }

      final accessToken = storage.read<String>('accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        return accessToken;
      }
    } catch (e) {
      print('Error getting token from cache: $e');
    }

    return '';
  }
}
