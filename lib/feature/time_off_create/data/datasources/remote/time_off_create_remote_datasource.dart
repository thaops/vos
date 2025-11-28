import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/leave_type_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/status_dto.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';

abstract class TimeOffCreateRemoteDataSource {
  Future<ApiResult<List<LeaveType>>> getLeaveTypes();
  Future<ApiResult<List<Status>>> getStatuses();
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
        if (json is! List) return [];
        
        final statuses = <Status>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = StatusDto.fromJson(item);
            statuses.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return statuses;
      },
    );
  }
}

