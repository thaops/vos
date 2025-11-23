import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/common/services/services.dart';
import 'package:vos_flutter/common/shared/cache/my_id.dart';
import 'package:vos_flutter/common/shared/auth/controller_cache_clear.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOutClear extends GetxService {
  /// Clear tất cả dữ liệu và cache khi đăng xuất
  /// Bao gồm: token, profile, Google profile, Firebase Auth, Google Sign In
  Future<void> signOut() async {
    try {
      // 1. Sign out Firebase Auth
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print('⚠️ Error signing out Firebase Auth: $e');
      }

      // 2. Sign out Google (disconnect để xóa hoàn toàn)
      try {
        final googleSignIn = GoogleSignIn(scopes: ['email']);
        await googleSignIn.disconnect();
      } catch (e) {
        print('⚠️ Error signing out Google: $e');
      }

      // 3. Clear Hive (Google user data) - phải clear TRƯỚC để tránh auto-login
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
      } catch (e) {
        print('⚠️ Error clearing Google user from Hive: $e');
      }

      // 4. Clear access token và authentication data
      final Services services = await Services.create();
      await services.deleteAccessToken();

      // 5. Clear user ID và name cache
      final MyId _myId = await MyId.create();
      await _myId.deleteMyId();
      await _myId.deleteMyName();

      // 6. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 7. Clear GetStorage (local storage) nhưng giữ manual environment và VIAGS credentials
      final GetStorage storage = GetStorage();
      final String? savedBaseUrl = storage.read<String>('base_url');
      final bool? isManualEnv = storage.read<bool>('manual_environment_set');
      final String? savedViagsName = storage.read<String>('saved_viags_name');
      final String? savedViagsPassword = storage.read<String>('saved_viags_password');
      await storage.erase();

      // Khôi phục manual environment nếu có
      if (savedBaseUrl != null &&
          savedBaseUrl.isNotEmpty &&
          isManualEnv == true) {
        await storage.write('base_url', savedBaseUrl);
        await storage.write('manual_environment_set', true);
        print("Restored manual environment: $savedBaseUrl");
      }

      // Khôi phục VIAGS credentials (name và password) nếu có
      if (savedViagsName != null && savedViagsName.isNotEmpty) {
        await storage.write('saved_viags_name', savedViagsName);
        print("Restored saved VIAGS name");
      }
      if (savedViagsPassword != null && savedViagsPassword.isNotEmpty) {
        await storage.write('saved_viags_password', savedViagsPassword);
        print("Restored saved VIAGS password");
      }

      // 8. Navigate to login screen trước khi clear controllers
      if (Get.context != null) {
        Get.offAllNamed(AppRouter.login);
      }

      // 9. Delay để đảm bảo navigation hoàn tất trước khi clear
      await Future.delayed(Duration(milliseconds: 300));

      // 10. Clear controllers nhưng KHÔNG reset GetX hoàn toàn
      ControllerCacheClear.clearControllersOnly();

      // 11. Clear OneSignal cached token (nếu cần)
      // await OneSignalService.clearCachedToken();
    } catch (e) {
      // Log error nhưng vẫn navigate về login
      print('❌ Error during sign out: $e');

      // Fallback: vẫn clear data ngay cả khi sign out lỗi
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
        final Services services = await Services.create();
        await services.deleteAccessToken();
        final GetStorage storage = GetStorage();
        // Giữ lại VIAGS credentials
        final String? savedViagsName = storage.read<String>('saved_viags_name');
        final String? savedViagsPassword = storage.read<String>('saved_viags_password');
        await storage.erase();
        // Khôi phục credentials
        if (savedViagsName != null && savedViagsName.isNotEmpty) {
          await storage.write('saved_viags_name', savedViagsName);
        }
        if (savedViagsPassword != null && savedViagsPassword.isNotEmpty) {
          await storage.write('saved_viags_password', savedViagsPassword);
        }
      } catch (_) {
        // Ignore cleanup errors
      }

      // Vẫn navigate về login ngay cả khi có lỗi
      if (Get.context != null) {
        Get.offAllNamed(AppRouter.login);
      }
    }
  }

  /// Clear chỉ cache mà không đăng xuất
  Future<void> clearCacheOnly() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear GetStorage nhưng giữ manual environment và VIAGS credentials
      final GetStorage storage = GetStorage();
      final String? savedBaseUrl = storage.read<String>('base_url');
      final bool? isManualEnv = storage.read<bool>('manual_environment_set');
      final String? savedViagsName = storage.read<String>('saved_viags_name');
      final String? savedViagsPassword = storage.read<String>('saved_viags_password');
      await storage.erase();

      // Khôi phục manual environment nếu có
      if (savedBaseUrl != null &&
          savedBaseUrl.isNotEmpty &&
          isManualEnv == true) {
        await storage.write('base_url', savedBaseUrl);
        await storage.write('manual_environment_set', true);
        print("Restored manual environment in clearCacheOnly: $savedBaseUrl");
      }

      // Khôi phục VIAGS credentials nếu có
      if (savedViagsName != null && savedViagsName.isNotEmpty) {
        await storage.write('saved_viags_name', savedViagsName);
      }
      if (savedViagsPassword != null && savedViagsPassword.isNotEmpty) {
        await storage.write('saved_viags_password', savedViagsPassword);
      }

      // Clear user cache
      final MyId _myId = await MyId.create();
      await _myId.deleteMyId();
      await _myId.deleteMyName();

      // Clear controllers cache (không reset GetX)
      ControllerCacheClear.clearControllersOnly();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Clear chỉ leave management cache
  Future<void> clearLeaveCache() async {
    try {
      ControllerCacheClear.clearLeaveControllers();
    } catch (e) {
      print('Error clearing leave cache: $e');
    }
  }

  /// Clear chỉ user cache
  Future<void> clearUserCache() async {
    try {
      ControllerCacheClear.clearUserControllers();
    } catch (e) {
      print('Error clearing user cache: $e');
    }
  }
}
