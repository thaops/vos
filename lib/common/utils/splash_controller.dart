import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/common/services/ota_update_service.dart';
import 'package:vos_flutter/common/services/services.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

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

  /// Khởi tạo app - chỉ check auth nhanh, OTA chạy background
  Future<void> _initializeApp() async {
    try {
      loadingText.value = 'Đang kiểm tra đăng nhập...';

      // ✅ Bước 1: Check auth NGAY (chỉ đọc local storage - nhanh)
      final hasAuth = await _checkAuthQuick();

      if (hasAuth) {
        // ✅ Navigate ngay, không đợi OTA
        loadingText.value = 'Chào mừng trở lại!';
        await _navigateToMain();
      } else {
        await _navigateToLogin();
      }

      // ✅ Bước 2: OTA check chạy background (không block)
      _lazyCheckOTA();

      // ✅ Bước 3: Refresh token chạy background
      _lazyRefreshFirebaseToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in initialization: $e');
      }
      // Fallback: vẫn vào app
      await _navigateToLogin();
    }
  }

  /// Check auth nhanh (chỉ đọc local storage)
  Future<bool> _checkAuthQuick() async {
    try {
      // Check Google user từ Hive (nhanh)
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');
      if (userData != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          return true; // Có session hợp lệ
        }
      }

      // Check token cũ (nhanh)
      final service = await Services.create();
      final token = await service.getAccessToken();
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// OTA check chạy background với timeout
  void _lazyCheckOTA() {
    Future.microtask(() async {
      try {
        isCheckingUpdate.value = true;
        final updateResult = await _forceCheckAndUpdateSilent()
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => false,
            );

        if (updateResult) {
          // Có update → restart app sau khi user đã vào (delay 5s)
          Future.delayed(const Duration(seconds: 5), () {
            _otaService.restartAppIfNeeded();
          });
        }
      } catch (e) {
        // Silent fail
      } finally {
        isCheckingUpdate.value = false;
      }
    });
  }

  /// Refresh Firebase token background
  void _lazyRefreshFirebaseToken() {
    Future.microtask(() async {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.getIdToken(true).timeout(
                const Duration(seconds: 3),
                onTimeout: () => throw TimeoutException('Token refresh timeout'),
              );

          // Update Hive nếu cần
          final box = Hive.box('google_user_box');
          final userData = box.get('current_user');
          if (userData != null) {
            final updatedUser = GoogleUserDto.fromFirebaseUser(
              currentUser,
              await currentUser.getIdToken(),
            );
            await box.put('current_user', updatedUser.toJson());

            // Refresh ProfileController nếu có
            try {
              if (Get.isRegistered<ProfileController>()) {
                final profileController = Get.find<ProfileController>();
                profileController.refreshGoogleUser();
              }
            } catch (e) {
              // ProfileController chưa được tạo, không sao
            }
          }
        }
      } catch (e) {
        // Silent fail - không block app
      }
    });
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

  // ✅ REMOVED: _checkAuthenticationAndNavigate() và _checkGoogleAuth()
  // Đã thay thế bằng _checkAuthQuick() - chỉ check local storage, không refresh token

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
