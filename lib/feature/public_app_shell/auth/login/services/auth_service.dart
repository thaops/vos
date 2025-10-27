import 'package:dio/dio.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/login_request.dart';
import 'package:vos_flutter/feature/public_app_shell/auth/login/models/login_response.dart';

class AuthService {
  static const String _baseUrl = 'https://first-api.viags.vn';
  late final Dio _dio;

  AuthService() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('API: $object'),
      ),
    );
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/System/UserLogin',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Kết nối mạng bị timeout. Vui lòng thử lại.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Không thể kết nối đến server. Vui lòng kiểm tra mạng.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception('Tên đăng nhập hoặc mật khẩu không đúng.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Tài khoản bị khóa hoặc không có quyền truy cập.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Lỗi server. Vui lòng thử lại sau.');
      } else {
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
