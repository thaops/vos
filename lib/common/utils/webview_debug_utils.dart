import 'dart:io';
import 'package:dio/dio.dart';

class WebViewDebugUtils {
  static final Dio _dio = Dio();

  /// Test URL accessibility and get detailed response info
  static Future<Map<String, dynamic>> testUrl(String url) async {
    try {
      print('🔍 Testing URL: $url');

      final response = await _dio.get(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => true, // Accept all status codes
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
          },
        ),
      );

      final result = {
        'url': url,
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'headers': response.headers.map,
        'isSuccess':
            response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        'isRedirect':
            response.statusCode != null &&
            response.statusCode! >= 300 &&
            response.statusCode! < 400,
        'isClientError':
            response.statusCode != null &&
            response.statusCode! >= 400 &&
            response.statusCode! < 500,
        'isServerError':
            response.statusCode != null && response.statusCode! >= 500,
        'contentLength': response.headers.value('content-length'),
        'contentType': response.headers.value('content-type'),
        'finalUrl': response.redirects.isNotEmpty
            ? response.redirects.last.location.toString()
            : url,
      };

      print('📊 URL Test Results:');
      print('   Status Code: ${result['statusCode']}');
      print('   Status Message: ${result['statusMessage']}');
      print('   Is Success: ${result['isSuccess']}');
      print('   Content Type: ${result['contentType']}');
      print('   Content Length: ${result['contentLength']}');
      print('   Final URL: ${result['finalUrl']}');

      if (result['isClientError'] == true) {
        print('⚠️  Client Error (4xx) - Check URL and permissions');
      }
      if (result['isServerError'] == true) {
        print('⚠️  Server Error (5xx) - Check server status');
      }

      return result;
    } catch (e) {
      print('❌ URL Test Failed: $e');
      return {'url': url, 'error': e.toString(), 'isSuccess': false};
    }
  }

  /// Test multiple URLs commonly used in the app
  static Future<void> testCommonUrls() async {
    final urls = [
      'https://project.viags.vn',
      'https://project.viags.vn/Verify/Login',
      'https://project.viags.vn/Verify/Logout',
      'https://first-api.viags.vn/System/UserLogin',
    ];

    print('🧪 Testing common URLs...');
    for (final url in urls) {
      await testUrl(url);
      print('---');
    }
  }

  /// Check if URL is accessible from device
  static Future<bool> isUrlAccessible(String url) async {
    try {
      final result = await testUrl(url);
      return result['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }
}
