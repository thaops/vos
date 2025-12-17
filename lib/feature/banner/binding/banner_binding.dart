import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/banner/data/datasources/local/banner_local_datasource.dart';
import 'package:vos_flutter/feature/banner/data/datasources/remote/banner_remote_datasource.dart';
import 'package:vos_flutter/feature/banner/data/repository_impl/banner_repository_impl.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_cached_banners_usecase.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_banners_usecase.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetStorage>()) {
      Get.lazyPut<GetStorage>(() => GetStorage(), fenix: true);
    }

    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Local Data Source (GetStorage)
    if (!Get.isRegistered<BannerLocalDataSource>()) {
      Get.lazyPut<BannerLocalDataSource>(
        () => BannerLocalDataSourceImpl(storage: Get.find<GetStorage>()),
      );
    }

    // Data Source
    if (!Get.isRegistered<BannerRemoteDataSource>()) {
      Get.lazyPut<BannerRemoteDataSource>(
        () => BannerRemoteDataSourceImpl(
          shareApiRepository: Get.find<ShareApiRepository>(),
        ),
        // ✅ Bỏ fenix: true - tránh cycle xóa/tạo lại khi dùng Get.offAllNamed()
      );
    }

    // Repository
    if (!Get.isRegistered<BannerRepository>()) {
      Get.lazyPut<BannerRepository>(
        () => BannerRepositoryImpl(
          remoteDataSource: Get.find<BannerRemoteDataSource>(),
          localDataSource: Get.find<BannerLocalDataSource>(),
        ),
        // ✅ Bỏ fenix: true - tránh cycle xóa/tạo lại khi dùng Get.offAllNamed()
      );
    }

    if (!Get.isRegistered<GetCachedBannersUsecase>()) {
      Get.lazyPut<GetCachedBannersUsecase>(
        () => GetCachedBannersUsecase(Get.find<BannerRepository>()),
      );
    }

    // Use Case
    if (!Get.isRegistered<GetBannersUsecase>()) {
      Get.lazyPut<GetBannersUsecase>(
        () => GetBannersUsecase(Get.find<BannerRepository>()),
        // ✅ Bỏ fenix: true - tránh cycle xóa/tạo lại khi dùng Get.offAllNamed()
      );
    }

    // Controller
    // ✅ Sửa: Bỏ fenix: true vì BannerController được quản lý bởi HomeTab.initState()
    // fenix: true gây ra cycle xóa/tạo lại khi dùng Get.offAllNamed()
    if (!Get.isRegistered<BannerController>()) {
      try {
        Get.lazyPut<BannerController>(
          () => BannerController(
            getBannersUsecase: Get.find<GetBannersUsecase>(),
            getCachedBannersUsecase: Get.find<GetCachedBannersUsecase>(),
          ),
          // ✅ Bỏ fenix: true - HomeTab sẽ tự quản lý lifecycle
        );
      } catch (e) {
        // Nếu đã được đăng ký trong lúc check, bỏ qua
        print('⚠️ BannerController registration error (may already exist): $e');
      }
    }
  }
}
