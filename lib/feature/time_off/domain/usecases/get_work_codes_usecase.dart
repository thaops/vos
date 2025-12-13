import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class GetWorkCodesUsecase {
  final TimeOffFormRepository repository;

  GetWorkCodesUsecase({required this.repository});

  Future<ApiResult<List<WorkCode>>> call() async {
    return await repository.getWorkCodes();
  }
}

