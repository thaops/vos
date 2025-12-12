import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';
import 'package:vos_flutter/feature/vacation/domain/repositories/vacation_repository.dart';

class GetVacationListUsecase {
  final VacationRepository repository;

  GetVacationListUsecase({required this.repository});

  Future<ApiResult<List<Vacation>>> call({
    int year = 0,
    int hrId = 0,
    String viewData = '',
  }) async {
    return repository.getVacationList(
      year: year,
      hrId: hrId,
      viewData: viewData,
    );
  }
}

