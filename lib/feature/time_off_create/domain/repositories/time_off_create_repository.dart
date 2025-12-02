import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
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
  Future<ApiResult<void>> createTimeOff(TimeOffCreateRequest request);
}
