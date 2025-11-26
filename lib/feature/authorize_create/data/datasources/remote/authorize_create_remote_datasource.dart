import 'dart:convert';
import 'package:dio/dio.dart' as dioLib;
import 'package:vos_flutter/common/services/config.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';

abstract class AuthorizeCreateRemoteDataSource {
  Future<ApiResult<List<Map<String, dynamic>>>> searchAuthorizedPersons(
    String token,
    String query,
  );

  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeTypes(String token);

  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeStatuses(
    String token,
  );

  Future<ApiResult<String>> createAuthorize(
    String token,
    Map<String, dynamic> payload,
  );
}

class AuthorizeCreateRemoteDataSourceImpl
    implements AuthorizeCreateRemoteDataSource {
  final dioLib.Dio dio;

  AuthorizeCreateRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> searchAuthorizedPersons(
    String token,
    String query,
  ) async {
    try {
      final lsData = jsonEncode({
        'Module': 'USER',
        'KeySearch': query,
        'Dep_ID': 0,
      });
      final list = await _fetchShareList(
        token: token,
        functionCode: 'HR_DATA_SEARCH',
        lsData: lsData,
      );
      final persons = list
          .whereType<Map<String, dynamic>>()
          .where((item) {
            final hrId = item['HR_ID'];
            final userCode = item['UserCode'] ?? item['HR_No'];
            final userName = item['UserName'] ?? item['FullName'];
            return hrId != null && (userCode != null || userName != null);
          })
          .map(
            (item) => {
              'HR_ID': item['HR_ID'] ?? 0,
              'HR_No': item['UserCode'] ?? item['HR_No'] ?? '',
              'FullName': item['UserName'] ?? item['FullName'] ?? '',
              'Dep_Name_VN': item['Level_3_Name'] ?? item['Dep_Name_VN'] ?? '',
              'Code_Job_Title': item['Code_Job_Title']?.toString() ?? '',
              'JobTitle_NameVN':
                  item['Name_Job_Title'] ?? item['JobTitle_NameVN'] ?? '',
            },
          )
          .toList();
      return ApiResult.success(persons);
    } catch (e) {
      return ApiResult.error('searchAuthorizedPersons failed: $e');
    }
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeTypes(
    String token,
  ) async {
    try {
      final list = await _fetchShareList(
        token: token,
        functionCode: 'EAF_HR.dbo.HR_Authorize.ls_Authorize',
        lsData: '{}',
      );
      final types = list
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => {
              'code': item['Code']?.toString() ?? '',
              'name': item['Name_VN']?.toString() ?? '',
            },
          )
          .where((type) => type['code']!.isNotEmpty)
          .toList();
      return ApiResult.success(types);
    } catch (e) {
      return ApiResult.error('loadAuthorizeTypes failed: $e');
    }
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeStatuses(
    String token,
  ) async {
    try {
      final list = await _fetchShareList(
        token: token,
        functionCode: 'EAF_HR.dbo.HR_Authorize.Status',
        lsData: '{}',
      );
      final statuses = list
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => {
              'code': item['Code']?.toString() ?? '',
              'name': item['Name_VN']?.toString() ?? '',
            },
          )
          .where((status) => status['code']!.isNotEmpty)
          .toList();
      return ApiResult.success(statuses);
    } catch (e) {
      return ApiResult.error('loadAuthorizeStatuses failed: $e');
    }
  }

  @override
  Future<ApiResult<String>> createAuthorize(
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final requestData = {
        'FunctionCode': 'HR_AUTHORIZE_UPDATE',
        'ls_Data': jsonEncode(payload),
      };

      final response = await dio.request(
        '${Config.baseUrlVasc}/Share/Share_Update',
        options: dioLib.Options(
          method: 'POST',
          headers: {
            'Authorization': token,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          responseType: dioLib.ResponseType.plain,
        ),
        data: requestData,
      );

      final body = _decodeResponse(response.data);
      final resultCode = body['ResultCode'] as int? ?? -1;
      if (resultCode != 0) {
        final message = body['Message'] as String? ?? 'Tạo ủy quyền thất bại';
        return ApiResult.error(message);
      }

      final data = body['Data']?.toString() ?? 'Cập nhật thành công';
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.error('createAuthorize failed: $e');
    }
  }

  Future<List<dynamic>> _fetchShareList({
    required String token,
    required String functionCode,
    required String lsData,
  }) async {
    final response = await dio.request(
      '${Config.baseUrlVasc}/Share/Share_Get',
      options: dioLib.Options(
        method: 'POST',
        headers: {
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        responseType: dioLib.ResponseType.plain,
      ),
      data: {'FunctionCode': functionCode, 'ls_Data': lsData},
    );
    final body = _decodeResponse(response.data);
    final resultCode = body['ResultCode'] as int? ?? -1;
    if (resultCode != 0) {
      final message = body['Message'] as String? ?? 'Không thể lấy dữ liệu';
      throw message;
    }
    final dataString = body['Data'] as String? ?? '';
    if (dataString.trim().isEmpty) {
      return [];
    }
    final cleanedString = dataString.replaceAll('\r', '').replaceAll('\n', '');
    final decoded = jsonDecode(cleanedString);
    if (decoded is List) {
      return decoded;
    }
    return [];
  }

  Map<String, dynamic> _decodeResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.trim().isNotEmpty) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return {};
  }
}
