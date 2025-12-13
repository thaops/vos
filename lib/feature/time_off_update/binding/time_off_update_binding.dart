import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_form_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/repository_impl/time_off_form_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/upload_files_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/time_off_form_controller.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/data/repository_impl/time_off_detail_repository_impl.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';

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

    Get.lazyPut<TimeOffFormRemoteDataSource>(
      () => TimeOffFormRemoteDataSourceImpl(
        shareApiRepository: Get.find<ShareApiRepository>(),
      ),
    );

    Get.lazyPut<FileUploadRemoteDataSource>(
      () => FileUploadRemoteDataSourceImpl(),
    );

    Get.lazyPut<TimeOffFormRepository>(
      () => TimeOffFormRepositoryImpl(
        remoteDataSource: Get.find<TimeOffFormRemoteDataSource>(),
        fileUploadDataSource: Get.find<FileUploadRemoteDataSource>(),
      ),
    );

    // Usecases - tái sử dụng từ create
    Get.lazyPut<GetLeaveTypesUsecase>(
      () =>
          GetLeaveTypesUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    Get.lazyPut<GetStatusesUsecase>(
      () => GetStatusesUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    Get.lazyPut<GetVacationReasonsUsecase>(
      () => GetVacationReasonsUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<GetAllVacationReasonsUsecase>(
      () => GetAllVacationReasonsUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<GetWorkCodesUsecase>(
      () =>
          GetWorkCodesUsecase(repository: Get.find<TimeOffFormRepository>()),
    );

    Get.lazyPut<GetLeaveLocationsUsecase>(
      () => GetLeaveLocationsUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<GetPersonalVacationUsecase>(
      () => GetPersonalVacationUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    // UpdateUsecase riêng
    Get.lazyPut<UpdateTimeOffUsecase>(
      () =>
          UpdateTimeOffUsecase(repository: Get.find<TimeOffFormRepository>()),
    );
    Get.lazyPut<SendApproveRequestUsecase>(
      () => SendApproveRequestUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    Get.lazyPut<UploadFilesUsecase>(
      () => UploadFilesUsecase(
        repository: Get.find<TimeOffFormRepository>(),
      ),
    );

    // ✅ Thêm CreateAflVosUsecase
    Get.lazyPut<CreateAflVosUsecase>(
      () => CreateAflVosUsecase(
        repository: Get.find<TimeOffFormRepository>(),
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

    Get.lazyPut<TimeOffFormController>(
      () => TimeOffFormController(
        mode: TimeOffFormMode.update,
        initialTimeOff: args.timeOff,
        getLeaveTypesUsecase: Get.find<GetLeaveTypesUsecase>(),
        getStatusesUsecase: Get.find<GetStatusesUsecase>(),
        getVacationReasonsUsecase: Get.find<GetVacationReasonsUsecase>(),
        getAllVacationReasonsUsecase: Get.find<GetAllVacationReasonsUsecase>(),
        getWorkCodesUsecase: Get.find<GetWorkCodesUsecase>(),
        getLeaveLocationsUsecase: Get.find<GetLeaveLocationsUsecase>(),
        getPersonalVacationUsecase: Get.find<GetPersonalVacationUsecase>(),
        updateTimeOffUsecase: Get.find<UpdateTimeOffUsecase>(),
        sendApproveRequestUsecase: Get.find<SendApproveRequestUsecase>(),
        uploadFilesUsecase: Get.find<UploadFilesUsecase>(),
        createAflVosUsecase: Get.find<CreateAflVosUsecase>(),
        getTimeOffDetailUsecase: Get.find<GetTimeOffDetailUsecase>(),
      ),
      tag: TimeOffFormController.tagUpdate,
    );
  }
}
