import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/models/time_off_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/time_off_status_dto.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_status.dart';

abstract class TimeOffRemoteDataSource {
  Future<ApiResult<List<TimeOff>>> getTimeOffList({
    int vRegId = 0,
    int year = 0,
  });

  Future<ApiResult<List<TimeOffStatus>>> getStatusList();
}

class TimeOffRemoteDataSourceImpl extends BaseShareDataSource
    implements TimeOffRemoteDataSource {
  TimeOffRemoteDataSourceImpl({required super.shareApiRepository});

  @override
  Future<ApiResult<List<TimeOff>>> getTimeOffList({
    int vRegId = 0,
    int year = 0,
  }) async {
    return shareApiRepository.callShareGet<List<TimeOff>>(
      functionCode: 'Vacation_Register_Get',
      token: getToken(), // Tự động lấy token từ base class
      data: {'VReg_ID': vRegId, 'Year': year, 'ViewData': 'ALL'},
      parser: (json) {
        if (json is! List) return [];

        final timeOffs = <TimeOff>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            // Skip items where all values are null
            final allNull = item.values.every((value) => value == null);
            if (allNull) continue;

            final dto = TimeOffDto.fromJson(item);
            timeOffs.add(dto.toDomain());
          } catch (e) {
            print('Error parsing time off item: $e');
            continue;
          }
        }

        return timeOffs;
      },
    );
  }

  @override
  Future<ApiResult<List<TimeOffStatus>>> getStatusList() async {
    return shareApiRepository.callShareGet<List<TimeOffStatus>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.ApproveStatus',
      token: getToken(),
      data: const {},
      parser: (json) {
        if (json is! List) return [];

        return json
            .whereType<Map<String, dynamic>>()
            .map((item) => TimeOffStatusDto.fromJson(item).toDomain())
            .toList();
      },
    );
  }
}
