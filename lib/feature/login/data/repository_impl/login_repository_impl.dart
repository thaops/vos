import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/data/datasources/local/login_local_datasource.dart';
import 'package:vos_flutter/feature/login/data/datasources/remote/login_remote_datasource.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/login/domain/models/user.dart';
import 'package:vos_flutter/feature/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;
  final LoginLocalDataSource localDataSource;
  LoginRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ApiResult<User>> signInWithGoogle() async {
    final result = await remoteDataSource.signInWithGoogle();
    if (result.isSuccess && result.data != null) {
      final dto = GoogleUserDto.fromDomain(result.data!);
      await localDataSource.saveUser(dto);
    }
    return result;
  }

  @override
  Future<ApiResult<User>> checkAuthState() async {
    // Ưu tiên check local trước
    final localUser = await localDataSource.getUser();
    if (localUser != null) {
      final remoteResult = await remoteDataSource.checkAuthState();
      if (remoteResult.isSuccess && remoteResult.data != null) {
        final dto = GoogleUserDto.fromDomain(remoteResult.data!);
        await localDataSource.saveUser(dto);
        return remoteResult;
      }
      return ApiResult.success(localUser.toDomain());
    }
    return await remoteDataSource.checkAuthState();
  }

  @override
  Future<ApiResult<void>> signOut() async {
    await localDataSource.clearUser();
    return await remoteDataSource.signOut();
  }
}
