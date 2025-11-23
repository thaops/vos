import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class Config {
  //https://napro-api.azurewebsites.net/api
  // https://coxe-api.azurewebsites.net/apiz
  // https://namphuong-dev.azurewebsites.net/
  static const String _baseUrlKey = 'base_url';
  static const String _manualEnvKey = 'manual_environment_set';
  
  // URL cho VACS (dùng cho các API chính: login, profile, tasks, ...)
  static String get baseUrlVasc {
    return dotenv.env['API_BASE_URL_VACS'] ??
        "https://share-api.viags.vn";
  }

  // URL cho NPP (dùng cho News API)
  static String get baseUrlNpp {
    return dotenv.env['API_BASE_URL_NPP'] ??
        "https://api-vos-dev.azurewebsites.net/api";
  }

  // Base URL chính - mặc định dùng VACS (cho các API chính)
  static String get baseUrl {
    final storage = GetStorage();
    String? savedUrl = storage.read<String>(_baseUrlKey);
    bool isManualEnv = storage.read<bool>(_manualEnvKey) ?? false;

    // Ưu tiên cao nhất: URL được set thủ công
    if (savedUrl != null && savedUrl.isNotEmpty && isManualEnv) {
      print("Using manual environment: $savedUrl");
      return savedUrl;
    }
    
    // Mặc định dùng VACS cho các API chính
    return baseUrlVasc;
  }

  static set baseUrl(String url) {
    final storage = GetStorage();
    // Luôn lưu URL được set thủ công, không bị ghi đè bởi awaiting flag
    storage.write(_baseUrlKey, url);
    // Đánh dấu là môi trường được set thủ công
    storage.write(_manualEnvKey, true);
  }

  /// Reset về logic mặc định (xóa URL thủ công)
  static void resetToAwaitingLogic() {
    final storage = GetStorage();
    storage.remove(_baseUrlKey);
    storage.remove(_manualEnvKey);
  }

  /// Kiểm tra xem có URL thủ công không
  static bool hasManualUrl() {
    final storage = GetStorage();
    final savedUrl = storage.read<String>(_baseUrlKey);
    final isManualEnv = storage.read<bool>(_manualEnvKey) ?? false;
    return savedUrl != null && savedUrl.isNotEmpty && isManualEnv;
  }

  /// Clear manual environment flag (chỉ xóa flag, giữ URL)
  static void clearManualEnvFlag() {
    final storage = GetStorage();
    storage.remove(_manualEnvKey);
  }
}
