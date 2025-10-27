import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/Services/api_endpoints.dart';
import 'package:vos_flutter/common/utils/network_workaround.dart';

class NetworkTestUtils {
  static final Dio _dio = Dio();

  /// Test kết nối cơ bản đến server
  static Future<bool> testBasicConnection() async {
    try {
      print("🔍 Testing basic connection...");
      final result = await InternetAddress.lookup(
        'api-tcs-dev.azurewebsites.net',
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("✅ DNS resolution successful");
        return true;
      }
    } catch (e) {
      print("❌ DNS resolution failed: $e");
    }
    return false;
  }

  /// Test HTTP connection với timeout ngắn
  static Future<Map<String, dynamic>> testHttpConnection() async {
    final result = <String, dynamic>{
      'success': false,
      'error': null,
      'responseTime': 0,
      'statusCode': null,
    };

    try {
      print("🌐 Testing HTTP connection...");
      final stopwatch = Stopwatch()..start();

      final response = await _dio.get(
        ApiEndpoints.loginUrlMicrosoft(0, 1),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      stopwatch.stop();

      result['success'] = true;
      result['responseTime'] = stopwatch.elapsedMilliseconds;
      result['statusCode'] = response.statusCode;

      print(
        "✅ HTTP connection successful: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)",
      );
    } catch (e) {
      result['error'] = e.toString();
      print("❌ HTTP connection failed: $e");
    }

    return result;
  }

  /// Test kết nối với retry logic
  static Future<Map<String, dynamic>> testConnectionWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    final result = <String, dynamic>{
      'success': false,
      'attempts': 0,
      'totalTime': 0,
      'errors': <String>[],
    };

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < maxRetries; i++) {
      result['attempts'] = i + 1;

      try {
        print("🔄 Attempt ${i + 1}/$maxRetries...");

        final response = await _dio.get(ApiEndpoints.loginUrlMicrosoft(0, 1));

        if (response.statusCode == 200) {
          result['success'] = true;
          stopwatch.stop();
          result['totalTime'] = stopwatch.elapsedMilliseconds;
          print("✅ Connection successful on attempt ${i + 1}");
          break;
        }
      } catch (e) {
        result['errors'].add("Attempt ${i + 1}: $e");
        print("❌ Attempt ${i + 1} failed: $e");

        if (i < maxRetries - 1) {
          print("⏳ Waiting ${retryDelay.inSeconds}s before retry...");
          await Future.delayed(retryDelay);
        }
      }
    }

    if (!result['success']) {
      stopwatch.stop();
      result['totalTime'] = stopwatch.elapsedMilliseconds;
    }

    return result;
  }

  /// Hiển thị dialog test kết nối
  static Future<void> showConnectionTestDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("🔍 Kiểm tra kết nối"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang kiểm tra kết nối đến server..."),
          ],
        ),
      ),
    );

    try {
      // Test DNS resolution
      final dnsResult = await testBasicConnection();

      // Test HTTP connection
      final httpResult = await testHttpConnection();

      // Test with retry
      final retryResult = await testConnectionWithRetry();

      // Test with workarounds
      final workaroundResult =
          await NetworkWorkaround.testConnectionWithWorkaround();

      // Test with different user agents
      final userAgentResult =
          await NetworkWorkaround.testWithDifferentUserAgents();

      Navigator.pop(context);

      // Hiển thị kết quả
      _showTestResults(
        context,
        dnsResult,
        httpResult,
        retryResult,
        workaroundResult,
        userAgentResult,
      );
    } catch (e) {
      Navigator.pop(context);
      Get.snackbar(
        "Lỗi kiểm tra",
        "Không thể kiểm tra kết nối: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  static void _showTestResults(
    BuildContext context,
    bool dnsResult,
    Map<String, dynamic> httpResult,
    Map<String, dynamic> retryResult,
    Map<String, dynamic> workaroundResult,
    Map<String, dynamic> userAgentResult,
  ) {
    final success = dnsResult && httpResult['success'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? "✅ Kết nối thành công" : "❌ Kết nối thất bại"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTestResult(
                "DNS Resolution",
                dnsResult ? "✅ Thành công" : "❌ Thất bại",
              ),
              _buildTestResult(
                "HTTP Connection",
                httpResult['success'] ? "✅ Thành công" : "❌ Thất bại",
              ),
              if (httpResult['responseTime'] != null)
                _buildTestResult(
                  "Response Time",
                  "${httpResult['responseTime']}ms",
                ),
              if (httpResult['statusCode'] != null)
                _buildTestResult("Status Code", "${httpResult['statusCode']}"),
              if (httpResult['error'] != null)
                _buildTestResult("HTTP Error", httpResult['error']),
              SizedBox(height: 16),
              Text(
                "Retry Test:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildTestResult("Attempts", "${retryResult['attempts']}"),
              _buildTestResult("Total Time", "${retryResult['totalTime']}ms"),
              _buildTestResult("Success", retryResult['success'] ? "✅" : "❌"),
              if (retryResult['errors'].isNotEmpty) ...[
                SizedBox(height: 8),
                Text("Errors:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...retryResult['errors'].map<Widget>(
                  (error) => Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text("• $error", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
              SizedBox(height: 16),
              Text(
                "Workaround Tests:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildTestResult(
                "HTTPS/HTTP Test",
                workaroundResult['success']
                    ? "✅ ${workaroundResult['method']}"
                    : "❌ Failed",
              ),
              if (workaroundResult['responseTime'] != null)
                _buildTestResult(
                  "Response Time",
                  "${workaroundResult['responseTime']}ms",
                ),
              if (workaroundResult['error'] != null)
                _buildTestResult("Workaround Error", workaroundResult['error']),
              SizedBox(height: 8),
              Text(
                "User-Agent Tests:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildTestResult(
                "User-Agent Success",
                userAgentResult['success']
                    ? "✅ ${userAgentResult['userAgent']}"
                    : "❌ Failed",
              ),
              if (userAgentResult['statusCode'] != null)
                _buildTestResult(
                  "Status Code",
                  "${userAgentResult['statusCode']}",
                ),
              if (userAgentResult['error'] != null)
                _buildTestResult("User-Agent Error", userAgentResult['error']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showConnectionTestDialog(context);
              },
              child: Text("Thử lại"),
            ),
        ],
      ),
    );
  }

  static Widget _buildTestResult(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
