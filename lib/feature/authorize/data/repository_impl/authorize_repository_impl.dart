import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/data/datasources/remote/authorize_remote_datasource.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/feature/authorize/domain/repositories/authorize_repository.dart';

class AuthorizeRepositoryImpl implements AuthorizeRepository {
  final AuthorizeRemoteDataSource remoteDataSource;

  AuthorizeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<Authorize>>> getAuthorizes(
      String token, int authorizeId, int hrId, int year) async {
    final result = await remoteDataSource.getAuthorizes(token, authorizeId, hrId, year);

    if (result.isSuccess && result.data != null) {
      final authorizes = result.data!.map((dto) => dto.toDomain()).toList();
      return ApiResult.success(authorizes);
    }

    return ApiResult.error(result.error ?? 'Failed to get authorizes');
  }
}

