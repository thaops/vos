import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/repository_impl/time_off_detail_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/controller/time_off_detail_controller.dart';

class TimeOffDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Parse arguments tại đây
    final args = Get.arguments as TimeOffDetailArgs;

    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Data Source
    Get.lazyPut<TimeOffDetailRemoteDataSource>(
      () => TimeOffDetailRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    // Repository
    Get.lazyPut<TimeOffDetailRepository>(
      () => TimeOffDetailRepositoryImpl(
        remoteDataSource: Get.find<TimeOffDetailRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<GetTimeOffDetailUsecase>(
      () => GetTimeOffDetailUsecase(
        repository: Get.find<TimeOffDetailRepository>(),
      ),
    );

    // Controller với args
    Get.lazyPut<TimeOffDetailController>(
      () => TimeOffDetailController(
        args: args,
        getTimeOffDetailUsecase: Get.find<GetTimeOffDetailUsecase>(),
      ),
    );
  }
}
