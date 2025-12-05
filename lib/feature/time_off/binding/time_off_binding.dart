import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_repository_impl.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_controller.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_update/data/repository_impl/time_off_update_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';

class TimeOffBinding extends Bindings {
  @override
  void dependencies() {
    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source cho TimeOff
    Get.lazyPut<TimeOffRemoteDataSource>(
      () => TimeOffRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // ✅ Thêm TimeOffCreateRemoteDataSource (cần cho TimeOffUpdateRepository)
    Get.lazyPut<TimeOffCreateRemoteDataSource>(
      () => TimeOffCreateRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // ✅ Thêm FileUploadRemoteDataSource
    Get.lazyPut<FileUploadRemoteDataSource>(
      () => FileUploadRemoteDataSourceImpl(),
    );

    // Repository cho TimeOff
    Get.lazyPut<TimeOffRepository>(
      () => TimeOffRepositoryImpl(
        remoteDataSource: Get.find<TimeOffRemoteDataSource>(),
      ),
    );

    // ✅ Thêm TimeOffUpdateRepository
    Get.lazyPut<TimeOffUpdateRepository>(
      () => TimeOffUpdateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetTimeOffListUsecase>(
      () => GetTimeOffListUsecase(repository: Get.find<TimeOffRepository>()),
    );

    Get.lazyPut<UpdateTimeOffUsecase>(
      () =>
          UpdateTimeOffUsecase(repository: Get.find<TimeOffUpdateRepository>()),
    );

    // Controller
    Get.lazyPut<TimeOffController>(
      () => TimeOffController(
        getTimeOffListUsecase: Get.find<GetTimeOffListUsecase>(),
        updateTimeOffUsecase: Get.find<UpdateTimeOffUsecase>(),
      ),
    );
  }
}
