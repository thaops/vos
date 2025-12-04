import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class SendApproveRequestUsecase {
  final TimeOffCreateRepository repository;

  SendApproveRequestUsecase({required this.repository});

  Future<ApiResult<void>> call(int vRegId) async {
    // Bỏ email parameter
    return await repository.sendApproveRequest(vRegId);
  }
}
