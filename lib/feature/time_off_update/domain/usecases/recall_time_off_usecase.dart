import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';

class RecallTimeOffUsecase {
  final TimeOffUpdateRepository repository;

  RecallTimeOffUsecase({required this.repository});

  Future<ApiResult<void>> call(int vRegId) async {
    return await repository.recallTimeOff(vRegId);
  }
}

