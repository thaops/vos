import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_form_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_repository_impl.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_form_repository_impl.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/recall_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/updateafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_list_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_time_off_status_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_controller.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/repository_impl/time_off_detail_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';

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

    Get.lazyPut<TimeOffFormRemoteDataSource>(
      () => TimeOffFormRemoteDataSourceImpl(
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

    Get.lazyPut<TimeOffFormRepository>(
      () => TimeOffFormRepositoryImpl(
        remoteDataSource: Get.find<TimeOffFormRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // ✅ Thêm TimeOffDetailRepository và UseCase
    Get.lazyPut<TimeOffDetailRemoteDataSource>(
      () => TimeOffDetailRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    Get.lazyPut<TimeOffDetailRepository>(
      () => TimeOffDetailRepositoryImpl(
        remoteDataSource: Get.find<TimeOffDetailRemoteDataSource>(),
      ),
    );

    Get.lazyPut<GetTimeOffDetailUsecase>(
      () => GetTimeOffDetailUsecase(
        repository: Get.find<TimeOffDetailRepository>(),
      ),
    );

    Get.lazyPut<CreateAflVosUsecase>(
      () => CreateAflVosUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    Get.lazyPut<UpdateAflVosUsecase>(
      () => UpdateAflVosUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    // Use Case
    Get.lazyPut<GetTimeOffListUsecase>(
      () => GetTimeOffListUsecase(repository: Get.find<TimeOffRepository>()),
    );

    Get.lazyPut<GetTimeOffStatusUsecase>(
      () => GetTimeOffStatusUsecase(repository: Get.find<TimeOffRepository>()),
    );

    Get.lazyPut<UpdateTimeOffUsecase>(
      () => UpdateTimeOffUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<RecallTimeOffUsecase>(
      () => RecallTimeOffUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    // Controller
    Get.lazyPut<TimeOffController>(
      () => TimeOffController(
        getTimeOffListUsecase: Get.find<GetTimeOffListUsecase>(),
        getTimeOffStatusUsecase: Get.find<GetTimeOffStatusUsecase>(),
        getTimeOffDetailUsecase: Get.find<GetTimeOffDetailUsecase>(),
        updateTimeOffUsecase: Get.find<UpdateTimeOffUsecase>(),
        sendApproveRequestUsecase: Get.find<SendApproveRequestUsecase>(),
        recallTimeOffUsecase: Get.find<RecallTimeOffUsecase>(),
        createAflVosUsecase: Get.find<CreateAflVosUsecase>(),
        updateAflVosUsecase: Get.find<UpdateAflVosUsecase>(),
      ),
    );
  }
}
