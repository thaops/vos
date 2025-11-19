import 'package:dio/dio.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
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

  /// Hàm cũ - giữ lại để backward compatible
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

  /// Hàm mới - trả về ApiResult (khuyến nghị dùng)
  /// Login và trả về ApiResult<LoginData>
  Future<ApiResult<LoginData>> loginWithApiResult(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/System/UserLogin',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Kiểm tra resultCode từ LoginResponse
        if (loginResponse.isSuccess && loginResponse.data != null) {
          return ApiResult<LoginData>.success(
            loginResponse.data!,
            loginResponse.message,
          );
        } else {
          return ApiResult<LoginData>.error(
            loginResponse.message.isNotEmpty
                ? loginResponse.message
                : 'Đăng nhập thất bại',
            loginResponse.resultCode,
          );
        }
      } else {
        return ApiResult<LoginData>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      int? statusCode;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Kết nối mạng bị timeout. Vui lòng thử lại.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra mạng.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng.';
        statusCode = 401;
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'Tài khoản bị khóa hoặc không có quyền truy cập.';
        statusCode = 403;
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
        statusCode = 500;
      } else {
        errorMessage = 'Lỗi kết nối: ${e.message}';
        statusCode = e.response?.statusCode;
      }

      return ApiResult<LoginData>.error(errorMessage, statusCode);
    } catch (e) {
      return ApiResult<LoginData>.error('Lỗi không xác định: $e');
    }
  }
}
