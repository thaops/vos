import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/banner/data/models/banner_dto.dart';

abstract class BannerRemoteDataSource {
  Future<ApiResult<List<BannerDto>>> getBanners(String token, int recUserID);
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final ShareApiRepository shareApiRepository;

  BannerRemoteDataSourceImpl({required this.shareApiRepository});

  @override
  Future<ApiResult<List<BannerDto>>> getBanners(
      String token, int recUserID) async {
    return shareApiRepository.callShareUpdate<List<BannerDto>>(
      functionCode: 'MOBI_BANNER_GET',
      token: token,
      data: {'RecUserID': recUserID},
      parser: (json) {
        if (json is! List) return [];
        return json
            .map((item) => BannerDto.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

