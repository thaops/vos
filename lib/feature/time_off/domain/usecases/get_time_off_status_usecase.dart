import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_status.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';

class GetTimeOffStatusUsecase {
  final TimeOffRepository repository;

  GetTimeOffStatusUsecase({required this.repository});

  Future<ApiResult<List<TimeOffStatus>>> call() async {
    return await repository.getStatusList();
  }
}
