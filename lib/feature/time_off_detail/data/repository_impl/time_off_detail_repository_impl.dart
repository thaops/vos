import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/data/datasources/remote/time_off_detail_remote_datasource.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/repositories/time_off_detail_repository.dart';

class TimeOffDetailRepositoryImpl implements TimeOffDetailRepository {
  final TimeOffDetailRemoteDataSource remoteDataSource;

  TimeOffDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<TimeOff>> getTimeOffDetail({required int vRegId}) async {
    return await remoteDataSource.getTimeOffDetail(vRegId: vRegId);
  }
}

