import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetStatusesUsecase {
  final TimeOffCreateRepository repository;

  GetStatusesUsecase({required this.repository});

  Future<ApiResult<List<Status>>> call() async {
    return await repository.getStatuses();
  }
}
