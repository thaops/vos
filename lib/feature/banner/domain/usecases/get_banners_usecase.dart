import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';

class GetBannersUsecase {
  final BannerRepository repository;

  GetBannersUsecase(this.repository);

  Future<ApiResult<List<Banner>>> call(String token, int recUserID) async {
    return await repository.getBanners(token, recUserID);
  }
}

