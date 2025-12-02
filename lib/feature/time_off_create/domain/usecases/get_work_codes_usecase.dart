import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetWorkCodesUsecase {
  final TimeOffCreateRepository repository;

  GetWorkCodesUsecase({required this.repository});

  Future<ApiResult<List<WorkCode>>> call() async {
    return await repository.getWorkCodes();
  }
}

