import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';

class UpdateTimeOffUsecase {
  final TimeOffUpdateRepository repository;

  UpdateTimeOffUsecase({required this.repository});

  Future<ApiResult<void>> call(TimeOffCreateRequest request) async {
    return await repository.updateTimeOff(request);
  }
}
