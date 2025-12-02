import 'dart:convert';
import 'package:dio/dio.dart' as dioLib;
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';

/// Base repository để gọi Share API endpoint
/// Tất cả các API gọi /Share/Share_Get và /Share/Share_Update đều nên dùng repository này
///
/// Giúp giảm code trùng lặp, dễ maintain và scale
class ShareApiRepository {
  final dioLib.Dio dio;

  ShareApiRepository({required this.dio});

  /// Generic method để gọi Share API - GET endpoint
  ///
  /// [functionCode]: FunctionCode của API (ví dụ: 'EAF_HR.dbo.HR_Authorize.Status')
  /// [token]: Authorization token (optional, nếu empty thì không thêm header)
  /// [data]: Data gửi lên (Map hoặc null), sẽ được encode thành JSON string
  /// [parser]: Function để parse response data thành domain model (optional)
  ///
  /// Returns: ApiResult<T> với data đã được parse (nếu có parser) hoặc raw data
  Future<ApiResult<T>> callShareGet<T>({
    required String functionCode,
    String token = '',
    Map<String, dynamic>? data,
    T Function(dynamic json)? parser,
  }) async {
    return _callShareApi<T>(
      endpoint: '/Share/Share_Get',
      functionCode: functionCode,
      token: token,
      data: data,
      parser: parser,
    );
  }

  /// Generic method để gọi Share API - UPDATE endpoint
  ///
  /// [functionCode]: FunctionCode của API (ví dụ: 'HR_AUTHORIZE_UPDATE')
  /// [token]: Authorization token (optional, nếu empty thì không thêm header)
  /// [data]: Data gửi lên (Map hoặc null), sẽ được encode thành JSON string
  /// [parser]: Function để parse response data thành domain model (optional)
  ///
  /// Returns: ApiResult<T> với data đã được parse (nếu có parser) hoặc raw data
  Future<ApiResult<T>> callShareUpdate<T>({
    required String functionCode,
    String token = '',
    Map<String, dynamic>? data,
    T Function(dynamic json)? parser,
  }) async {
    return _callShareApi<T>(
      endpoint: '/Share/Share_Update',
      functionCode: functionCode,
      token: token,
      data: data,
      parser: parser,
    );
  }

  /// Internal method để gọi Share API
  Future<ApiResult<T>> _callShareApi<T>({
    required String endpoint,
    required String functionCode,
    String token = '',
    Map<String, dynamic>? data,
    T Function(dynamic json)? parser,
  }) async {
    try {
      // 1. Build headers
      final headers = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Chỉ thêm Authorization nếu có token
      if (token.isNotEmpty) {
        // Thêm "Bearer " prefix nếu token chưa có
        final authToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
        headers['Authorization'] = authToken;
      }

      // 2. Build request data
      final lsDataString = data != null ? jsonEncode(data) : '{}';
      final requestData = {
        'FunctionCode': functionCode,
        'ls_Data': lsDataString,
      };

      // Log request
      print('📤 [ShareAPI] Request:');
      print('   URL: ${Config.baseUrlVasc}$endpoint');
      print('   FunctionCode: $functionCode');
      print('   ls_Data: $lsDataString');
      print('   Headers: ${headers.keys.join(", ")}');

      // 3. Call API
      final response = await dio.request(
        '${Config.baseUrlVasc}$endpoint',
        options: dioLib.Options(
          method: 'POST',
          headers: headers,
          responseType: dioLib.ResponseType.plain,
        ),
        data: requestData,
      );

      // 4. Parse response
      return _parseResponse<T>(response, parser, functionCode);
    } catch (e) {
      return ApiResult.error('Share API call failed: ${e.toString()}');
    }
  }

  /// Parse response từ Share API
  ApiResult<T> _parseResponse<T>(
    dioLib.Response response,
    T Function(dynamic json)? parser,
    String functionCode,
  ) {
    // Log raw response
    print('📥 [ShareAPI] Response for $functionCode:');
    print('   Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        print('   Raw Response: ${jsonEncode(response.data)}');
      } catch (e) {
        print('   Raw Response (cannot encode): ${response.data}');
      }
    } else {
      print('   Error: ${response.statusMessage}');
    }

