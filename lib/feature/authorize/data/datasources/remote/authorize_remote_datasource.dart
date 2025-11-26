import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/authorize/data/models/authorize_dto.dart';

abstract class AuthorizeRemoteDataSource {
  Future<ApiResult<List<AuthorizeDto>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year);
  Future<ApiResult<List<Map<String, String>>>> getAuthorizeStatuses(String token);
}

class AuthorizeRemoteDataSourceImpl implements AuthorizeRemoteDataSource {
  final ShareApiRepository shareApiRepository;

  AuthorizeRemoteDataSourceImpl({required this.shareApiRepository});

  @override
  Future<ApiResult<List<AuthorizeDto>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year) async {
    return shareApiRepository.callShareGet<List<AuthorizeDto>>(
      functionCode: 'HR_AUTHORIZE_GET',
      token: token,
      data: {
        'Authorize_ID': authorizeId,
        'HR_ID': hrId,
        'Year': year,
      },
      parser: (json) {
        if (json is! List) return [];
        
        final authorizes = <AuthorizeDto>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            // Skip items where all values are null
            final allNull = item.values.every((value) => value == null);
            if (allNull) continue;

            final authorize = AuthorizeDto.fromJson(item);
            authorizes.add(authorize);
          } catch (e) {
            // Skip invalid items
            continue;
          }
        }

        // Empty list là trường hợp hợp lệ (user có thể chưa có ủy quyền nào)
        // UI sẽ xử lý empty state để hiển thị "Chưa có ủy quyền nào"
        return authorizes;
      },
    );
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> getAuthorizeStatuses(String token) async {
    return shareApiRepository.callShareGet<List<Map<String, String>>>(
      functionCode: 'EAF_HR.dbo.HR_Authorize.Status',
      token: token,
      parser: (json) {
        if (json is! List) return [];
        return json
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'code': (item['Code'] as String? ?? '').toString(),
                'name': (item['Name_VN'] as String? ?? '').toString(),
              },
            )
            .toList();
      },
    );
  }
}

