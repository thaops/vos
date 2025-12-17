import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/feature/banner/data/models/banner_dto.dart';

abstract class BannerLocalDataSource {
  List<BannerDto> getCachedBanners({required int recUserId});
  Future<void> saveCachedBanners({
    required int recUserId,
    required List<BannerDto> banners,
  });
  Future<void> clearCachedBanners({required int recUserId});
}

class BannerLocalDataSourceImpl implements BannerLocalDataSource {
  static const String _keyPrefix = 'home_banner_cache_user_';

  final GetStorage storage;

  BannerLocalDataSourceImpl({required this.storage});

  String _key(int recUserId) => '$_keyPrefix$recUserId';

  @override
  List<BannerDto> getCachedBanners({required int recUserId}) {
    try {
      final raw = storage.read(_key(recUserId));
      if (raw is! List) return <BannerDto>[];
      return raw
          .whereType<Map>()
          .map((e) => BannerDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return <BannerDto>[];
    }
  }

  @override
  Future<void> saveCachedBanners({
    required int recUserId,
    required List<BannerDto> banners,
  }) async {
    try {
      await storage.write(
        _key(recUserId),
        banners.map((e) => e.toJson()).toList(),
      );
    } catch (_) {
      // Ignore cache write errors
    }
  }

  @override
  Future<void> clearCachedBanners({required int recUserId}) async {
    try {
      await storage.remove(_key(recUserId));
    } catch (_) {
      // Ignore
    }
  }
}
