import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Helper class để lấy thông tin thiết bị
class DeviceInfoHelper {
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;

    if (Platform.isAndroid) {
      final androidInfo = deviceInfo as AndroidDeviceInfo;
      return {
        'platform': 'Android',
        'deviceName': androidInfo.model,
        'osVersion': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      return {
        'platform': 'iOS',
        'deviceName': iosInfo.name,
        'osVersion': iosInfo.systemVersion,
      };
    }

    return {
      'platform': 'unknown',
      'deviceName': 'unknown',
      'osVersion': 'unknown',
    };
  }
}

