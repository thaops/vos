import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class KeychainTestService {
  static const String _keyDeviceId = 'deviceID';
  static const String _accessGroup = 'vn.viags.vos';

  final FlutterSecureStorage _storageWithGroup = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      groupId: _accessGroup,
    ),
  );

  final FlutterSecureStorage _storageWithoutGroup = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  bool _isUsingFallback = false;

  FlutterSecureStorage get _storage =>
      _isUsingFallback ? _storageWithoutGroup : _storageWithGroup;

  Future<String> getDeviceId() async {
    try {
      String? deviceId = await _storageWithGroup.read(key: _keyDeviceId);

      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await _storageWithGroup.write(key: _keyDeviceId, value: deviceId);
      }

      return deviceId;
    } catch (e) {
      if (e.toString().contains('-34018') ||
          e.toString().contains('entitlement')) {
        if (!_isUsingFallback) {
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
          return deviceId;
        } catch (e2) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> deleteDeviceId() async {
    try {
      await _storage.delete(key: _keyDeviceId);
    } catch (e) {
      // ignore
    }
  }

  Future<void> testAndPrintKeychainInfo() async {
    if (kIsWeb || !Platform.isIOS) {
      return;
    }

    try {
      await getDeviceId();

      try {
        await _storage.read(key: _keyDeviceId);
      } catch (e) {
        if (e.toString().contains('-34018') ||
            e.toString().contains('entitlement')) {
          if (!_isUsingFallback) {
            _isUsingFallback = true;
          }
          await _storageWithoutGroup.read(key: _keyDeviceId);
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
