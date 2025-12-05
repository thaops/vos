import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/repository_impl/time_off_create_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/data/repository_impl/time_off_update_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/upload_files_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';

class TimeOffUpdateBinding extends Bindings {
  @override
  void dependencies() {
    // Parse arguments tại đây
    final args = Get.arguments as TimeOffUpdateArgs;

    // ShareApiRepository (singleton)
    if (!Get.isRegistered<ShareApiRepository>()) {
      Get.lazyPut<ShareApiRepository>(
        () => ShareApiRepository(dio: dioLib.Dio()),
      );
    }

    // Tái sử dụng RemoteDataSource từ time_off_create
    Get.lazyPut<TimeOffCreateRemoteDataSource>(
      () => TimeOffCreateRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    Get.lazyPut<FileUploadRemoteDataSource>(
      () => FileUploadRemoteDataSourceImpl(),
    );

    // Tái sử dụng TimeOffCreateRepository cho các usecase get
    Get.lazyPut<TimeOffCreateRepository>(
      () => TimeOffCreateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // TimeOffUpdateRepository cho UpdateUsecase
    Get.lazyPut<TimeOffUpdateRepository>(
      () => TimeOffUpdateRepositoryImpl(
        remoteDataSource: Get.find<TimeOffCreateRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // Usecases - tái sử dụng từ create
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

    // UpdateUsecase riêng
    Get.lazyPut<UpdateTimeOffUsecase>(
      () =>
          UpdateTimeOffUsecase(repository: Get.find<TimeOffUpdateRepository>()),
    );
    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffUpdateRepository>(),
      ),
    );

    Get.lazyPut<UploadFilesUsecase>(
      () => UploadFilesUsecase(
        repository: Get.find<TimeOffUpdateRepository>(),
      ),
    );

    // Controller với args
    Get.lazyPut<TimeOffUpdateController>(
      () => TimeOffUpdateController(
        args: args,
        getLeaveTypesUsecase: Get.find<GetLeaveTypesUsecase>(),
        getStatusesUsecase: Get.find<GetStatusesUsecase>(),
        getVacationReasonsUsecase: Get.find<GetVacationReasonsUsecase>(),
        getAllVacationReasonsUsecase: Get.find<GetAllVacationReasonsUsecase>(),
        getWorkCodesUsecase: Get.find<GetWorkCodesUsecase>(),
        getLeaveLocationsUsecase: Get.find<GetLeaveLocationsUsecase>(),
        updateTimeOffUsecase: Get.find<UpdateTimeOffUsecase>(),
        sendApproveRequestUsecase: Get.find<SendApproveRequestUsecase>(),
        uploadFilesUsecase: Get.find<UploadFilesUsecase>(),
      ),
    );
  }
}
