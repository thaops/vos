import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/vacation/data/datasources/remote/vacation_remote_datasource.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';
import 'package:vos_flutter/feature/vacation/domain/repositories/vacation_repository.dart';

class VacationRepositoryImpl implements VacationRepository {
  final VacationRemoteDataSource remoteDataSource;

  VacationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<Vacation>>> getVacationList({
    int year = 0,
    int hrId = 0,
    String viewData = '',
  }) async {
    return remoteDataSource.getVacationList(
      year: year,
      hrId: hrId,
      viewData: viewData,
    );
  }
}

