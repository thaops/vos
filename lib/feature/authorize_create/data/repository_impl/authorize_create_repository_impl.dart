import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize_create/data/datasources/remote/authorize_create_remote_datasource.dart';
import 'package:vos_flutter/feature/authorize_create/domain/repositories/authorize_create_repository.dart';

class AuthorizeCreateRepositoryImpl implements AuthorizeCreateRepository {
  final AuthorizeCreateRemoteDataSource remoteDataSource;

  AuthorizeCreateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> searchAuthorizedPersons(
    String token,
    String query,
  ) async {
    return await remoteDataSource.searchAuthorizedPersons(token, query);
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeTypes(
    String token,
  ) async {
    return await remoteDataSource.loadAuthorizeTypes(token);
  }

  @override
  Future<ApiResult<List<Map<String, String>>>> loadAuthorizeStatuses(
    String token,
  ) async {
    return await remoteDataSource.loadAuthorizeStatuses(token);
  }

  @override
  Future<ApiResult<String>> createAuthorize(
    String token,
    Map<String, dynamic> payload,
  ) async {
    return await remoteDataSource.createAuthorize(token, payload);
  }
}
