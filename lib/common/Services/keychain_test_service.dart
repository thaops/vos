import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Service để test Keychain với Access Group
/// Giữ dữ liệu sau khi xoá app trên iOS
/// 
/// LƯU Ý QUAN TRỌNG nếu gặp lỗi -34018:
/// 1. Mở Xcode → Runner target → Signing & Capabilities
/// 2. Bật "Keychain Sharing" capability
/// 3. Thêm Access Group: vn.viags.vos (hoặc để Xcode tự thêm)
/// 4. Clean build: flutter clean && cd ios && pod install && cd ..
/// 5. Rebuild app trong Xcode (Product → Clean Build Folder, sau đó Build)
/// 6. Hoặc chạy: flutter run --release (không dùng hot reload)
class KeychainTestService {
  static const String _keyDeviceId = 'deviceID';
  static const String _accessGroup = 'vn.viags.vos'; // Bundle ID của app
  
  // Storage với Access Group (để giữ dữ liệu sau khi xoá app)
  final FlutterSecureStorage _storageWithGroup = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: _accessGroup, // Bắt buộc nếu muốn giữ dữ liệu khi xoá app
    ),
  );

  // Storage không có Access Group (fallback nếu lỗi -34018)
  final FlutterSecureStorage _storageWithoutGroup = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Track xem đã dùng fallback chưa (không có Access Group)
  bool _isUsingFallback = false;

  // Sử dụng storage có groupId, fallback về không có groupId nếu lỗi
  FlutterSecureStorage get _storage => 
      _isUsingFallback ? _storageWithoutGroup : _storageWithGroup;

  /// Lấy hoặc tạo Device ID từ Keychain
  /// Tự động fallback nếu lỗi -34018 (entitlements)
  Future<String> getDeviceId() async {
    try {
      String? deviceId = await _storageWithGroup.read(key: _keyDeviceId);

      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await _storageWithGroup.write(
          key: _keyDeviceId,
          value: deviceId,
        );
      }

      return deviceId;
    } catch (e) {
      // Nếu lỗi -34018 (entitlements), thử fallback không có groupId
      if (e.toString().contains('-34018') || e.toString().contains('entitlement')) {
        if (!_isUsingFallback) {
          debugPrint('⚠️ Lỗi -34018: Entitlements chưa được cấu hình đúng');
          debugPrint('⚠️ Đang thử fallback không có Access Group...');
          debugPrint('⚠️ LƯU Ý: Dữ liệu sẽ MẤT khi xoá app nếu dùng fallback');
          debugPrint('⚠️ Để fix: Xcode → Capabilities → Keychain Sharing → Bật và thêm Access Group');
          debugPrint('⚠️ Sau đó: flutter clean && cd ios && pod install && cd .. && flutter run');
          _isUsingFallback = true;
        }
        try {
          String? deviceId = await _storageWithoutGroup.read(key: _keyDeviceId);
          if (deviceId == null) {
            deviceId = const Uuid().v4();
            await _storageWithoutGroup.write(
              key: _keyDeviceId,
              value: deviceId,
            );
          }
          debugPrint('✅ Đã dùng fallback (không có Access Group)');
          return deviceId;
        } catch (e2) {
          debugPrint('❌ KeychainTestService.getDeviceId() fallback error: $e2');
          rethrow;
        }
      }
      debugPrint('❌ KeychainTestService.getDeviceId() error: $e');
      rethrow;
    }
  }

  /// Xóa Device ID từ Keychain
  Future<void> deleteDeviceId() async {
    try {
      await _storage.delete(key: _keyDeviceId);
    } catch (e) {
      debugPrint('❌ KeychainTestService.deleteDeviceId() error: $e');
    }
  }

  /// Test và print thông tin Keychain
  Future<void> testAndPrintKeychainInfo() async {
    if (kIsWeb || !Platform.isIOS) {
      debugPrint('⚠️ Keychain chỉ hỗ trợ iOS, bỏ qua test');
      return;
    }

    try {
      debugPrint('\n🔐 ========== KEYCHAIN TEST ==========');
      debugPrint('📱 Platform: iOS');
      debugPrint('🔑 Access Group: $_accessGroup');
      debugPrint('🔒 Accessibility: first_unlock_this_device');
      debugPrint('📝 Key: $_keyDeviceId');
      debugPrint('');

      // Lấy Device ID
      final deviceId = await getDeviceId();
      debugPrint('✅ Device ID từ Keychain: $deviceId');
      debugPrint('');

      // Kiểm tra lại bằng cách đọc trực tiếp (dùng cùng storage như getDeviceId)
      try {
        final readAgain = await _storage.read(key: _keyDeviceId);
        debugPrint('🔍 Đọc lại từ Keychain: ${readAgain ?? "null"}');
      } catch (e) {
        // Nếu lỗi khi đọc lại, thử fallback
        if (e.toString().contains('-34018') || e.toString().contains('entitlement')) {
          if (!_isUsingFallback) {
            _isUsingFallback = true;
          }
          final readAgain = await _storageWithoutGroup.read(key: _keyDeviceId);
          debugPrint('🔍 Đọc lại từ Keychain (fallback): ${readAgain ?? "null"}');
        } else {
          debugPrint('🔍 Lỗi khi đọc lại: $e');
        }
      }
      debugPrint('');

      // Kiểm tra Access Group
      debugPrint('📋 Thông tin Access Group:');
      if (_isUsingFallback) {
        debugPrint('   ⚠️ Đang dùng FALLBACK (không có Access Group)');
        debugPrint('   ⚠️ Dữ liệu sẽ MẤT khi xoá app');
        debugPrint('   ⚠️ Để fix: Xcode → Capabilities → Keychain Sharing → Bật');
        debugPrint('   ⚠️ Sau đó: flutter clean && cd ios && pod install && cd .. && flutter run');
      } else {
        debugPrint('   ✅ Đang dùng Access Group: $_accessGroup');
        debugPrint('   ✅ Dữ liệu sẽ tồn tại khi xoá app');
      }
      debugPrint('   - Accessibility: first_unlock_this_device');
      debugPrint('   - Lưu ý: Dữ liệu chỉ trên thiết bị này, không backup iCloud');
      debugPrint('');

      debugPrint('✅ ========== KEYCHAIN TEST COMPLETE ==========\n');
    } catch (e, stackTrace) {
      debugPrint('❌ ========== KEYCHAIN TEST ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('❌ ===========================================\n');
    }
  }
}

