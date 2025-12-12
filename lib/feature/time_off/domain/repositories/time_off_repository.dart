import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_status.dart';

abstract class TimeOffRepository {
  Future<ApiResult<List<TimeOff>>> getTimeOffList({
    int vRegId = 0,
    int year = 0,
  });

  Future<ApiResult<List<TimeOffStatus>>> getStatusList();
}
