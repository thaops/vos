import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';

class SendApproveRequestUsecase {
  final TimeOffCreateRepository repository;

  SendApproveRequestUsecase({required this.repository});

  Future<ApiResult<SendApproveResult>> call(int vRegId) async {
    return await repository.sendApproveRequest(vRegId);
  }
}
