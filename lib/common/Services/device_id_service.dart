import 'package:flutter/services.dart';

class DeviceIdService {
  static const platform = MethodChannel('device_id_channel');

  static Future<String?> getAndroidId() async {
    try {
      final id = await platform.invokeMethod<String>('getAndroidId');
      return id;
    } catch (e) {
      print("Error getAndroidId: $e");
      return null;
    }
  }
}

