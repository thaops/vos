import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_form_repository.dart';

class GetLeaveTypesUsecase {
  final TimeOffFormRepository repository;

  GetLeaveTypesUsecase({required this.repository});

  Future<ApiResult<List<LeaveType>>> call() async {
    return await repository.getLeaveTypes();
  }
}

