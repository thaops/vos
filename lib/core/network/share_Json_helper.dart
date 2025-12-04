import 'dart:convert';

class ShareJsonHelper {
  /// Decode JSON theo chuẩn Share Web (Data trả về dạng String JSON)
  static Map<String, dynamic>? decode(dynamic json) {
    if (json is String) {
      try {
        return jsonDecode(json);
      } catch (_) {
        return null;
      }
    }

    if (json is Map<String, dynamic>) return json;

    return null;
  }

  /// Lấy field từ JSON (int hoặc string → int)
  static int getInt(Map<String, dynamic>? map, String key) {
    if (map == null) return 0;

    final value = map[key];

    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
