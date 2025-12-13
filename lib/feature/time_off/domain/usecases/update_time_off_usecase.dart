import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class UpdateTimeOffUsecase {
  final TimeOffFormRepository repository;

  UpdateTimeOffUsecase({required this.repository});

  Future<ApiResult<int>> call(TimeOffCreateRequest request) async {
    return await repository.upsertTimeOff(request);
  }
}
