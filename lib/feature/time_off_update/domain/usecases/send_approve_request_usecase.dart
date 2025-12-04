import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';

class SendApproveRequestUsecase {
  final TimeOffUpdateRepository repository;

  SendApproveRequestUsecase({required this.repository});

  Future<ApiResult<int>> call(int vRegId) async {
    return await repository.sendApproveRequest(vRegId);
  }
}
