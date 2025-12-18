import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';

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
  final ShareApiRepository shareApiRepository;

  AuthorizeCreateRemoteDataSourceImpl({required this.shareApiRepository});

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> searchAuthorizedPersons(
    String token,
    String query,
  ) async {
    return shareApiRepository.callShareGet<List<Map<String, dynamic>>>(
      functionCode: 'HR_DATA_SEARCH',
      token: token,
      data: {'Module': 'USER', 'KeySearch': query, 'Dep_ID': 0},
      parser: (json) {
        if (json is! List) return [];
        return json
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
                'Dep_Name_VN':
                    item['Level_3_Name'] ?? item['Dep_Name_VN'] ?? '',
                'Code_Job_Title': item['Code_Job_Title']?.toString() ?? '',
                'JobTitle_NameVN':
                    item['Name_Job_Title'] ?? item['JobTitle_NameVN'] ?? '',
              },
            )
            .toList();
      },
    );
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeTypes(
    String token,
  ) async {
    return shareApiRepository.callShareGet<List<Map<String, String>>>(
      functionCode: 'EAF_HR.dbo.HR_Authorize.ls_Authorize',
      token: token,
      parser: (json) {
        if (json is! List) return [];
        return json
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'code': item['Code']?.toString() ?? '',
                'name': item['Name_VN']?.toString() ?? '',
              },
            )
            .where((type) => type['code']!.isNotEmpty)
            .toList();
      },
    );
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeStatuses(
    String token,
  ) async {
    return shareApiRepository.callShareGet<List<Map<String, String>>>(
      functionCode: 'EAF_HR.dbo.HR_Authorize.Status',
      token: token,
      parser: (json) {
        if (json is! List) return [];
        return json
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'code': item['Code']?.toString() ?? '',
                'name': item['Name_VN']?.toString() ?? '',
              },
            )
            .where((status) => status['code']!.isNotEmpty)
            .toList();
      },
    );
  }

  @override
  Future<ApiResult<String>> createAuthorize(
    String token,
    Map<String, dynamic> payload,
  ) async {
    print("payload: $payload");
    return shareApiRepository.callShareUpdate<String>(
      functionCode: 'HR_AUTHORIZE_UPDATE',
      token: token,
      data: payload,
      parser: (json) {
        if (json == null) {
          return 'Cập nhật thành công';
        }

        if (json is String) {
          return json.isEmpty ? 'Cập nhật thành công' : json;
        }

        if (json is Map) {
          final message = json['Message'] as String?;
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }

        return json.toString();
      },
    );
  }
}
