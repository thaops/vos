import 'package:dio/dio.dart';

/// Generic class để xử lý API response một cách thống nhất
class ApiResponseHandler<T> {
  /// Parse response và trả về kết quả
  static ApiResult<T> handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String? dataKey,
  }) {
    try {
      // Kiểm tra HTTP status code
      if (response.statusCode != 200) {
        return ApiResult<T>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      // Kiểm tra response data
      if (response.data == null) {
        return ApiResult<T>.error('Response data is null');
      }

      // Parse response data
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra API status code (case insensitive)
        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          // API thành công
          final data =
              dataKey != null ? responseData[dataKey] : responseData['data'];

          if (data != null) {
            try {
              final parsedData = fromJson(data);
              return ApiResult<T>.success(parsedData, message);
            } catch (e) {
              return ApiResult<T>.error('Parse error: $e');
            }
          } else {
            return ApiResult<T>.error('No data found in response');
          }
        } else {
          // API trả về lỗi
          return ApiResult<T>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        // Response không phải Map, thử parse trực tiếp
        try {
          final parsedData = fromJson(response.data);
          return ApiResult<T>.success(parsedData);
        } catch (e) {
          return ApiResult<T>.error('Parse error: $e');
        }
      }
    } catch (e) {
      return ApiResult<T>.error('Unexpected error: $e');
    }
  }

  /// Handle response cho list data
  static ApiResult<List<T>> handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String? dataKey,
  }) {
    try {
      if (response.statusCode != 200) {
        return ApiResult<List<T>>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<List<T>>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          final data =
              dataKey != null ? responseData[dataKey] : responseData['data'];

          if (data is List) {
            try {
              final parsedList =
                  data
                      .map((item) => fromJson(item as Map<String, dynamic>))
                      .toList();
              return ApiResult<List<T>>.success(parsedList, message);
            } catch (e) {
              return ApiResult<List<T>>.error('Parse list error: $e');
            }
          } else {
            return ApiResult<List<T>>.error('Data is not a list');
          }
        } else {
          return ApiResult<List<T>>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<List<T>>.error('Response is not a valid format');
      }
    } catch (e) {
      return ApiResult<List<T>>.error('Unexpected error: $e');
    }
  }
}

/// Generic result class cho API response
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  /// Tạo success result
  factory ApiResult.success(T data, [String? message]) {
    return ApiResult._(isSuccess: true, data: data, message: message);
  }

  /// Tạo error result
  factory ApiResult.error(String error, [int? statusCode]) {
    return ApiResult._(isSuccess: false, error: error, statusCode: statusCode);
  }

  /// Kiểm tra có thành công không
  bool get isError => !isSuccess;

  /// Lấy data hoặc throw exception
  T get requireData {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'No data available');
  }
}
