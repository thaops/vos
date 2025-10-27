import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/Services/services.dart';
import 'package:vos_flutter/common/services/ota_update_service.dart';
import 'package:vos_flutter/router/app_router.dart';

class SplashController extends GetxController {
  final OTAUpdateService _otaService = OTAUpdateService();

  // Observable states
  final RxString loadingText = 'Đang khởi tạo...'.obs;
  final RxBool isCheckingUpdate = false.obs;
  final RxBool hasUpdate = false.obs;
  final RxString currentPatchNumber = 'Unknown'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Khởi tạo app với FORCE UPDATE flow (silent)
  Future<void> _initializeApp() async {
    try {
      // Bước 1: BẮT BUỘC check và update OTA (silent)
      loadingText.value = 'Đang khởi tạo...';
      isCheckingUpdate.value = true;

      // Bước 2: Force check và update OTA
      final updateResult = await _forceCheckAndUpdateSilent();

      if (updateResult) {
        // Có update và đã update xong → App sẽ restart
        if (kDebugMode) {
          print('🔄 App will restart after force update');
        }
        return;
      }

      // Bước 3: Không có update → Tiếp tục vào app
      await _checkAuthenticationAndNavigate();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in force update initialization: $e');
      }
      // Fallback: vẫn vào app (để tránh block user)
      await _navigateToLogin();
    }
  }

  /// BẮT BUỘC check và update OTA (silent - không hiển thị UI)
  Future<bool> _forceCheckAndUpdateSilent() async {
    try {
      // Lấy patch number hiện tại
      currentPatchNumber.value = await _otaService.getCurrentPatchNumber();

      if (kDebugMode) {
        print('📱 Current patch number: ${currentPatchNumber.value}');
      }

      // BẮT BUỘC check update (silent)
      final hasUpdateResult = await _otaService.hasMandatoryUpdateSilent();
      hasUpdate.value = hasUpdateResult;

      if (hasUpdateResult) {
        if (kDebugMode) {
          print(
            '🚨 FORCE UPDATE: Update available, performing silent update...',
          );
        }

        // BẮT BUỘC update (silent)
        final updateSuccess = await _otaService.forceCheckAndUpdateSilent();

        if (updateSuccess) {
          if (kDebugMode) {
            print('✅ FORCE UPDATE: Update completed, app will restart');
          }
          return true; // App sẽ restart
        } else {
          if (kDebugMode) {
            print('⚠️ FORCE UPDATE: Update failed, continuing to app');
          }
          return false; // Update fail, tiếp tục vào app
        }
      } else {
        if (kDebugMode) {
          print('✅ FORCE UPDATE: No update required');
        }
        return false; // Không có update, tiếp tục vào app
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FORCE UPDATE: Error - $e');
      }
      // Lỗi, vẫn cho vào app để tránh block user
      return false;
    } finally {
      isCheckingUpdate.value = false;
    }
  }

  /// Kiểm tra authentication và navigate
  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      loadingText.value = 'Đang kiểm tra đăng nhập...';

      final service = await Services.create();
      final token = await service.getAccessToken();

      if (token.isNotEmpty) {
        loadingText.value = 'Chào mừng trở lại!';
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToMain();
      } else {
        loadingText.value = 'Chuyển đến trang đăng nhập...';
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking authentication: $e');
      }
      await _navigateToLogin();
    }
  }

  /// Navigate to main app
  Future<void> _navigateToMain() async {
    await Get.offAllNamed(AppRouter.main);
  }

  /// Navigate to login
  Future<void> _navigateToLogin() async {
    await Get.offAllNamed(AppRouter.login);
  }

  /// Manual check for updates (có thể gọi từ settings)
  Future<void> checkForUpdates() async {
    try {
      isCheckingUpdate.value = true;
      loadingText.value = 'Đang kiểm tra cập nhật...';

      final hasUpdateResult = await _otaService
          .checkAndDownloadUpdateWithRestart();
      hasUpdate.value = hasUpdateResult;

      if (hasUpdateResult) {
        // App sẽ restart tự động ngay lập tức
      } else {
        Get.snackbar(
          'Cập nhật',
          'Ứng dụng đã là phiên bản mới nhất!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kiểm tra cập nhật: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCheckingUpdate.value = false;
    }
  }

  /// Restart app để apply patch
  Future<void> restartApp() async {
    await _otaService.restartAppIfNeeded();
  }
}
