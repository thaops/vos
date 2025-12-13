import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class GetStatusesUsecase {
  final TimeOffFormRepository repository;

  GetStatusesUsecase({required this.repository});

  Future<ApiResult<List<Status>>> call() async {
    return await repository.getStatuses();
  }
}
