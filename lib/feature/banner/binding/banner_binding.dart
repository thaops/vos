import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/banner/data/datasources/remote/banner_remote_datasource.dart';
import 'package:vos_flutter/feature/banner/data/repository_impl/banner_repository_impl.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_banners_usecase.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source
    if (!Get.isRegistered<BannerRemoteDataSource>()) {
      Get.lazyPut<BannerRemoteDataSource>(
        () => BannerRemoteDataSourceImpl(shareApiRepository: Get.find<ShareApiRepository>()),
        // ✅ Bỏ fenix: true - tránh cycle xóa/tạo lại khi dùng Get.offAllNamed()
      );
    }

    // Repository
    if (!Get.isRegistered<BannerRepository>()) {
      Get.lazyPut<BannerRepository>(
        () => BannerRepositoryImpl(
          remoteDataSource: Get.find<BannerRemoteDataSource>(),
        ),
        // ✅ Bỏ fenix: true - tránh cycle xóa/tạo lại khi dùng Get.offAllNamed()
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
