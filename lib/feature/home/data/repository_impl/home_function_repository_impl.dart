import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/home/data/datasources/remote/home_function_remote_datasource.dart';
import 'package:vos_flutter/feature/home/domain/models/home_function.dart';
import 'package:vos_flutter/feature/home/domain/repositories/home_function_repository.dart';

class HomeFunctionRepositoryImpl implements HomeFunctionRepository {
  final HomeFunctionRemoteDataSource remoteDataSource;

  HomeFunctionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<HomeFunctionSession>>> getHomeFunctions(
      String token, String lsStatus) async {
    final result = await remoteDataSource.getHomeFunctions(token, lsStatus);

    if (result.isSuccess && result.data != null) {
      final sessions =
          result.data!.map((dto) => dto.toDomain()).toList();
      return ApiResult.success(sessions);
    }

    return ApiResult.error(result.error ?? 'Failed to get home functions');
  }
}

