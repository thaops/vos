import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/feature/banner/data/datasources/remote/banner_remote_datasource.dart';
import 'package:vos_flutter/feature/banner/data/repository_impl/banner_repository_impl.dart';
import 'package:vos_flutter/feature/banner/domain/repositories/banner_repository.dart';
import 'package:vos_flutter/feature/banner/domain/usecases/get_banners_usecase.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<BannerRemoteDataSource>(
      () => BannerRemoteDataSourceImpl(
        dio: dioLib.Dio(),
      ),
    );

    // Repository
    Get.lazyPut<BannerRepository>(
      () => BannerRepositoryImpl(
        remoteDataSource: Get.find<BannerRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetBannersUsecase>(
      () => GetBannersUsecase(
        Get.find<BannerRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<BannerController>(
      () => BannerController(
        getBannersUsecase: Get.find<GetBannersUsecase>(),
      ),
    );
  }
}

