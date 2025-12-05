import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/repository_impl/time_off_create_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/create_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/upload_files_usecase.dart';
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

    Get.lazyPut<FileUploadRemoteDataSource>(
      () => FileUploadRemoteDataSourceImpl(),
    );

    Get.lazyPut<TimeOffCreateRepository>(
      () => TimeOffCreateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    Get.lazyPut<GetLeaveTypesUsecase>(
      () =>
          GetLeaveTypesUsecase(repository: Get.find<TimeOffCreateRepository>()),
    );

    Get.lazyPut<GetStatusesUsecase>(
      () => GetStatusesUsecase(repository: Get.find<TimeOffCreateRepository>()),
    );

    Get.lazyPut<GetVacationReasonsUsecase>(
      () => GetVacationReasonsUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<GetAllVacationReasonsUsecase>(
      () => GetAllVacationReasonsUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<GetWorkCodesUsecase>(
      () =>
          GetWorkCodesUsecase(repository: Get.find<TimeOffCreateRepository>()),
    );

    Get.lazyPut<GetLeaveLocationsUsecase>(
      () => GetLeaveLocationsUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<CreateTimeOffUsecase>(
      () =>
          CreateTimeOffUsecase(repository: Get.find<TimeOffCreateRepository>()),
    );

    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<UploadFilesUsecase>(
      () => UploadFilesUsecase(
        repository: Get.find<TimeOffCreateRepository>(),
      ),
    );

    Get.lazyPut<TimeOffCreateController>(
      () => TimeOffCreateController(
        getLeaveTypesUsecase: Get.find<GetLeaveTypesUsecase>(),
        getStatusesUsecase: Get.find<GetStatusesUsecase>(),
        getVacationReasonsUsecase: Get.find<GetVacationReasonsUsecase>(),
        getAllVacationReasonsUsecase: Get.find<GetAllVacationReasonsUsecase>(),
        getWorkCodesUsecase: Get.find<GetWorkCodesUsecase>(),
        getLeaveLocationsUsecase: Get.find<GetLeaveLocationsUsecase>(),
        createTimeOffUsecase: Get.find<CreateTimeOffUsecase>(),
        sendApproveRequestUsecase: Get.find<SendApproveRequestUsecase>(),
        uploadFilesUsecase: Get.find<UploadFilesUsecase>(),
      ),
    );
  }
}
