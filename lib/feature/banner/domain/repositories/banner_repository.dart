import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';

abstract class BannerRepository {
  Future<ApiResult<List<Banner>>> getBanners(String token, int recUserID);
  Future<ApiResult<List<Banner>>> getCachedBanners(int recUserID);
}
