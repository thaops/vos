import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetVacationReasonsUsecase {
  final TimeOffCreateRepository repository;

  GetVacationReasonsUsecase({required this.repository});

  Future<ApiResult<List<VacationReason>>> call({
    required String workCode,
    required String name,
  }) async {
    return await repository.getVacationReasons(
      workCode: workCode,
      name: name,
    );
  }
}

