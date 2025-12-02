import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class GetLeaveLocationsUsecase {
  final TimeOffCreateRepository repository;

  GetLeaveLocationsUsecase({required this.repository});

  Future<ApiResult<List<LeaveLocation>>> call() async {
    return await repository.getLeaveLocations();
  }
}

