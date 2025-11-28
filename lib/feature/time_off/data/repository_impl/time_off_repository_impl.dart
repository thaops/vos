import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/data/datasources/remote/time_off_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/repositories/time_off_repository.dart';

class TimeOffRepositoryImpl implements TimeOffRepository {
  final TimeOffRemoteDataSource remoteDataSource;

  TimeOffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<TimeOff>>> getTimeOffList({
    int vRegId = 0,
    int year = 0,
  }) async {
    return await remoteDataSource.getTimeOffList(vRegId: vRegId, year: year);
  }
}
