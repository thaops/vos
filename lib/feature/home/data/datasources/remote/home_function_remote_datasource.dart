import 'dart:convert';
import 'package:dio/dio.dart' as dioLib;
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/home/data/models/home_function_dto.dart';

abstract class HomeFunctionRemoteDataSource {
  Future<ApiResult<List<HomeFunctionSessionDto>>> getHomeFunctions(
      String token, String lsStatus);
}

class HomeFunctionRemoteDataSourceImpl
    implements HomeFunctionRemoteDataSource {
  final dioLib.Dio dio;

  HomeFunctionRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApiResult<List<HomeFunctionSessionDto>>> getHomeFunctions(
      String token, String lsStatus) async {
    try {
      // Headers
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Body
      final data = {
        'FunctionCode': 'Mobi_Function_Get',
        'ls_Data': jsonEncode({'ls_Status': lsStatus}),
      };

      // Call API VACS
      final response = await dio.request(
        '${Config.baseUrlVasc}/Share/Share_Update',
        options: dioLib.Options(
          method: 'POST',
          headers: headers,
          responseType: dioLib.ResponseType.plain, // Dùng plain để nhận raw string
        ),
        data: data,
      );

      // Kiểm tra response
      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> responseData;

        // Xử lý response.data có thể là String hoặc Map
        try {
          if (response.data is String) {
            // Parse JSON string
            final jsonString = response.data as String;
            if (jsonString.trim().isEmpty) {
              return ApiResult.error('Response is empty');
            }
            responseData = json.decode(jsonString) as Map<String, dynamic>;
          } else if (response.data is Map) {
            // Đã là Map, cast trực tiếp
            responseData = response.data as Map<String, dynamic>;
          } else {
            return ApiResult.error(
                'Invalid response format: ${response.data.runtimeType}');
          }
        } catch (e) {
          print('❌ Parse JSON error: $e');
          print('❌ Response data type: ${response.data.runtimeType}');
          final preview = response.data.toString();
          print('❌ Response data preview: ${preview.length > 200 ? preview.substring(0, 200) : preview}');
          return ApiResult.error('Failed to parse response: ${e.toString()}');
        }

        // Kiểm tra ResultCode
        final resultCode = responseData['ResultCode'] as int?;
        if (resultCode != 0) {
          final message =
              responseData['Message'] as String? ?? 'Lấy danh sách chức năng thất bại';
          return ApiResult.error(message);
        }

        // Lấy Data từ response (là JSON string)
        final dataString = responseData['Data'] as String?;
        if (dataString == null || dataString.isEmpty) {
          return ApiResult.success([]);
        }

        // Parse JSON string thành List
        try {
          final List<dynamic> dataList = jsonDecode(dataString);
          final sessions = dataList
              .map((item) =>
                  HomeFunctionSessionDto.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResult.success(sessions);
        } catch (e) {
          print('❌ Parse home function list error: $e');
          return ApiResult.error('Failed to parse home function list: ${e.toString()}');
        }
      } else {
        return ApiResult.error(
            'Invalid response status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.error('getHomeFunctions failed: $e');
    }
  }
}

