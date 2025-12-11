import 'dart:io';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';

abstract class TimeOffCreateRepository {
  Future<ApiResult<List<LeaveType>>> getLeaveTypes();
  Future<ApiResult<List<Status>>> getStatuses();
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  });
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons();
  Future<ApiResult<List<WorkCode>>> getWorkCodes();
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations();
  Future<ApiResult<int>> createTimeOff(TimeOffCreateRequest request);
  Future<ApiResult<SendApproveResult>> sendApproveRequest(int vRegId);
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files);
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  });
  Future<ApiResult<void>> updateAflVos({
    required UpdateAflVosRequest request,
    required int vRegId,
    required String email,
  });
}
