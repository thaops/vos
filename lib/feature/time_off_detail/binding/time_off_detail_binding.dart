import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/repository_impl/time_off_detail_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/controller/time_off_detail_controller.dart';
import 'package:vos_flutter/feature/time_off_update/data/repository_impl/time_off_update_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';

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

    // TimeOffCreateRemoteDataSource (để tái sử dụng cho Update)
    if (!Get.isRegistered<TimeOffCreateRemoteDataSource>()) {
      Get.lazyPut<TimeOffCreateRemoteDataSource>(
        () => TimeOffCreateRemoteDataSourceImpl(
          shareApiRepository: Get.find<ShareApiRepository>(),
        ),
      );
    }

    // FileUploadRemoteDataSource
    if (!Get.isRegistered<FileUploadRemoteDataSource>()) {
      Get.lazyPut<FileUploadRemoteDataSource>(
        () => FileUploadRemoteDataSourceImpl(),
      );
    }

    // TimeOffUpdateRepository
    Get.lazyPut<TimeOffUpdateRepository>(
      () => TimeOffUpdateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // Update Usecases
    Get.lazyPut<UpdateTimeOffUsecase>(
      () => UpdateTimeOffUsecase(
        repository: Get.find<TimeOffUpdateRepository>(),
      ),
    );

    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffUpdateRepository>(),
      ),
    );

    // Controller với args
    Get.lazyPut<TimeOffDetailController>(
      () => TimeOffDetailController(
        args: args,
        getTimeOffDetailUsecase: Get.find<GetTimeOffDetailUsecase>(),
        sendApproveRequestUsecase: Get.find<SendApproveRequestUsecase>(),
        updateTimeOffUsecase: Get.find<UpdateTimeOffUsecase>(),
      ),
    );
  }
}
