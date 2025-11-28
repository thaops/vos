import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/data/datasources/remote/time_off_create_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/repositories/time_off_create_repository.dart';

class TimeOffCreateRepositoryImpl implements TimeOffCreateRepository {
  final TimeOffCreateRemoteDataSource remoteDataSource;

  TimeOffCreateRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<ApiResult<List<LeaveType>>> getLeaveTypes() async {
    return await remoteDataSource.getLeaveTypes();
  }

  @override
  Future<ApiResult<List<Status>>> getStatuses() async {
    return await remoteDataSource.getStatuses();
  }
}

