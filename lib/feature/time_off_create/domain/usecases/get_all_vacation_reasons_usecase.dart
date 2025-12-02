import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetAllVacationReasonsUsecase {
  final TimeOffCreateRepository repository;

  GetAllVacationReasonsUsecase({required this.repository});

  Future<ApiResult<List<VacationReason>>> call() async {
    return await repository.getAllVacationReasons();
  }
}

