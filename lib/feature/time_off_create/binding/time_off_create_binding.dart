import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/repository_impl/time_off_create_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/controller/time_off_create_controller.dart';

class TimeOffCreateBinding extends Bindings {
  @override
  void dependencies() {
    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    Get.lazyPut<TimeOffCreateRemoteDataSource>(
      () => TimeOffCreateRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    Get.lazyPut<TimeOffCreateRepository>(
      () => TimeOffCreateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
      ),
    );

    Get.lazyPut<GetLeaveTypesUsecase>(
      () => GetLeaveTypesUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<GetStatusesUsecase>(
      () => GetStatusesUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<TimeOffCreateController>(
      () => TimeOffCreateController(
        getLeaveTypesUsecase: Get.find<GetLeaveTypesUsecase>(),
        getStatusesUsecase: Get.find<GetStatusesUsecase>(),
      ),
    );
  }
}

