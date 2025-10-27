import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
// import 'package:shorebird_code_push/shorebird_code_push.dart';

class OTAUpdateService {
  static final OTAUpdateService _instance = OTAUpdateService._internal();
  factory OTAUpdateService() => _instance;
  OTAUpdateService._internal();

  // final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  /// Kiểm tra và tải patch OTA nếu có
  Future<bool> checkAndDownloadUpdate() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates...');
      }

      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('📦 New update available, downloading...');
        }

        // Tải update về
        await InAppUpdate.performImmediateUpdate();

        if (kDebugMode) {
          print('✅ Update downloaded successfully');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('✅ App is up to date');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking/downloading OTA update: $e');
      }
      return false;
    }
  }

  /// Kiểm tra và tải patch OTA với force restart
  Future<bool> checkAndDownloadUpdateWithRestart() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates with force restart...');
      }

      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('📦 New update available, downloading...');
        }

        // Tải update về và restart app
        await InAppUpdate.performImmediateUpdate();

        if (kDebugMode) {
          print('✅ Update downloaded, app will restart automatically');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('✅ App is up to date');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking/downloading OTA update: $e');
      }
      return false;
    }
  }

  /// Lấy thông tin version hiện tại
  Future<String> getCurrentPatchNumber() async {
    try {
      // TODO: Implement Shorebird v2.0+ API
      // final patchNumber = await _shorebirdCodePush.currentPatchNumber();
      // return patchNumber.toString();
      return '1';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting patch number: $e');
      }
      return 'Unknown';
    }
  }

  /// Kiểm tra xem có patch mới không (không tải)
  Future<bool> isUpdateAvailable() async {
    try {
      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update availability: $e');
      }
      return false;
    }
  }

  /// Restart app để apply patch (nếu cần)
  Future<void> restartAppIfNeeded() async {
    try {
      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('✅ Force restarting app to apply update...');
        }
        // Force restart để apply update ngay lập tức
        await SystemNavigator.pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update status: $e');
      }
    }
  }

  /// BẮT BUỘC check và update (silent - không hiển thị UI)
  Future<bool> forceCheckAndUpdateSilent() async {
    try {
      if (kDebugMode) {
        print('🚨 FORCE UPDATE: Silent checking for mandatory updates...');
      }

      // Check update
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('🚨 FORCE UPDATE: Update available, downloading silently...');
        }

        // BẮT BUỘC tải update (silent)
        await InAppUpdate.performImmediateUpdate();

        if (kDebugMode) {
          print('✅ FORCE UPDATE: Update downloaded, app will restart');
        }

        return true; // App sẽ restart
      } else {
        if (kDebugMode) {
          print('✅ FORCE UPDATE: No update required');
        }
        return false; // Không có update
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FORCE UPDATE: Error - $e');
      }
      return false; // Lỗi, không block user
    }
  }

  /// Check xem có update bắt buộc không (silent)
  Future<bool> hasMandatoryUpdateSilent() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking mandatory update: $e');
      }
      return false; // Lỗi = không có update bắt buộc
    }
  }
}
