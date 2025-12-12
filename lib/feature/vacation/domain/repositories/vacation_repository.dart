import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';

abstract class VacationRepository {
  Future<ApiResult<List<Vacation>>> getVacationList({
    int year = 0,
    int hrId = 0,
    String viewData = '',
  });
}

