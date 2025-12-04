import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

abstract class TimeOffDetailRepository {
  Future<ApiResult<TimeOff>> getTimeOffDetail({required int vRegId});
}

