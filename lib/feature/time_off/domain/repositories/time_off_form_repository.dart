import 'dart:io';

import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';

/// Repository nghiệp vụ cho form Time Off (create/update).
/// - Lookup data (leave types, statuses, work codes...)
/// - Upload files
/// - Upsert request (backend dùng chung Vacation_Register_Update)
/// - Approve/Recall
abstract class TimeOffFormRepository {
  Future<ApiResult<List<LeaveType>>> getLeaveTypes();
  Future<ApiResult<List<Status>>> getStatuses();
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  });
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons();
  Future<ApiResult<List<WorkCode>>> getWorkCodes();
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations();

  /// Create/Update dùng chung 1 API -> trả về VReg_ID
  Future<ApiResult<int>> upsertTimeOff(TimeOffCreateRequest request);

  Future<ApiResult<SendApproveResult>> sendApproveRequest(int vRegId);
  Future<ApiResult<void>> recallTimeOff(int vRegId);
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

  Future<ApiResult<PersonalVacation>> getPersonalVacation({required int hrId});
}


