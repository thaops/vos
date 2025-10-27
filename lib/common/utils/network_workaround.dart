import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vos_flutter/common/Services/config.dart';

class NetworkWorkaround {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio();

    // Cấu hình timeout
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    dio.options.sendTimeout = Duration(seconds: 30);

    // Thêm interceptor để handle network issues
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("🌐 Request: ${options.method} ${options.uri}");
          print("🌐 Headers: ${options.headers}");
          handler.next(options);
        },
        onError: (error, handler) {
          print("❌ Network error: ${error.type}");
          print("❌ Error message: ${error.message}");

          if (error.type == DioExceptionType.connectionError) {
            // Thử với HTTP thay vì HTTPS
            if (error.requestOptions.uri.scheme == 'https') {
              final httpUrl = error.requestOptions.uri.toString().replaceFirst(
                'https://',
                'http://',
              );
              print("🔄 Retrying with HTTP: $httpUrl");

              // Retry với HTTP
              dio
                  .get(httpUrl)
                  .then((response) {
                    print("✅ HTTP retry successful");
                    handler.resolve(response);
                  })
                  .catchError((e) {
                    print("❌ HTTP retry also failed: $e");
                    handler.next(error);
                  });
              return;
            }
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Test kết nối với workaround
  static Future<Map<String, dynamic>> testConnectionWithWorkaround() async {
    final result = <String, dynamic>{
      'success': false,
      'method': '',
      'error': null,
      'responseTime': 0,
    };

    try {
      print("🔍 Testing connection with workarounds...");
      final stopwatch = Stopwatch()..start();

      // Thử HTTPS trước
      try {
        final response = await dio.get(
          'https://api-tcs-dev.azurewebsites.net/api/login/get-redirect-url?platform=0&type=1',
          options: Options(
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'TCS-E-Office/1.0',
            },
          ),
        );

        stopwatch.stop();
        result['success'] = true;
        result['method'] = 'HTTPS';
        result['responseTime'] = stopwatch.elapsedMilliseconds;
        print("✅ HTTPS connection successful");
        return result;
      } catch (e) {
        print("❌ HTTPS failed: $e");

        // Thử HTTP
        try {
          final response = await dio.get(
            'http://api-tcs-dev.azurewebsites.net/api/login/get-redirect-url?platform=0&type=1',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'TCS-E-Office/1.0',
              },
            ),
          );

          stopwatch.stop();
          result['success'] = true;
          result['method'] = 'HTTP';
          result['responseTime'] = stopwatch.elapsedMilliseconds;
          print("✅ HTTP connection successful");
          return result;
        } catch (e2) {
          print("❌ HTTP also failed: $e2");
          result['error'] = 'Both HTTPS and HTTP failed';
        }
      }
    } catch (e) {
      result['error'] = e.toString();
      print("❌ All connection attempts failed: $e");
    }

    return result;
  }

  /// Test với different user agents
  static Future<Map<String, dynamic>> testWithDifferentUserAgents() async {
    final userAgents = [
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'TCS-E-Office/1.0 (macOS)',
      'Flutter/3.0.0 (macOS)',
      'Dart/3.0.0 (macOS)',
    ];

    for (final userAgent in userAgents) {
      try {
        print("🔍 Testing with User-Agent: $userAgent");

        final response = await dio.get(
          'https://api-tcs-dev.azurewebsites.net/api/login/get-redirect-url?platform=0&type=1',
          options: Options(
            headers: {'Accept': 'application/json', 'User-Agent': userAgent},
          ),
        );

        print("✅ Success with User-Agent: $userAgent");
        return {
          'success': true,
          'userAgent': userAgent,
          'statusCode': response.statusCode,
        };
      } catch (e) {
        print("❌ Failed with User-Agent: $userAgent - $e");
      }
    }

    return {'success': false, 'error': 'All User-Agent attempts failed'};
  }
}
