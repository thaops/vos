import 'dart:io';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/file_upload_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_form_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/models/time_off_create_request_dto.dart';
import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class TimeOffFormRepositoryImpl implements TimeOffFormRepository {
  final TimeOffFormRemoteDataSource remoteDataSource;
  final FileUploadRemoteDataSource fileUploadDataSource;

  TimeOffFormRepositoryImpl({
    required this.remoteDataSource,
    required this.fileUploadDataSource,
  });

  @override
  Future<ApiResult<List<LeaveType>>> getLeaveTypes() async {
    return await remoteDataSource.getLeaveTypes();
  }

  @override
  Future<ApiResult<List<Status>>> getStatuses() async {
    return await remoteDataSource.getStatuses();
  }

  @override
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  }) async {
    return await remoteDataSource.getVacationReasons(
      workCode: workCode,
      name: name,
    );
  }

  @override
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons() async {
    return await remoteDataSource.getAllVacationReasons();
  }

  @override
  Future<ApiResult<List<WorkCode>>> getWorkCodes() async {
    return await remoteDataSource.getWorkCodes();
  }

  @override
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations() async {
    return await remoteDataSource.getLeaveLocations();
  }

  @override
  Future<ApiResult<int>> upsertTimeOff(TimeOffCreateRequest request) async {
    final dto = TimeOffCreateRequestDto.fromDomain(request);
    return await remoteDataSource.createTimeOff(dto);
  }
  
  @override
  Future<ApiResult<SendApproveResult>> sendApproveRequest(int vRegId) {
    return remoteDataSource.sendApproveRequest(vRegId);
  }

  @override
  Future<ApiResult<void>> recallTimeOff(int vRegId) {
    return remoteDataSource.recallTimeOff(vRegId);
  }

  @override
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files) async {
    return await fileUploadDataSource.uploadFiles(files);
  }

  @override
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  }) {
    return remoteDataSource.createAflVos(request: request, email: email);
  }

  @override
  Future<ApiResult<void>> updateAflVos({
    required UpdateAflVosRequest request,
    required int vRegId,
    required String email,
  }) {
    return remoteDataSource.updateAflVos(
      request: request,
      vRegId: vRegId,
      email: email,
    );
  }

  @override
  Future<ApiResult<PersonalVacation>> getPersonalVacation({
    required int hrId,
  }) async {
    return await remoteDataSource.getPersonalVacation(hrId: hrId);
  }
}
