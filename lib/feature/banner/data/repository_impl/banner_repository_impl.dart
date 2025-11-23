import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/banner/data/datasources/remote/banner_remote_datasource.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<Banner>>> getBanners(String token, int recUserID) async {
    final result = await remoteDataSource.getBanners(token, recUserID);
    
    if (result.isSuccess && result.data != null) {
      final banners = result.data!.map((dto) => dto.toDomain()).toList();
      return ApiResult.success(banners);
    }
    
    return ApiResult.error(result.error ?? 'Failed to get banners');
  }
}

