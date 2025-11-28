import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_repository_impl.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_controller.dart';

class TimeOffBinding extends Bindings {
  @override
  void dependencies() {
    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source
    Get.lazyPut<TimeOffRemoteDataSource>(
      () => TimeOffRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // Repository
    Get.lazyPut<TimeOffRepository>(
      () => TimeOffRepositoryImpl(
        remoteDataSource: Get.find<TimeOffRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetTimeOffListUsecase>(
      () => GetTimeOffListUsecase(
        repository: Get.find<TimeOffRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<TimeOffController>(
      () => TimeOffController(
        getTimeOffListUsecase: Get.find<GetTimeOffListUsecase>(),
      ),
    );
  }
}

