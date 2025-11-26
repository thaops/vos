import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/home/data/models/home_function_dto.dart';

abstract class HomeFunctionRemoteDataSource {
  Future<ApiResult<List<HomeFunctionSessionDto>>> getHomeFunctions(
      String token, String lsStatus);
}

class HomeFunctionRemoteDataSourceImpl
    implements HomeFunctionRemoteDataSource {
  final ShareApiRepository shareApiRepository;

  HomeFunctionRemoteDataSourceImpl({required this.shareApiRepository});

  @override
  Future<ApiResult<List<HomeFunctionSessionDto>>> getHomeFunctions(
      String token, String lsStatus) async {
    return shareApiRepository.callShareUpdate<List<HomeFunctionSessionDto>>(
      functionCode: 'Mobi_Function_Get',
      token: token,
      data: {'ls_Status': lsStatus},
      parser: (json) {
        if (json is! List) return [];
        return json
            .map((item) =>
                HomeFunctionSessionDto.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

