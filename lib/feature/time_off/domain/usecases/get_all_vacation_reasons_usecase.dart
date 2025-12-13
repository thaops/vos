import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class GetAllVacationReasonsUsecase {
  final TimeOffFormRepository repository;

  GetAllVacationReasonsUsecase({required this.repository});

  Future<ApiResult<List<VacationReason>>> call() async {
    return await repository.getAllVacationReasons();
  }
}

