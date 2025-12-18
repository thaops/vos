import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification_intent.dart';

class NotificationParser {
  NotificationIntent? parse(OSNotificationClickEvent event) {
    final jsonContent = event.notification.additionalData?["JsonContent"];
    if (jsonContent == null) return null;

    final requestNumber = _extractRequestNumber(jsonContent);
    if (requestNumber == null) return null;

    final vRegId = int.tryParse(requestNumber);
    if (vRegId == null) return null;

    return TimeOffDetailIntent(vRegId);
  }

  String? _extractRequestNumber(dynamic jsonContent) {
    try {
      Map<String, dynamic>? jsonData;

      if (jsonContent is String) {
        jsonData = jsonDecode(jsonContent) as Map<String, dynamic>?;
      } else if (jsonContent is Map) {
        jsonData = jsonContent as Map<String, dynamic>?;
      }

      if (jsonData == null) return null;

      final customData = jsonData["custom_data"];
      if (customData is! Map) return null;

      return customData["REQUEST_NUMBER:"]?.toString() ??
          customData["request_number:"]?.toString() ??
          customData["REQUEST_NUMBER"]?.toString() ??
          customData["request_number"]?.toString();
    } catch (_) {
      return null;
    }
  }
}

