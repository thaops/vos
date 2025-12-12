import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/personal_vacation.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetPersonalVacationUsecase {
  final TimeOffCreateRepository repository;

  GetPersonalVacationUsecase({required this.repository});

  Future<ApiResult<PersonalVacation>> call({required int hrId}) async {
    return await repository.getPersonalVacation(hrId: hrId);
  }
}
