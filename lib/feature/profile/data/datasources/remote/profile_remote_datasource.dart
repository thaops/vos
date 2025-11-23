import 'dart:convert';
import 'package:dio/dio.dart' as dioLib;
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/data/models/link_viags_request_dto.dart';
import 'package:vos_flutter/feature/profile/data/models/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ApiResult<UserProfileDto>> getUserProfile();
  Future<ApiResult<UserProfileDto>> linkViagsAccount(LinkViagsRequestDto request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final dioLib.Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApiResult<UserProfileDto>> getUserProfile() async {
    try {
      // TODO: Implement get user profile API if needed
      return ApiResult.error('Not implemented');
    } catch (e) {
      return ApiResult.error('getUserProfile failed: $e');
    }
  }

  @override
  Future<ApiResult<UserProfileDto>> linkViagsAccount(
      LinkViagsRequestDto request) async {
    try {
      // Headers theo yêu cầu API
      final headers = {
        'Accept-Language': '',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Body x-www-form-urlencoded
      final data = {
        'ls_Data': request.toJsonString(), // Sửa từ Is_Data thành ls_Data
        'FunctionCode': 'MOBI_LOGIN',
      };

      // Call API VACS
      // Không set responseType để Dio trả về raw response, tự parse sau
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

        // Xử lý response.data - với responseType.plain, data sẽ là String
        try {
          String responseString;
          
          if (response.data is String) {
            responseString = response.data as String;
          } else {
            // Fallback: convert sang string
            responseString = response.data.toString();
          }

          // Kiểm tra response rỗng
          if (responseString.trim().isEmpty) {
            return ApiResult.error('Response is empty');
          }

          // Kiểm tra response có bắt đầu bằng dấu chấm (có thể là error page)
          if (responseString.trim().startsWith('.')) {
            print('❌ Response starts with dot, might be error page');
            print('❌ Response preview: ${responseString.substring(0, responseString.length > 200 ? 200 : responseString.length)}');
            return ApiResult.error('Invalid response format from server');
          }

          // Parse JSON string
          responseData = json.decode(responseString) as Map<String, dynamic>;
        } catch (e) {
          print('❌ Parse JSON error: $e');
          print('❌ Response data type: ${response.data.runtimeType}');
          final preview = response.data.toString();
          print('❌ Response data preview: ${preview.length > 200 ? preview.substring(0, 200) : preview}');
          return ApiResult.error(
              'Failed to parse response: ${e.toString()}');
        }

        // Kiểm tra ResultCode
        final resultCode = responseData['ResultCode'] as int?;
        if (resultCode != 0) {
          final message =
              responseData['Message'] as String? ?? 'Đăng nhập thất bại';
          return ApiResult.error(message);
        }

        // Lấy Data từ response
        final userData = responseData['Data'] as Map<String, dynamic>?;
        if (userData == null) {
          return ApiResult.error('No data in response');
        }

        // Map response vào UserProfileDto
        try {
          final dto = UserProfileDto.fromJson(userData);
          return ApiResult.success(dto);
        } catch (e) {
          print('❌ Parse UserProfileDto error: $e');
          return ApiResult.error('Failed to parse user profile: ${e.toString()}');
        }
      } else {
        return ApiResult.error(
            'Invalid response status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Link VIAGS API error: $e');
      if (e is dioLib.DioException) {
        final errorMessage = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
        return ApiResult.error('linkViagsAccount failed: $errorMessage');
      }
      return ApiResult.error('linkViagsAccount failed: ${e.toString()}');
    }
  }
}

