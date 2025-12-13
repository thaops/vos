import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class GetPersonalVacationUsecase {
  final TimeOffFormRepository repository;

  GetPersonalVacationUsecase({required this.repository});

  Future<ApiResult<PersonalVacation>> call({required int hrId}) async {
    return await repository.getPersonalVacation(hrId: hrId);
  }
}
