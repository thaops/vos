import 'package:get_storage/get_storage.dart';

class Services {
  final GetStorage _storage = GetStorage();
  
  // Khóa để lưu trữ token trong GetStorage
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  Services();

  // Khởi tạo GetStorage và trả về instance của Services
  static Future<Services> create() async {
    await GetStorage.init();
    return Services();
  }

  // Lưu access token
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(_accessTokenKey, accessToken);
  }

  // Lấy access token
  Future<String> getAccessToken() async {
    // 1) Ưu tiên key chuẩn: accessToken
    final String? token = _storage.read<String>(_accessTokenKey);
    if (token != null && token.isNotEmpty) return token;

    // 2) Fallback: token nằm trong user_profile_data (VIAGS/VACS)
    final cachedProfile = _storage.read('user_profile_data');
    if (cachedProfile is Map) {
      final profileToken =
          (cachedProfile['Token'] as String?) ??
          (cachedProfile['token'] as String?);
      if (profileToken != null && profileToken.isNotEmpty) {
        return profileToken;
      }
    }

    // 3) Fallback legacy: user_token
    final legacyToken = _storage.read<String>('user_token');
    if (legacyToken != null && legacyToken.isNotEmpty) return legacyToken;

    return ''; // Trả về chuỗi rỗng nếu không có token
  }

  

  // Xóa access token
  Future<void> deleteAccessToken() async {
    await _storage.remove(_accessTokenKey);
    print('Deleted access token');
  }

  // Lưu refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  // Lấy refresh token
  Future<String?> getRefreshToken() async {
    String? token = _storage.read(_refreshTokenKey);
    return token; // Trả về null nếu không có refresh token
  }

  // Xóa refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.remove(_refreshTokenKey);
  }

  // Xóa cả access token và refresh token (ví dụ: khi đăng xuất)
  Future<void> clearTokens() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
  }
}