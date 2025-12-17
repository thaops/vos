import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/banner/data/datasources/local/banner_local_datasource.dart';
import 'package:vos_flutter/feature/banner/data/datasources/remote/banner_remote_datasource.dart';
import 'package:vos_flutter/feature/banner/domain/models/banner.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;
  final BannerLocalDataSource localDataSource;

  BannerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ApiResult<List<Banner>>> getBanners(
    String token,
    int recUserID,
  ) async {
    final result = await remoteDataSource.getBanners(token, recUserID);

    if (result.isSuccess && result.data != null) {
      // Cache local (persist) để vào lại Home hiển thị ngay
      await localDataSource.saveCachedBanners(
        recUserId: recUserID,
        banners: result.data!,
      );
      final banners = result.data!.map((dto) => dto.toDomain()).toList();
      return ApiResult.success(banners);
    }

    // Fallback local cache
    final cachedDtos = localDataSource.getCachedBanners(recUserId: recUserID);
    if (cachedDtos.isNotEmpty) {
      final cached = cachedDtos.map((e) => e.toDomain()).toList();
      return ApiResult.success(cached);
    }

    return ApiResult.error(result.error ?? 'Failed to get banners');
  }

  @override
  Future<ApiResult<List<Banner>>> getCachedBanners(int recUserID) async {
    final cachedDtos = localDataSource.getCachedBanners(recUserId: recUserID);
    final cached = cachedDtos.map((e) => e.toDomain()).toList();
    return ApiResult.success(cached);
  }
}
