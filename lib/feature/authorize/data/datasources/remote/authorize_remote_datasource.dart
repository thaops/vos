import 'dart:convert';
import 'package:dio/dio.dart' as dioLib;
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/data/models/authorize_dto.dart';

abstract class AuthorizeRemoteDataSource {
  Future<ApiResult<List<AuthorizeDto>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year);
}

class AuthorizeRemoteDataSourceImpl implements AuthorizeRemoteDataSource {
  final dioLib.Dio dio;

  AuthorizeRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApiResult<List<AuthorizeDto>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year) async {
    try {
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final requestBody = {
        'Authorize_ID': authorizeId,
        'HR_ID': hrId,
        'Year': year,
      };

      final data = {
        'FunctionCode': 'HR_AUTHORIZE_GET',
        'ls_Data': jsonEncode(requestBody),
      };

      // Log request details
      print('📤 [AUTHORIZE API] Request URL: ${Config.baseUrlVasc}/Share/Share_Get');
      print('📤 [AUTHORIZE API] Request Method: POST');
      print('📤 [AUTHORIZE API] Request Headers: ${headers.keys.toList()}');
      print('📤 [AUTHORIZE API] Authorization token: ${token.length > 50 ? "${token.substring(0, 50)}..." : token}');
      print('📤 [AUTHORIZE API] Request Body:');
      print('   - FunctionCode: ${data['FunctionCode']}');
      print('   - ls_Data: ${data['ls_Data']}');
      print('📤 [AUTHORIZE API] Request Parameters:');
      print('   - Authorize_ID: $authorizeId');
      print('   - HR_ID: $hrId');
      print('   - Year: $year');

      final response = await dio.request(
        '${Config.baseUrlVasc}/Share/Share_Get',
        options: dioLib.Options(
          method: 'POST',
          headers: headers,
          responseType: dioLib.ResponseType.plain,
        ),
        data: data,
      );

      // Log response details
      print('📥 [AUTHORIZE API] Response Status: ${response.statusCode}');
      print('📥 [AUTHORIZE API] Response Type: ${response.data.runtimeType}');
      if (response.data is String) {
        final responseStr = response.data as String;
        print('📥 [AUTHORIZE API] Response Length: ${responseStr.length}');
        print('📥 [AUTHORIZE API] Response Preview (first 500 chars): ${responseStr.length > 500 ? responseStr.substring(0, 500) : responseStr}');
      }

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> responseData;

        try {
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
                'Invalid response format: ${response.data.runtimeType}');
          }
        } catch (e) {
          return ApiResult.error('Failed to parse response: ${e.toString()}');
        }

        final resultCode = responseData['ResultCode'] as int?;
        final message = responseData['Message'] as String? ?? '';
        final totalRecord = responseData['TotalRecord'] as int? ?? 0;
        
        print('📊 [AUTHORIZE API] Parsed Response:');
        print('   - ResultCode: $resultCode');
        print('   - Message: $message');
        print('   - TotalRecord: $totalRecord');
        
        if (resultCode != 0) {
          print('❌ [AUTHORIZE API] API returned error: ResultCode=$resultCode, Message=$message');
          return ApiResult.error(message.isNotEmpty ? message : 'Lấy danh sách ủy quyền thất bại');
        }

        final dataString = responseData['Data'] as String?;
        if (dataString == null || dataString.isEmpty) {
          print('⚠️ [AUTHORIZE API] Data string is null or empty');
          if (totalRecord == 0) {
            print('⚠️ [AUTHORIZE API] TotalRecord = 0 and no Data, returning empty list');
            print('💡 [AUTHORIZE API] Suggestion: HR_ID=$hrId may be incorrect. Try using HR_ID from user profile or check user permissions.');
          }
          return ApiResult.success([]);
        }
        
        // Log cả khi TotalRecord = 0 để debug
        if (totalRecord == 0) {
          print('⚠️ [AUTHORIZE API] TotalRecord = 0 but Data exists, will parse to check for null objects');
        }
        
        print('📊 [AUTHORIZE API] Data string length: ${dataString.length}');
        print('📊 [AUTHORIZE API] Data string preview (first 300 chars): ${dataString.length > 300 ? dataString.substring(0, 300) : dataString}');

        try {
          final cleanedString = dataString
              .replaceAll('\r\n', '')
              .replaceAll('\r', '')
              .replaceAll('\n', '')
              .trim();

          final List<dynamic> dataList = jsonDecode(cleanedString);
          
          print('📊 [AUTHORIZE API] Parsed data list length: ${dataList.length}');

          if (dataList.isEmpty) {
            print('⚠️ [AUTHORIZE API] Data list is empty after parsing');
            return ApiResult.success([]);
          }

          final authorizes = <AuthorizeDto>[];
          int skippedCount = 0;
          int errorCount = 0;
          
          for (int i = 0; i < dataList.length; i++) {
            try {
              final item = dataList[i];
              if (item is! Map<String, dynamic>) {
                skippedCount++;
                continue;
              }

              final allNull = item.values.every((value) => value == null);
              if (allNull) {
                skippedCount++;
                print('⚠️ [AUTHORIZE API] Item $i: All values are null, skipping');
                continue;
              }

              final authorize = AuthorizeDto.fromJson(item);
              authorizes.add(authorize);
            } catch (e) {
              errorCount++;
              print('❌ [AUTHORIZE API] Error parsing item $i: $e');
              continue;
            }
          }
          
          print('📊 [AUTHORIZE API] Parse result:');
          print('   - Total items: ${dataList.length}');
          print('   - Successfully parsed: ${authorizes.length}');
          print('   - Skipped (null): $skippedCount');
          print('   - Errors: $errorCount');

          if (authorizes.isEmpty) {
            print('❌ [AUTHORIZE API] No valid items parsed from response');
            if (skippedCount > 0) {
              print('💡 [AUTHORIZE API] All items were null. This usually means:');
              print('   1. HR_ID=$hrId is incorrect for this user');
              print('   2. User has no authorizations');
              print('   3. User permissions do not allow viewing authorizations');
              print('💡 [AUTHORIZE API] Try using a different HR_ID (e.g., from user profile)');
            }
            return ApiResult.error('Không tìm thấy dữ liệu ủy quyền. Vui lòng kiểm tra HR_ID hoặc quyền truy cập.');
          }
          
          print('✅ [AUTHORIZE API] Successfully parsed ${authorizes.length} authorizes');
          return ApiResult.success(authorizes);
        } catch (e) {
          print('❌ [AUTHORIZE API] Parse authorize list error: $e');
          return ApiResult.error('Failed to parse authorize list: ${e.toString()}');
        }
      } else {
        print('❌ [AUTHORIZE API] Invalid response status: ${response.statusCode}');
        return ApiResult.error(
            'Invalid response status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [AUTHORIZE API] Exception: $e');
      print('❌ [AUTHORIZE API] Stack trace: $stackTrace');
      return ApiResult.error('getAuthorizes failed: $e');
    }
  }
}

