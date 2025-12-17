import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';

class GetCachedBannersUsecase {
  final BannerRepository repository;

  GetCachedBannersUsecase(this.repository);

  Future<ApiResult<List<Banner>>> call(int recUserID) async {
    return repository.getCachedBanners(recUserID);
  }
}
