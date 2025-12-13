import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class SendApproveRequestUsecase {
  final TimeOffFormRepository repository;

  SendApproveRequestUsecase({required this.repository});

  Future<ApiResult<SendApproveResult>> call(int vRegId) async {
    return await repository.sendApproveRequest(vRegId);
  }
}
