import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';

class GetTimeOffDetailUsecase {
  final TimeOffDetailRepository repository;

  GetTimeOffDetailUsecase({required this.repository});

  Future<ApiResult<TimeOff>> call({required int vRegId}) async {
    return await repository.getTimeOffDetail(vRegId: vRegId);
  }
}

