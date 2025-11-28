import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';

class GetTimeOffListUsecase {
  final TimeOffRepository repository;

  GetTimeOffListUsecase({required this.repository});

  Future<ApiResult<List<TimeOff>>> call({int vRegId = 0, int year = 0}) async {
    return await repository.getTimeOffList(vRegId: vRegId, year: year);
  }
}
