import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class CreateTimeOffUsecase {
  final TimeOffCreateRepository repository;

  CreateTimeOffUsecase({required this.repository});

  Future<ApiResult<int>> call(TimeOffCreateRequest request) async {
    return await repository.createTimeOff(request);
  }
}
