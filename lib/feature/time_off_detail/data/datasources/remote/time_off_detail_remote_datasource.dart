import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/feature/time_off/data/models/time_off_dto.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

abstract class TimeOffDetailRemoteDataSource {
  Future<ApiResult<TimeOff>> getTimeOffDetail({required int vRegId});
}

class TimeOffDetailRemoteDataSourceImpl extends BaseShareDataSource
    implements TimeOffDetailRemoteDataSource {
  TimeOffDetailRemoteDataSourceImpl({required super.shareApiRepository});

  @override
  Future<ApiResult<TimeOff>> getTimeOffDetail({required int vRegId}) async {
    return shareApiRepository.callShareGet<TimeOff>(
      functionCode: 'Vacation_Register_Get',
      token: getToken(),
      data: {'VReg_ID': vRegId, 'Year': 0, 'ViewData': 'ALL'},
      parser: (json) {
        if (json is! List || json.isEmpty) {
          throw Exception('No data found');
        }

        final item = json[0];
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid data format');
        }

        final allNull = item.values.every((value) => value == null);
        if (allNull) {
          throw Exception('All values are null');
        }

        final dto = TimeOffDto.fromJson(item);
        return dto.toDomain();
      },
    );
  }
}