    // Check HTTP status
    if (response.statusCode != 200) {
      return ApiResult.error(
        'HTTP Error: ${response.statusCode}',
        response.statusCode,
      );
    }

    if (response.data == null) {
      return ApiResult.error('Response data is null');
    }

    try {
      // Parse response body
      Map<String, dynamic> responseData;
      if (response.data is String) {
        final jsonString = response.data as String;
        if (jsonString.trim().isEmpty) {
          return ApiResult.error('Response is empty');
        }
        responseData = json.decode(jsonString) as Map<String, dynamic>;
      } else if (response.data is Map) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        return ApiResult.error(
          'Invalid response format: ${response.data.runtimeType}',
        );
      }

      // Log parsed response
      print('   Parsed Response: ${jsonEncode(responseData)}');

      // Check API result code
      final resultCode = responseData['ResultCode'] as int?;
      final message = responseData['Message'] as String? ?? '';

      print('   ResultCode: $resultCode');
      print('   Message: $message');

      if (resultCode != 0) {
        return ApiResult.error(
          message.isNotEmpty ? message : 'API call failed',
          resultCode,
        );
      }

      // Extract data
      final dataValue = responseData['Data'];

      print('   Data type: ${dataValue.runtimeType}');
      if (dataValue is String) {
        print('   Data (String): $dataValue');
      } else {
        print('   Data: ${jsonEncode(dataValue)}');
      }

      // Handle case: Data có thể là String (JSON string) hoặc Map/Object trực tiếp
      dynamic parsedData;

      if (dataValue == null) {
        // Trả về empty list nếu là List, null nếu là Object
        if (parser != null) {
          try {
            return ApiResult.success(parser([]));
          } catch (_) {
            return ApiResult.success(parser({}));
          }
        }
        return ApiResult.success(null as T);
      }

      // Nếu Data là String, cần kiểm tra xem có phải JSON string không
      if (dataValue is String) {
        final dataString = dataValue.trim();
        if (dataString.isEmpty) {
          if (parser != null) {
            try {
              return ApiResult.success(parser([]));
            } catch (_) {
              return ApiResult.success(parser({}));
            }
          }
          return ApiResult.success(null as T);
        }

        // Clean string
        final cleanedString = dataString
            .replaceAll('\r\n', '')
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .trim();

        // Thử parse JSON - nếu không phải JSON thì dùng string trực tiếp
        try {
          // Kiểm tra xem có phải JSON string không (bắt đầu bằng [ hoặc {)
          if (cleanedString.startsWith('[') || cleanedString.startsWith('{')) {
            parsedData = jsonDecode(cleanedString);
          } else {
            // Không phải JSON string, dùng trực tiếp string
            parsedData = cleanedString;
          }
        } catch (e) {
          // Nếu parse JSON fail, có thể là plain text string
          // Dùng string trực tiếp
          parsedData = cleanedString;
        }
      } else {
        // Data đã là object/array, dùng trực tiếp
        parsedData = dataValue;
      }

      // Apply parser nếu có
      if (parser != null) {
        try {
          print('   Parsing data with parser...');
          final result = parser(parsedData);
          print('   ✅ Parse successful');
          // Nếu parser trả về void, vẫn tạo success result nhưng không có data
          // Với void type, result sẽ là null hoặc void, nhưng vẫn là success
          return ApiResult.success(result, message);
        } catch (e, stackTrace) {
          print('   ❌ Parser error: $e');
          print('   Stack trace: $stackTrace');
          return ApiResult.error('Parser error: ${e.toString()}');
        }
      }

      // Trả về raw data nếu không có parser
      print('   ✅ Returning raw data');
      return ApiResult.success(parsedData as T, message);
    } catch (e) {
      return ApiResult.error('Response parsing failed: ${e.toString()}');
    }
  }
}
