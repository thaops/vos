import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/repository_impl/time_off_detail_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/controller/time_off_detail_controller.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_form_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_form_repository_impl.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/update_time_off_usecase.dart';

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

    if (!Get.isRegistered<TimeOffFormRemoteDataSource>()) {
      Get.lazyPut<TimeOffFormRemoteDataSource>(
        () => TimeOffFormRemoteDataSourceImpl(
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

    Get.lazyPut<TimeOffFormRepository>(
      () => TimeOffFormRepositoryImpl(
        remoteDataSource: Get.find<TimeOffFormRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // Update Usecases
    Get.lazyPut<UpdateTimeOffUsecase>(
      () => UpdateTimeOffUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffFormRepository>(),
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
