import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class UpdateAflVosUsecase {
  final TimeOffFormRepository repository;

  UpdateAflVosUsecase({required this.repository});

  Future<ApiResult<void>> call({
    required UpdateAflVosRequest request,
    required int vRegId,
    required String email,
  }) async {
    return await repository.updateAflVos(
      request: request,
      vRegId: vRegId,
      email: email,
    );
  }
}
