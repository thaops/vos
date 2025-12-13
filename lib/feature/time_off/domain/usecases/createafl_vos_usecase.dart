import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class CreateAflVosUsecase {
  final TimeOffFormRepository repository;

  CreateAflVosUsecase({required this.repository});

  Future<ApiResult<void>> call({
    required CreateAflVosRequest request,
    required String email,
  }) async {
    return await repository.createAflVos(request: request, email: email);
  }
}

