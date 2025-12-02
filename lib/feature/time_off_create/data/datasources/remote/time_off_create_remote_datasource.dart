import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/leave_location_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/leave_type_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/status_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/time_off_create_request_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/vacation_reason_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/work_code_dto.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';

abstract class TimeOffCreateRemoteDataSource {
  Future<ApiResult<List<LeaveType>>> getLeaveTypes();
  Future<ApiResult<List<Status>>> getStatuses();
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  });
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons();
  Future<ApiResult<List<WorkCode>>> getWorkCodes();
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations();
  Future<ApiResult<void>> createTimeOff(TimeOffCreateRequestDto request);
}

class TimeOffCreateRemoteDataSourceImpl extends BaseShareDataSource
    implements TimeOffCreateRemoteDataSource {
  TimeOffCreateRemoteDataSourceImpl({required super.shareApiRepository});

  @override
  Future<ApiResult<List<LeaveType>>> getLeaveTypes() async {
    return shareApiRepository.callShareGet<List<LeaveType>>(
      functionCode: 'CODE_JOB_VACATION',
      token: getToken(), // Tự động lấy token từ base class
      data: {},
      parser: (json) {
        if (json is! List) return [];

        final leaveTypes = <LeaveType>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = LeaveTypeDto.fromJson(item);
            leaveTypes.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return leaveTypes;
      },
    );
  }

  @override
  Future<ApiResult<List<Status>>> getStatuses() async {
    return shareApiRepository.callShareGet<List<Status>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Status',
      token: getToken(),
      data: {},
      parser: (json) {
        print('🔍 [Status] Parser received: ${json.runtimeType}');
        if (json is! List) {
          print('❌ [Status] Response is not a List: ${json.runtimeType}');
          return [];
        }

        print('✅ [Status] Parsing ${json.length} items');
        final statuses = <Status>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              print(
                '⚠️ [Status] Item at index $i is not a Map: ${item.runtimeType}',
              );
              continue;
            }

            print('📝 [Status] Parsing item $i: $item');
            final dto = StatusDto.fromJson(item);
            statuses.add(dto.toDomain());
            print('✅ [Status] Parsed: ${dto.code} - ${dto.nameVn}');
          } catch (e, stackTrace) {
            print('❌ [Status] Error parsing item at index $i: $e');
            print('Stack trace: $stackTrace');
            continue;
          }
        }
        print('✅ [Status] Successfully parsed ${statuses.length} statuses');
        return statuses;
      },
    );
  }

  @override
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  }) async {
    return shareApiRepository.callShareGet<List<VacationReason>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Vacation_Reason',
      token: getToken(),
      data: {'Code': workCode, 'Name': name},
      parser: (json) {
        if (json is! List) return [];

        final reasons = <VacationReason>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = VacationReasonDto.fromJson(item);
            reasons.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return reasons;
      },
    );
  }

  @override
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons() async {
    return shareApiRepository.callShareGet<List<VacationReason>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Vacation_Reason',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) {
          print(
            '⚠️ [VacationReason] Response is not a List: ${json.runtimeType}',
          );
          return [];
        }

        print('✅ [VacationReason] Parsing ${json.length} items');
        final reasons = <VacationReason>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              print(
                '⚠️ [VacationReason] Item at index $i is not a Map: ${item.runtimeType}',
              );
              continue;
            }

            final dto = VacationReasonDto.fromJson(item);
            reasons.add(dto.toDomain());
            print('✅ [VacationReason] Parsed: ${dto.code} - ${dto.nameVn}');
          } catch (e, stackTrace) {
            print('❌ [VacationReason] Error parsing item at index $i: $e');
            print('Stack trace: $stackTrace');
            continue;
          }
        }
        print(
          '✅ [VacationReason] Successfully parsed ${reasons.length} reasons',
        );
        return reasons;
      },
    );
  }

  @override
  Future<ApiResult<List<WorkCode>>> getWorkCodes() async {
    return shareApiRepository.callShareGet<List<WorkCode>>(
      functionCode: 'CODE_JOB_VACATION',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) return [];

        final workCodes = <WorkCode>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = WorkCodeDto.fromJson(item);
            workCodes.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return workCodes;
      },
    );
  }

  @override
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations() async {
    return shareApiRepository.callShareGet<List<LeaveLocation>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Dom_Int',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) {
          print(
            '⚠️ [LeaveLocation] Response is not a List: ${json.runtimeType}',
          );
          return [];
        }

        print('✅ [LeaveLocation] Parsing ${json.length} items');
        final locations = <LeaveLocation>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              print(
                '⚠️ [LeaveLocation] Item at index $i is not a Map: ${item.runtimeType}',
              );
              continue;
            }

            final dto = LeaveLocationDto.fromJson(item);
            locations.add(dto.toDomain());
            print('✅ [LeaveLocation] Parsed: ${dto.code} - ${dto.nameVn}');
          } catch (e, stackTrace) {
            print('❌ [LeaveLocation] Error parsing item at index $i: $e');
            print('Stack trace: $stackTrace');
            continue;
          }
        }
        print(
          '✅ [LeaveLocation] Successfully parsed ${locations.length} locations',
        );
        return locations;
      },
    );
  }

  @override
  Future<ApiResult<void>> createTimeOff(TimeOffCreateRequestDto request) async {
    return shareApiRepository.callShareUpdate<void>(
      functionCode: 'Vacation_Register_Update',
      token: getToken(),
      data: request.toJson(),
      parser: (json) {
        // Response không cần parse, chỉ cần check ResultCode
        return;
      },
    );
  }
}
